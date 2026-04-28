import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⭐ 改用 SharedPreferences

/// Headless 回调函数
/// 在 App 被完全杀死后，原生定位服务仍会触发此函数
/// 这是一个独立的 Dart 引擎入口点，不依赖主应用的状态
@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent event) async {
  print(
      '[HEADLESS] event=${event.name} at ${DateTime.now().toIso8601String()}');

  // ⭐ 新增：过滤掉安装/替换事件，避免在安装时触发
  if (event.name == bg.Event.BOOT) {
    // 检查是否是真正的开机事件（而不是安装/替换）
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBootTime = prefs.getInt('lastBootTime') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // 如果距离上次"开机"小于 10 秒，认为是安装/替换事件，跳过
      if (currentTime - lastBootTime < 10000) {
        print(
            '[HEADLESS] ⚠️ Detected app installation/replacement event, skipping...');
        return;
      }

      // 记录本次开机时间
      await prefs.setInt('lastBootTime', currentTime);
      print('[HEADLESS] ✅ Real boot event detected, proceeding...');
    } catch (e) {
      print('[HEADLESS] ⚠️ Failed to check boot event: $e');
    }
  }

  // 在关键事件上保证配置被重新应用 (防止被系统重置)
  Future<void> _ensureConfig() async {
    try {
      final state = await bg.BackgroundGeolocation.state;

      // ⭐ 修改：检查关键配置项并打印详细信息
      final needsReconfigure = state.distanceFilter != 0 ||
          state.heartbeatInterval != 60 ||
          state.stopTimeout != 0 ||
          state.disableStopDetection != true;

      if (needsReconfigure) {
        print('[HEADLESS] ⚠️ Config mismatch detected, enforcing...');
        print(
            '[HEADLESS]   distanceFilter: ${state.distanceFilter} (expected: 0)');
        print(
            '[HEADLESS]   heartbeatInterval: ${state.heartbeatInterval} (expected: 60)');
        print('[HEADLESS]   stopTimeout: ${state.stopTimeout} (expected: 0)');
        print(
            '[HEADLESS]   disableStopDetection: ${state.disableStopDetection} (expected: true)');

        await bg.BackgroundGeolocation.setConfig(bg.Config(
          distanceFilter: 0,
          heartbeatInterval: 60,
          stopTimeout: 0,
          disableStopDetection: true,
          locationUpdateInterval: 60000,
          fastestLocationUpdateInterval: 30000,
          stopOnTerminate: false,
          startOnBoot: true,
          foregroundService: true,
          enableHeadless: true,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          allowIdenticalLocations: true,
          disableElasticity: true,
          debug: false,
          logLevel: bg.Config.LOG_LEVEL_OFF,
        ));

        print('[HEADLESS] ✅ Config enforced');
      } else {
        print('[HEADLESS] ✅ Config is correct');
      }

      // 确保 moving 状态
      if (state.isMoving != true) {
        await bg.BackgroundGeolocation.changePace(true);
        print('[HEADLESS] ✅ Forced moving state');
      }
    } catch (e) {
      print('[HEADLESS] ensureConfig error: $e');
    }
  }

  Future<void> _safe(Function fn) async {
    try {
      await fn();
    } catch (e) {
      print('[HEADLESS] safe wrapper error: $e');
    }
  }

  switch (event.name) {
    case bg.Event.LOCATION:
      await _safe(() async {
        await _ensureConfig();
        await _handleLocation(event.event as bg.Location);
      });
      break;
    case bg.Event.MOTIONCHANGE:
      try {
        // event.event 可能是 Map 或含有 location 字段
        final raw = event.event;
        await _ensureConfig();
        if (raw is Map && raw['location'] != null) {
          // location 序列化结构由插件提供；用 BackgroundGeolocation API 再拉一次更保险
          final fresh = await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            timeout: 15000,
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
            persist: true,
          );
          await _handleLocation(fresh);
        } else {
          // 直接再取一次当前位置
          final fresh = await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            timeout: 15000,
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
            persist: true,
          );
          await _handleLocation(fresh);
        }
      } catch (e) {
        print('[HEADLESS] motionchange handling error: $e');
      }
      break;
    case bg.Event.PROVIDERCHANGE:
      // 仅记录，某些 ROM 会在 providerchange 后紧跟一次 location
      print('[HEADLESS] providerchange payload=${jsonEncode(event.event)}');
      break;

    case bg.Event.HEARTBEAT:
      await _safe(() async {
        print('[HEADLESS] HEARTBEAT - enforce config & fetch');
        await _ensureConfig();
        final loc = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 30000,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
          persist: true,
        );
        await _handleLocation(loc);
        print('[HEADLESS] ❤️ heartbeat upload attempted');
      });
      break;

    case bg.Event.TERMINATE:
      print('[HEADLESS] TERMINATE - app terminated');
      // App 终止事件：可选择上传最后位置
      try {
        await _ensureConfig();
        final state = await bg.BackgroundGeolocation.state;
        if (state.enabled) {
          final loc = await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            timeout: 10000,
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
          );
          await _handleLocation(loc);
        }
      } catch (e) {
        print('[HEADLESS] terminate position error: $e');
      }
      break;
    case bg.Event.BOOT:
      await _safe(() async {
        print('[HEADLESS] BOOT - enforce config & force moving');
        await _ensureConfig();
        final loc = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 30000,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
          persist: true,
        );
        await _handleLocation(loc);
      });
      break;

    default:
      print('[HEADLESS] unhandled event: ${event.name}');
      break;
  }
}

