import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mighty_delivery/main/models/PendingRequest.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/services/RoutePlanService.dart';
import 'package:path_provider/path_provider.dart';

class PendingRequestService {
  static final PendingRequestService instance = PendingRequestService._internal();
  factory PendingRequestService() => instance;
  PendingRequestService._internal();

  static const String _storageKey = 'pending_requests';
  final List<PendingRequest> _pendingRequests = [];
  final _controller = StreamController<List<PendingRequest>>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isRetrying = false;

  Stream<List<PendingRequest>> get requestsStream => _controller.stream;
  List<PendingRequest> get pendingRequests => List.unmodifiable(_pendingRequests);
  int get pendingCount => _pendingRequests.length;

  /// 初始化服务
  Future<void> initialize() async {
    await _loadFromStorage();
    _startNetworkMonitoring();
  }

  /// 从本地存储加载待处理请求
  Future<void> _loadFromStorage() async {
    try {
      final storage = GetStorage();
      final data = storage.read(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _pendingRequests.clear();
        _pendingRequests.addAll(
          jsonList.map((json) => PendingRequest.fromJson(json)).toList(),
        );
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
    }
  }

  /// 保存到本地存储
  Future<void> _saveToStorage() async {
    try {
      final storage = GetStorage();
      final jsonList = _pendingRequests.map((r) => r.toJson()).toList();
      await storage.write(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving pending requests: $e');
    }
  }

  /// 添加待处理请求
  Future<void> addRequest({
    required RequestType type,
    required String taskId,
    required String taskName,
    required Map<String, dynamic> requestData,
    String? photoPath,
    String? signaturePath,
  }) async {
    final request = PendingRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      taskId: taskId,
      taskName: taskName,
      requestData: requestData,
      createdAt: DateTime.now(),
      photoPath: photoPath,
      signaturePath: signaturePath,
    );

    _pendingRequests.add(request);
    await _saveToStorage();
    _notifyListeners();

    // 立即尝试执行一次
    await _retryRequest(request);
  }

  /// 开始网络监听
  void _startNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        // 检查是否有网络连接
        final hasConnection = results.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet);

        if (hasConnection && !_isRetrying && _pendingRequests.isNotEmpty) {
          debugPrint('Network restored, retrying pending requests...');
          retryAll();
        }
      },
    );
  }

  /// 重试所有待处理请求
  Future<void> retryAll() async {
    if (_isRetrying || _pendingRequests.isEmpty) return;

    _isRetrying = true;
    debugPrint('Retrying ${_pendingRequests.length} pending requests...');

    // 创建一个副本来避免并发修改
    final requestsToRetry = List<PendingRequest>.from(_pendingRequests);

    for (final request in requestsToRetry) {
      await _retryRequest(request);
      // 添加短暂延迟避免过快请求
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _isRetrying = false;
  }

  /// 重试单个请求
  Future<bool> _retryRequest(PendingRequest request) async {
    try {
      // 更新状态为重试中
      _updateRequest(
        request.id,
        request.copyWith(status: RequestStatus.retrying),
      );

      bool success = false;

      switch (request.type) {
        case RequestType.taskStatus:
          success = await _retryTaskStatus(request);
          break;
        case RequestType.proofOfDelivery:
          success = await _retryProofOfDelivery(request);
          break;
        case RequestType.pickup:
        case RequestType.delivery:
          success = await _retryTaskStatus(request);
          break;
      }

      if (success) {
        // 成功，从队列中移除
        await removeRequest(request.id);
        debugPrint('Request ${request.id} completed successfully');
      } else {
        // 失败，更新重试次数
        _updateRequest(
          request.id,
          request.copyWith(
            status: RequestStatus.failed,
            retryCount: request.retryCount + 1,
            errorMessage: '重试失败',
          ),
        );
      }

      return success;
    } catch (e) {
      debugPrint('Error retrying request ${request.id}: $e');
      _updateRequest(
        request.id,
        request.copyWith(
          status: RequestStatus.failed,
          retryCount: request.retryCount + 1,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// 重试任务状态更新
  Future<bool> _retryTaskStatus(PendingRequest request) async {
    try {
      final routePlanService = RoutePlanService();
      await routePlanService.addTaskStatus(
        taskId: request.requestData['taskId'] as String,
        statusCode: request.requestData['statusCode'] as String,
        name: request.requestData['name'] as String,
        senderMessage: request.requestData['senderMessage'] as String,
        receiverMessage: request.requestData['receiverMessage'] as String,
        colorHex: request.requestData['colorHex'] as String,
        itemIds: List<String>.from(request.requestData['itemIds'] as List),
        itemRemarks: request.requestData['itemRemarks'] != null
            ? List<Map<String, dynamic>>.from(
                request.requestData['itemRemarks'] as List)
            : null,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to retry task status: $e');
      return false;
    }
  }

  /// 重试 Proof of Delivery 上传
  Future<bool> _retryProofOfDelivery(PendingRequest request) async {
    try {
      if (request.photoPath == null || request.signaturePath == null) {
        debugPrint('Missing photo or signature path');
        return false;
      }

      // 检查文件是否存在
      final photoFile = File(request.photoPath!);
      final signatureFile = File(request.signaturePath!);

      if (!await photoFile.exists() || !await signatureFile.exists()) {
        debugPrint('Photo or signature file not found');
        return false;
      }

      // 创建 FormData
      FormData formData = FormData.fromMap({
        'TaskHeaderId': request.requestData['taskHeaderId'] as String,
        'SignatureFile': await MultipartFile.fromFile(
          signatureFile.path,
          filename: 'signature.png',
        ),
        'Notes': request.requestData['notes'] as String? ?? '',
        'Photos[0].PhotoFile': await MultipartFile.fromFile(
          photoFile.path,
          filename: 'photo.jpg',
        ),
        'Photos[0].PhotoType': request.requestData['photoType'] as String? ?? '1',
        'Photos[0].Description':
            request.requestData['photoDescription'] as String? ?? '现场照片',
      });

      // 调用上传 API
      final response = await HttpUtils.uploadMultipart(
        '/api/delivery/proof-of-delivery/upload',
        formData: formData,
        loadingDialog: false,
        showErrorTip: false,
      );

      if (response.code == 0) {
        // 上传成功后删除临时文件
        try {
          await signatureFile.delete();
        } catch (_) {}
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Failed to retry proof of delivery: $e');
      return false;
    }
  }

  /// 手动重试单个请求
  Future<bool> retryRequest(String requestId) async {
    final request = _pendingRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => throw Exception('Request not found'),
    );
    return await _retryRequest(request);
  }

  /// 更新请求
  void _updateRequest(String requestId, PendingRequest updatedRequest) {
    final index = _pendingRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _pendingRequests[index] = updatedRequest;
      _saveToStorage();
      _notifyListeners();
    }
  }

  /// 移除请求
  Future<void> removeRequest(String requestId) async {
    _pendingRequests.removeWhere((r) => r.id == requestId);
    await _saveToStorage();
    _notifyListeners();
  }

  /// 清空所有请求
  Future<void> clearAll() async {
    _pendingRequests.clear();
    await _saveToStorage();
    _notifyListeners();
  }

  /// 通知监听器
  void _notifyListeners() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_pendingRequests));
    }
  }

  /// 释放资源
  void dispose() {
    _connectivitySubscription?.cancel();
    _controller.close();
  }
}
