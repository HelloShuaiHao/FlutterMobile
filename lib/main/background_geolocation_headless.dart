import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
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

  switch (event.name) {
    case bg.Event.LOCATION:
      await _handleLocation(event.event as bg.Location);
      break;

    case bg.Event.HEARTBEAT:
      print('[HEADLESS] HEARTBEAT - fetching current position');
      // 心跳事件：主动获取当前位置并上传
      try {
        final loc = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 30000,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
          persist: true,
        );
        await _handleLocation(loc);
      } catch (e) {
        print('[HEADLESS] heartbeat getCurrentPosition error: $e');
      }
      break;

    case bg.Event.TERMINATE:
      print('[HEADLESS] TERMINATE - app terminated');
      // App 终止事件：可选择上传最后位置
      try {
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

    default:
      print('[HEADLESS] unhandled event: ${event.name}');
      break;
  }
}

/// 处理位置上传的核心逻辑
Future<void> _handleLocation(bg.Location loc) async {
  print(
      '[HEADLESS] location lat=${loc.coords.latitude} lon=${loc.coords.longitude}');

  // ⭐ 关键修改：使用 SharedPreferences 替代 GetStorage
  String? vehicleId;
  String? token;

  try {
    final prefs = await SharedPreferences.getInstance();

    // 读取 vehicleId
    vehicleId = prefs.getString('vehicleId');

    // 读取 token（用于后续可能的认证需求）
    token = prefs.getString('USER_TOKEN');

    print('[HEADLESS] vehicleId=$vehicleId (from SharedPreferences)');
    print(
        '[HEADLESS] token=${token?.substring(0, 20)}... (length=${token?.length ?? 0})');

    if (vehicleId == null || vehicleId.isEmpty) {
      print('[HEADLESS] ⚠️ vehicleId is null or empty, will upload without it');
    }
  } catch (e) {
    print('[HEADLESS] ⚠️ Failed to read SharedPreferences: $e');
  }

  try {
    final resp =
        await HttpUtils.postJson('/api/mobile/locations/create', data: {
      'address': 'location.',
      'VehicleId': vehicleId,
      'latitude': loc.coords.latitude,
      'longitude': loc.coords.longitude,
    });

    if (resp.code == 0) {
      print(
          '[HEADLESS] ✅ upload success ${DateTime.now().toUtc().toIso8601String()}');
    } else {
      print('[HEADLESS] ❌ upload fail code=${resp.code} msg=${resp.msg}');
    }
  } catch (e) {
    print('[HEADLESS] ⚠️ upload exception $e');
  }
}