/// 处理位置上传的核心逻辑
Future<void> _handleLocation(bg.Location loc) async {
  print(
      '[HEADLESS] location lat=${loc.coords.latitude} lon=${loc.coords.longitude}');

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool(IS_LOGGED_IN) ?? false;
  final token = prefs.getString(USER_TOKEN) ?? '';
  final userType = prefs.getString(USER_TYPE) ?? '';

  if (!(isLoggedIn && token.isNotEmpty && userType == DELIVERY_MAN)) {
    print(
        '[HEADLESS] auth gate blocked upload: isLoggedIn=$isLoggedIn hasToken=${token.isNotEmpty} userType=$userType');
    return;
  }

  // ⭐ 新增：去重逻辑 - 检查是否和上次位置相同且时间过近
  try {
    final lastLat = prefs.getDouble('lastUploadLat');
    final lastLon = prefs.getDouble('lastUploadLon');
    final lastUploadTime = prefs.getInt('lastHeadlessUploadTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 如果位置相同（精度到小数点后6位）且时间间隔小于 5 秒，跳过
    if (lastLat != null && lastLon != null) {
      final latDiff = (loc.coords.latitude - lastLat).abs();
      final lonDiff = (loc.coords.longitude - lastLon).abs();
      final timeDiff = currentTime - lastUploadTime;

      if (latDiff < 0.000001 && lonDiff < 0.000001 && timeDiff < 5000) {
        print(
            '[HEADLESS] ⏭️ Skipping duplicate upload (same location within 5s)');
        return;
      }
    }

    // 记录本次上传的位置和时间
    await prefs.setDouble('lastUploadLat', loc.coords.latitude);
    await prefs.setDouble('lastUploadLon', loc.coords.longitude);
    await prefs.setInt('lastHeadlessUploadTime', currentTime);
  } catch (e) {
    print('[HEADLESS] ⚠️ Failed to check/save deduplication data: $e');
  }

  // ⭐ 关键修改：使用 SharedPreferences 替代 GetStorage
  String? vehicleId;
  String bearerToken = token;

  try {
    // 读取 vehicleId
    vehicleId = prefs.getString('vehicleId');

    // 读取 token（用于后续可能的认证需求）
    final tokenPreview =
        bearerToken.length > 20 ? bearerToken.substring(0, 20) : bearerToken;
    print('[HEADLESS] vehicleId=$vehicleId (from SharedPreferences)');
    print('[HEADLESS] token=$tokenPreview... (length=${bearerToken.length})');

    if (vehicleId == null || vehicleId.isEmpty) {
      print('[HEADLESS] ⚠️ vehicleId is null or empty, will upload without it');
    }
  } catch (e) {
    print('[HEADLESS] ⚠️ Failed to read SharedPreferences: $e');
  }

  // ===== 构造 payload =====
  // Address 逻辑：优先从 SharedPreferences 读取最近一次前台保存的 address（如果你后续在前台写入）
  String address = 'location.'; // 默认占位
  try {
    final lastAddress = prefs.getString('LAST_KNOWN_ADDRESS');
    if (lastAddress != null && lastAddress.isNotEmpty) {
      address = lastAddress;
    }
  } catch (_) {}

  final payload = <String, dynamic>{
    'address': address,
    'VehicleId': vehicleId,
    'latitude': loc.coords.latitude,
    'longitude': loc.coords.longitude,
  };
  print('[HEADLESS] 📤 Uploading payload: $payload');

  // 优先使用独立 Dio，避免 HttpUtils 可能尚未 init（主 isolate 尚未运行）
  try {
    final base = SpUtil.baseUrl.val;
    final Dio dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
        '__tenant': 'CF',
      },
    ));

    print('[HEADLESS] baseUrl=$base hasToken=${bearerToken.isNotEmpty}');
    final resp = await dio.post(
      '/api/mobile/locations/create',
      data: jsonEncode(payload),
    );

    if (resp.statusCode != null &&
        resp.statusCode! >= 200 &&
        resp.statusCode! < 300) {
      print('[HEADLESS] ✅ upload success (raw) status=${resp.statusCode}');
    } else {
      print(
          '[HEADLESS] ❌ raw http status=${resp.statusCode} body=${resp.data}');
    }
  } catch (e) {
    print('[HEADLESS] ⚠️ direct Dio upload failed: $e');
    // 回退使用 HttpUtils（如果已经初始化）
    try {
      // Fallback: 使用已初始化的 HttpUtils (主 isolate 已经跑起来的情况下)
      try {
        final wrapper = await HttpUtils.postJson('/api/mobile/locations/create',
            data: payload, showErrorTip: false);
        if (wrapper.code == 0) {
          print('[HEADLESS] ✅ fallback upload success');
          return;
        } else {
          print('[HEADLESS] ❌ fallback wrapper code=${wrapper.code}');
        }
      } catch (_) {
        // ignore
      }
    } catch (ee) {
      print('[HEADLESS] ❌ fallback upload exception $ee');
    }
  }
}
