import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/logutil.dart';
import '../utils/storage.dart';
import '../utils/toast.dart';
import 'response_entity.dart';

typedef StreamCallBack = Function(String var1);

class HttpUtils {
  static late final Dio dio;
  static final CancelToken _cancelToken = CancelToken();
  static Function? _unAuthHandle;

  /// 刷新 Authorization 和 refresh_token header
  static void refreshTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    dio.options.headers['refresh_token'] = refreshToken;
  }

  static init({Function? unAuthHandle}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _unAuthHandle = unAuthHandle;

    BaseOptions options = BaseOptions();
    dio = Dio(options);

    dio.options = dio.options.copyWith(
      baseUrl: SpUtil.baseUrl.val,
      connectTimeout: const Duration(seconds: 60),
    );

    // Ignore SSL certificate errors (for development purposes only)
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      var headers = options.headers;
      var authorization = headers['Authorization']?.toString();
      if (authorization == null || authorization.isEmpty) {
        // 注意这里 defaultValue 和 val 的区别
        // defaultValue 是默认值，val 是获取值
        options.headers['Authorization'] = 'Bearer ${SpUtil.token.val}';
      }

      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      headers['APP_packageName'] = packageName;
      headers['APP_version'] = version;
      headers['APP_buildNumber'] = buildNumber;
      headers['APP_platform'] = Platform.isAndroid ? "Android" : "iOS";

      // 新增：全局 header
      headers['__tenant'] = 'CF';

      handler.next(options);
    }));

    // 自动刷新 token 拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e, handler) async {
        // 只处理 401
        if (e.response?.statusCode == 401) {
          final refreshToken = SpUtil.refresh_token.val;
          if (refreshToken.isNotEmpty) {
            try {
              // 用 refresh_token 换新 token
              var refreshResponse = await dio.post(
                '${SpUtil.baseAuthUrl.val}/connect/token',
                data: {
                  'client_id': 'SimTech.Apex_App',
                  'grant_type': 'refresh_token',
                  'refresh_token': refreshToken,
                  'scope':
                      'TransportService PartnerService DeliveryService offline_access MobileService',
                },
                options: Options(
                  headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                  },
                ),
              );

              if (refreshResponse.statusCode == 200 &&
                  refreshResponse.data != null) {
                final newAccessToken = refreshResponse.data['access_token'];
                final newRefreshToken = refreshResponse.data['refresh_token'];

                // 保存新 token
                SpUtil.token.val = newAccessToken;
                SpUtil.refresh_token.val = newRefreshToken ?? '';

                // 刷新 header
                HttpUtils.refreshTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                // 重试原请求
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                final cloneReq = await dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                    contentType: opts.contentType,
                    responseType: opts.responseType,
                    followRedirects: opts.followRedirects,
                    validateStatus: opts.validateStatus,
                    receiveDataWhenStatusError: opts.receiveDataWhenStatusError,
                    extra: opts.extra,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } else {
                // refresh_token 失效，跳转登录
                _unAuthHandle?.call();
                return handler.next(e);
              }
            } catch (err) {
              // 刷新失败，跳转登录
              _unAuthHandle?.call();
              return handler.next(e);
            }
          } else {
            // 没有 refresh_token，跳转登录
            _unAuthHandle?.call();
            return handler.next(e);
          }
        }
        handler.next(e);
      },
    ));

    // 添加拦截器
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    // dio.interceptors.add(MyLogInterceptor());

    if (kDebugMode) {
      // DdCheckPlugin().init(
      //   dio,
      //   initHost: '192.168.1.89', // Change to your computer IP
      //   projectName: "AI", // Custom Project Name
      // );
    }
  }

  static void cancelRequests({CancelToken? token}) {
    if (token != null) {
      token.cancel("cancelled");
    } else {
      _cancelToken.cancel("cancelled");
    }
  }

  static Future<ResponseEntity<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    bool loadingDialog = false,
    bool showErrorTip = true,
  }) async {
    if (loadingDialog) {
      showLoading();
    }
    try {
      var response = await dio.get(
        path,
        queryParameters: params,
        options: options,
      );
      // 对返回数据进行包装
      Map<String, dynamic> wrappedData = {
        "code": 0,
        "msg": "success",
        "data": response.data,
      };

      var entity = ResponseEntity<T>.fromJson(wrappedData);

      return entity;
    } catch (e) {
      if (showErrorTip) {
        showError("网络错误");
      }
      return ResponseEntity<T>.fromJson({
        "code": 500,
      });
    } finally {
      if (loadingDialog) {
        dismissLoading();
      }
    }
  }

  static Future<ResponseEntity<T>> post<T>(
    String path, {
    data,
    Options? options,
    bool loadingDialog = false,
    bool showErrorTip = true,
  }) async {
    if (loadingDialog) {
      showLoading();
    }
    try {
      // Ensure Content-Type is set to application/x-www-form-urlencoded
      options ??= Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      var response = await dio.post(
        path,
        data: data,
        options: options,
      );

      // Wrap the response data
      Map<String, dynamic> wrappedData = {
        "code": 0,
        "msg": "success",
        "data": response.data,
      };

      var entity = ResponseEntity<T>.fromJson(wrappedData);
      return entity;
    } catch (e) {
      if (showErrorTip) {
        showError("网络错误");
      }
      return ResponseEntity<T>.fromJson({
        "code": 500,
      });
    } finally {
      if (loadingDialog) {
        dismissLoading();
      }
    }
  }

  /// 专门用于 application/json 的 POST
  static Future<ResponseEntity<T>> postJson<T>(
    String path, {
    dynamic data,
    Options? options,
    bool loadingDialog = false,
    bool showErrorTip = true,
  }) async {
    if (loadingDialog) {
      showLoading();
    }
    try {
      options ??= Options(headers: {'Content-Type': 'application/json'});
      var response = await dio.post(
        path,
        data: data is String ? data : jsonEncode(data),
        options: options,
      );
      Map<String, dynamic> wrappedData = {
        'code': 0,
        'msg': 'success',
        'data': response.data,
      };
      return ResponseEntity<T>.fromJson(wrappedData);
    } catch (e) {
      if (showErrorTip) {
        showError('网络错误');
      }
      return ResponseEntity<T>.fromJson({'code': 500});
    } finally {
      if (loadingDialog) dismissLoading();
    }
  }

  static void postForStream(
    String path,
    void Function(String event) onData, {
    data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Function? onError,
    void Function()? onDone,
  }) async {
    Response<ResponseBody> response;
    try {
      response = await dio.post<ResponseBody>(
        path,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      response.data?.stream
          .transform(unit8Transformer)
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())
          .listen(
        onData,
        onDone: onDone,
        onError: (d) {
          onError?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      logger.i(e);
      onError?.call();
    }
  }

  static StreamTransformer<Uint8List, List<int>> unit8Transformer =
      StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      sink.add(List<int>.from(data));
    },
  );

  // ignore: unused_element
  static Future<void> _dump401Token({
    required String phase,
    required RequestOptions req,
    Response? resp,
    String? newAccess,
    String? newRefresh,
  }) async {
    try {
      final ts = DateTime.now().toIso8601String();
      final access = newAccess ?? (SpUtil.token.val.toString());
      final refresh = newRefresh ?? (SpUtil.refresh_token.val.toString());
      final authHeader = req.headers['Authorization']?.toString() ?? '';
      final content = StringBuffer()
        ..writeln('[$ts][$phase]')
        ..writeln('URL: ${req.uri}')
        ..writeln('status: ${resp?.statusCode}')
        ..writeln('authHeader: $authHeader')
        ..writeln('accessToken: $access')
        ..writeln('refreshToken: $refresh')
        ..writeln('-----');

      final path = '${Directory.systemTemp.path}/last_401_token.txt';
      final file = File(path);
      await file.writeAsString(content.toString(),
          mode: FileMode.append, flush: true);
      debugPrint('401 tokens saved to: $path');
    } catch (_) {}
  }
}
