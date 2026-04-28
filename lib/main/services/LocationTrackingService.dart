import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/location_event_payload.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  static const String _lastLocationLatKey = 'LAST_LOCATION_LAT';
  static const String _lastLocationLonKey = 'LAST_LOCATION_LON';
  static const Duration _eventUploadTimeout = Duration(seconds: 8);
  static const Duration _eventPositionTimeout = Duration(seconds: 6);

  static bool _configured = false;
  bool _started = false;
  Completer<void>? _startingLock;
  bool _stopRequested = false;
  int _lifecycleGeneration = 0;

  DateTime? _lastUploadAt;
  // 与 heartbeatInterval对齐，确保每次心跳都能通过时间窗口判断
  // final Duration uploadInterval = const Duration(minutes: 3);
  final Duration uploadInterval = const Duration(minutes: 1);
  // final Duration uploadInterval = const Duration(seconds: 10);

  bg.Location? _lastLocation;

  // ===== New: periodic forced uploader support =====
  Timer? _periodicTimer; // 每3分钟兜底强制上传一次
  String? _cachedIdentityUserId; // 缓存登录时传入的 identity (目前是 token, 占位即可)

  final _locationStreamController = StreamController<bg.Location>.broadcast();
  Stream<bg.Location> get locationStream => _locationStreamController.stream;

  Future<void> startTracking({
    String identityUserId = '', // 可以为空，上传时检查 vehicleId
    String? bearerToken,
  }) async {
    final generation = ++_lifecycleGeneration;
    _stopRequested = false;
    print(
        '[BG] startTracking(identity=$identityUserId) configured=$_configured started=$_started lock=${_startingLock != null}');
    _cachedIdentityUserId = identityUserId; // cache for timer fallback
    // Restore fast path
    if (_configured && _started) {
      try {
        final state = await bg.BackgroundGeolocation.state;
        print(
            '[BG][RESTORE] already running enabled=${state.enabled} isMoving=${state.isMoving}');
        if (state.isMoving != true) {
          await _tryChangePace('[RESTORE]');
          print('[BG][RESTORE] forced moving again');
        }
        if (_lastLocation != null) {
          print(
              '[BG][RESTORE] last cached lat=${_lastLocation!.coords.latitude} lon=${_lastLocation!.coords.longitude}');
          await _tryUpload(force: true, identityUserId: identityUserId);
        } else {
          print('[BG][RESTORE] no cached location -> force first fix');
          await _forceFirstFix(identityUserId);
        }
        _startPeriodicUploader();
        return;
      } catch (e) {
        print('[BG][RESTORE] quick path failed: $e -> continue normal flow');
      }
    }
    if (_startingLock != null) {
      try {
        await _startingLock!.future.timeout(const Duration(seconds: 4));
      } on TimeoutException {
        print('[BG] startTracking waited previous start lock timeout; continuing new start');
        _startingLock = null;
      }
      print('[BG] waited previous start. started=$_started');
      if (_isStartCancelled(generation)) {
        print('[BG] start aborted after waiting previous start');
        return;
      }
      if (_started) {
        await _tryUpload(force: true, identityUserId: identityUserId);
      }
      return;
    }

    if (!_configured) {
      await _configure();
    }

    // Request permission gracefully
    try {
      final auth = await bg.BackgroundGeolocation.requestPermission();
      print('[BG] permission result=$auth');
      if (auth == 2) {
        print('[BG] permission denied code=2 -> abort start');
        return;
      }
    } catch (e) {
      print('[BG] requestPermission error (ignored): $e');
    }

    bg.State? state;
    try {
      state = await bg.BackgroundGeolocation.state;
    } catch (e) {
      print('[BG] state retrieval error: $e');
    }
    if (state != null) {
      print(
          '[BG] current state enabled=${state.enabled} isMoving=${state.isMoving}');
      if (state.enabled) {
        _started = true;
        print('[BG] already enabled -> treat as restore');
        if (state.isMoving != true) {
          await _tryChangePace('[restore]');
          print('[BG] ✅ Forced moving state (restore)');
        }
        await _forceFirstFix(identityUserId);
        _startPeriodicUploader();
        return;
      }
    }

    final startLock = Completer<void>();
    _startingLock = startLock;
    try {
      if (_isStartCancelled(generation)) {
        print('[BG] start skipped: stop requested');
        return;
      }
      print('[BG] calling start() ...');
      await bg.BackgroundGeolocation.start();
      if (_isStartCancelled(generation)) {
        print('[BG] start completed after stop request -> stopping native service');
        await bg.BackgroundGeolocation.stop();
        return;
      }
      _started = true;
      print('[BG] start() success');
      await _tryChangePace('[start]');
      print('[BG] ✅ Forced moving state');

      // ⭐ 新增：强制触发第一次心跳（验证心跳是否工作）
      try {
        print('[BG] 🔥 Triggering first heartbeat manually...');
        final loc = await bg.BackgroundGeolocation.getCurrentPosition(
          samples: 1,
          timeout: 10000,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        );
        print(
            '[BG] 🔥 First heartbeat location: lat=${loc.coords.latitude} lon=${loc.coords.longitude}');
      } catch (e) {
        print('[BG] 🔥 First heartbeat failed (not critical): $e');
      }

      await _forceFirstFix(identityUserId);
      _startPeriodicUploader();

      // ⭐ 新增：启动后立即测试心跳机制
      print('[BG] 🧪 Testing heartbeat mechanism...');

      // 检查原生调度器状态
      final scheduleState = await bg.BackgroundGeolocation.state;
      print('[BG] 📋 Native scheduler state:');
      print('[BG]   - heartbeatInterval: ${scheduleState.heartbeatInterval}s');
      print('[BG]   - enabled: ${scheduleState.enabled}');
      print('[BG]   - isMoving: ${scheduleState.isMoving}');
      print('[BG]   - trackingMode: ${scheduleState.trackingMode}');
      print('[BG]   - distanceFilter: ${scheduleState.distanceFilter}');

      print(
          '[BG] ✅ Service started with heartbeat=${scheduleState.heartbeatInterval}s');
      print('[BG] ⏰ Next heartbeat expected in ~60 seconds...');
    } catch (e) {
      print('[BG] start() error: $e');
      if (_isStartCancelled(generation)) {
        print('[BG] start retry skipped: stop requested');
        return;
      }
      // Retry once after short delay if start fails
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (_isStartCancelled(generation)) {
          print('[BG] start retry skipped: stop requested');
          return;
        }
        print('[BG] retrying start() ...');
        await bg.BackgroundGeolocation.start();
        if (_isStartCancelled(generation)) {
          print('[BG] retry start completed after stop request -> stopping native service');
          await bg.BackgroundGeolocation.stop();
          return;
        }
        _started = true;
        print('[BG] retry start() success');
        await _tryChangePace('[retry]');
        print('[BG] ✅ Forced moving state (retry)');
        await _forceFirstFix(identityUserId);
        _startPeriodicUploader();
      } catch (e2) {
        print('[BG] retry start() failed: $e2');
      }
    } finally {
      if (!startLock.isCompleted) startLock.complete();
      if (identical(_startingLock, startLock)) {
        _startingLock = null;
      }
    }
  }

  bool _isStartCancelled(int generation) =>
      _stopRequested || generation != _lifecycleGeneration;

  Future<void> _tryChangePace(String reason) async {
    try {
      await bg.BackgroundGeolocation
          .changePace(true)
          .timeout(const Duration(seconds: 4));
    } on TimeoutException {
      print('[BG] changePace timeout $reason; continuing to first fix');
    } catch (e) {
      print('[BG] changePace failed $reason: $e');
    }
  }

  Future<void> stopTracking() async {
    _stopRequested = true;
    _lifecycleGeneration++;
    if (_startingLock != null) {
      try {
        await _startingLock!.future.timeout(const Duration(seconds: 4));
      } on TimeoutException {
        print('[BG] stopTracking waited start lock timeout; continuing stop');
      }
    }
    if (_started) {
      try {
        await bg.BackgroundGeolocation.stop();
        print('[BG] stopped');
      } catch (e) {
        print('[BG] stop error: $e');
      }
      _started = false;
      // cancel periodic timer
      _periodicTimer?.cancel();
      _periodicTimer = null;
    }
  }

  Future<void> _configure() async {
    if (_configured) {
      print('[BG] already configured, skipping');
      return;
    }

    print('[BG] configuring plugin...');
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);
    bg.BackgroundGeolocation.onProviderChange(_onProviderChange);

    try {
      // ⭐ 步骤1：使用 ready() 初始化基础配置
      final state = await bg.BackgroundGeolocation.ready(bg.Config(
        reset: false,

        // ============ 核心配置 ============
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        foregroundService: true,

        // ============ 心跳配置（关键！）============
        heartbeatInterval: 60, // 60秒心跳

        // ⭐ 关键：停止检测配置
        disableStopDetection: true, // 禁用停止检测
        stopTimeout: 0, // 永不自动停止
        stopOnStationary: false, // 静止时不停止

        // ⭐ 关键：位置更新配置
        distanceFilter: 0, // 距离过滤为0（依赖心跳）
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        locationUpdateInterval: 60000, // 60秒更新间隔
        fastestLocationUpdateInterval: 30000,
        allowIdenticalLocations: true,

        // ⭐ 关键：电池优化相关
        disableElasticity: true, // 禁用弹性策略
        activityType: bg.Config.ACTIVITY_TYPE_OTHER,

        // ⭐ iOS 配置（跨平台兼容）
        pausesLocationUpdatesAutomatically: false,
        showsBackgroundLocationIndicator: true,

        // ============ Android 特定配置 ============
        notification: bg.Notification(
          title: 'Location Service Running',
          text: 'Tracking delivery position',
          channelName: 'DeliveryTracking',
          priority: bg.Config.NOTIFICATION_PRIORITY_HIGH,
          sticky: true,
        ),

        // ============ 调试配置 ============
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_OFF,
        logMaxDays: 3,
      ));

      print('[BG] ready() -> enabled=${state.enabled}');

      // ⭐ 步骤2：使用 setConfig 强制应用关键配置（确保生效）
      await bg.BackgroundGeolocation.setConfig(bg.Config(
        heartbeatInterval: 60,
        disableStopDetection: true,
        stopTimeout: 0,
        distanceFilter: 0,
        locationUpdateInterval: 60000,
        fastestLocationUpdateInterval: 30000,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_OFF,
      ));

      print('[BG] ✅ Advanced config applied via setConfig');

      // ⭐ 步骤3：验证配置是否生效
      final verifyState = await bg.BackgroundGeolocation.state;
      print(
          '[BG] ✅ Verification: heartbeatInterval=${verifyState.heartbeatInterval}');
      print('[BG] ✅ Verification: stopTimeout=${verifyState.stopTimeout}');
      print(
          '[BG] ✅ Verification: disableStopDetection=${verifyState.disableStopDetection}');
      print(
          '[BG] ✅ Verification: distanceFilter=${verifyState.distanceFilter}');
      print(
          '[BG] ✅ Verification: locationUpdateInterval=${verifyState.locationUpdateInterval}');
      print(
          '[BG] ✅ Verification: scheduleUseAlarmManager=${verifyState.scheduleUseAlarmManager}');

      if (verifyState.enabled) {
        // 之前已经 start 过（原生 service 可能仍在）
        _started = true;
        _cachedIdentityUserId ??= SpUtil.token.val; // 尝试恢复 identity
        _startPeriodicUploader(); // 之前缺失
        await _tryUpload(
          force: true,
          identityUserId: _cachedIdentityUserId ?? '',
        );
      }

      _configured = true;
      print('[BG] configure done');
    } catch (e, stack) {
      print('[BG] ❌ configure error: $e');
      print(stack);
      rethrow;
    }
  }

  Future<void> _forceFirstFix(String identityUserId) async {
    print('[BG] obtaining first position...');
    try {
      final pos = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 30000,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        persist: true,
      );
      _onLocation(pos);
      await _tryUpload(force: true, identityUserId: identityUserId);
    } catch (e) {
      print('[BG] first getCurrentPosition error: $e');
    }
  }

  // ===== New: 启动兜底定时上传器 =====
  void _startPeriodicUploader() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(uploadInterval, (timer) async {
      if (!_started) return;
      final id = _cachedIdentityUserId ?? '';
      print('[BG] periodic tick -> force upload (idLen=${id.length})');
      await _tryUpload(force: true, identityUserId: id);
    });
    print(
        '[BG] periodic uploader started interval=${uploadInterval.inSeconds}s');
  }

  void _onLocation(bg.Location location) {
    _lastLocation = location;
    _locationStreamController.add(location);
    _saveLastLocation(location.coords.latitude, location.coords.longitude);
    print(
        '[BG] onLocation lat=${location.coords.latitude} lon=${location.coords.longitude}');
  }

  void _onLocationError(bg.LocationError error) {
    print('[BG] onLocationError $error');
  }

  void _onProviderChange(bg.ProviderChangeEvent event) async {
    print('[BG] onProviderChange $event');
    if (!event.enabled ||
        !event.gps ||
        event.status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_DENIED ||
        event.status ==
            bg.ProviderChangeEvent.AUTHORIZATION_STATUS_RESTRICTED) {
      await sendCurrentLocationEvent(LocationEventAddress.gpsLost);
    }
  }

  void _onHeartbeat(bg.HeartbeatEvent event) async {
    final now = DateTime.now();
    print('[BG] ❤️ heartbeat @ ${now.toIso8601String()}'); // 心跳触发

    // ⭐ 新增：检查心跳来源和状态
    try {
      final state = await bg.BackgroundGeolocation.state;
      print(
          '[BG] ❤️ State check: enabled=${state.enabled} isMoving=${state.isMoving}');
      print(
          '[BG] ❤️ Heartbeat config: interval=${state.heartbeatInterval}s alarm=${state.scheduleUseAlarmManager}');
    } catch (e) {
      print('[BG] ❤️ Failed to get state: $e');
    }

    try {
      final loc = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 30000,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        persist: true,
      );
      _onLocation(loc);
      final identityUserId = _cachedIdentityUserId ?? SpUtil.token.val;
      // 改为: 每次心跳都无条件上传, 保证静止也汇报
      await _tryUpload(force: true, identityUserId: identityUserId);
    } catch (e) {
      print('[BG] ❌ heartbeat getCurrentPosition error: $e');
    }
  }

  Future<void> _tryUpload({
    bool force = false,
    String identityUserId = '',
  }) async {
    final isLoggedIn = getBoolAsync(IS_LOGGED_IN);
    final hasToken = getStringAsync(USER_TOKEN).isNotEmpty;
    final isDeliveryMan = getStringAsync(USER_TYPE) == DELIVERY_MAN;

    if (!(isLoggedIn && hasToken && isDeliveryMan)) {
      print(
          '[BG] auth gate blocked upload: isLoggedIn=$isLoggedIn hasToken=$hasToken isDeliveryMan=$isDeliveryMan');
      return;
    }

    // 检查 vehicleId 是否存在，没有则跳过上传
    final vehicleId = SpUtil.getJSON("vehicleId");
    if (vehicleId == null || vehicleId.toString().isEmpty) {
      print('[BG] vehicleId missing in storage -> skip upload');
      return;
    }

    final now = DateTime.now();
    if (!force &&
        _lastUploadAt != null &&
        now.difference(_lastUploadAt!) < uploadInterval) {
      print('[BG] skip upload (interval)');
      return;
    }
    final loc = _lastLocation;
    if (loc == null) {
      print('[BG] no location yet -> skip upload');
      return;
    }

    _lastUploadAt = now;
    print('[BG] uploading...');
    try {
      final r = await HttpUtils.postJson(
        '/api/mobile/locations/create',
        data: buildLocationEventPayload(
          address: LocationEventAddress.normal,
          vehicleId: vehicleId.toString(),
          latitude: loc.coords.latitude,
          longitude: loc.coords.longitude,
        ),
      );
      if (r.code == 0) {
        print('[BG] upload success ${now.toIso8601String()}');
      } else {
        print('[BG] upload fail code=${r.code}');
      }
    } catch (e) {
      print('[BG] upload exception $e');
    }
  }

  bg.Location? get lastLocation => _lastLocation;

  Future<void> sendCurrentLocationEvent(LocationEventAddress address) async {
    print('[BG] event ${address.value} preparing upload');
    final isLoggedIn = getBoolAsync(IS_LOGGED_IN);
    final token = getStringAsync(USER_TOKEN);
    final isDeliveryMan = getStringAsync(USER_TYPE) == DELIVERY_MAN;

    if (!(isLoggedIn && token.isNotEmpty && isDeliveryMan)) {
      print(
          '[BG] event ${address.value} blocked: isLoggedIn=$isLoggedIn hasToken=${token.isNotEmpty} isDeliveryMan=$isDeliveryMan');
      return;
    }

    final vehicleId = await _readVehicleId();
    final location = await _readBestKnownLocation();
    if (location == null) {
      print('[BG] event ${address.value} skipped: no known location');
      return;
    }

    final payload = buildLocationEventPayload(
      address: address,
      vehicleId: vehicleId,
      latitude: location.$1,
      longitude: location.$2,
    );
    print('[BG] event ${address.value} payload=$payload');

    try {
      final r = await HttpUtils.postJson(
        '/api/mobile/locations/create',
        data: payload,
        showErrorTip: false,
      ).timeout(_eventUploadTimeout);
      print('[BG] event ${address.value} upload code=${r.code}');
    } on TimeoutException {
      print('[BG] event ${address.value} upload timed out');
    } catch (e) {
      print('[BG] event ${address.value} upload exception $e');
    }
  }

  Future<String?> _readVehicleId() async {
    final vehicleId = SpUtil.getJSON('vehicleId')?.toString();
    if (vehicleId != null && vehicleId.isNotEmpty) return vehicleId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sharedVehicleId = prefs.getString('vehicleId');
      if (sharedVehicleId != null && sharedVehicleId.isNotEmpty) {
        return sharedVehicleId;
      }
    } catch (_) {}

    return null;
  }

  Future<(double, double)?> _readBestKnownLocation() async {
    final loc = _lastLocation;
    if (loc != null) {
      return (loc.coords.latitude, loc.coords.longitude);
    }

    try {
      final pos = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 5000,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        persist: false,
      ).timeout(_eventPositionTimeout);
      _onLocation(pos);
      return (pos.coords.latitude, pos.coords.longitude);
    } catch (e) {
      print('[BG] get current location for event failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_lastLocationLatKey) ??
          prefs.getDouble('lastUploadLat');
      final lon = prefs.getDouble(_lastLocationLonKey) ??
          prefs.getDouble('lastUploadLon');
      if (lat != null && lon != null) return (lat, lon);
    } catch (_) {}

    return null;
  }

  Future<void> _saveLastLocation(double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_lastLocationLatKey, latitude);
      await prefs.setDouble(_lastLocationLonKey, longitude);
    } catch (_) {}
  }

  void dispose() {
    _locationStreamController.close();
  }

  // Cold start init: detect native service still running but Dart flags lost
  Future<void> ensureColdStartInit() async {
    try {
      final state = await bg.BackgroundGeolocation.state;

      // ⭐ 新增：如果已经 configured 且 started，说明正常运行中，无需恢复
      if (_configured && _started) {
        print(
            '[BG][COLD_START] Already running, skip init (configured=$_configured started=$_started)');
        return;
      }

      // If native still enabled but our Dart flags reset -> this is a cold start after process death.
      if (state.enabled && !_configured) {
        print(
            '[BG][COLD_START] detected enabled native state; rebuilding Dart side. isMoving=${state.isMoving}');

        // ⭐ 新增：检查 Headless 是否已经处理了 boot 事件
        // 通过检查最近的位置更新时间判断（5秒内有更新说明 Headless 已处理）
        try {
          final prefs = await SharedPreferences.getInstance();
          final lastHeadlessTime = prefs.getInt('lastHeadlessUploadTime') ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastHeadlessTime < 5000) {
            print(
                '[BG][COLD_START] Headless boot event handled recently, skip Dart-side init');
            // 仅重建监听器，不触发新的操作
            bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
            bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);
            bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
            _configured = true;
            _started = true;
            _cachedIdentityUserId ??= SpUtil.token.val;
            _startPeriodicUploader();
            return;
          }
        } catch (e) {
          print('[BG][COLD_START] Failed to check Headless timestamp: $e');
        }

        // Re-register listeners & mark configured
        bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
        bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);
        bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
        _configured = true; // mark
        _started = true; // mark running
        _cachedIdentityUserId ??= SpUtil.token.val; // attempt restore identity

        // Force moving if not
        if (state.isMoving != true) {
          await _tryChangePace('[COLD_START]');
          print('[BG][COLD_START] forced moving');
        }

        // Start periodic uploader
        _startPeriodicUploader();

        // ⭐ 修改：不立即上传，等待自然心跳或定时器触发
        print(
            '[BG][COLD_START] Restored service, waiting for next heartbeat/timer');
      } else {
        print(
            '[BG][COLD_START] no native enabled state to restore (enabled=${state.enabled} configured=$_configured)');
      }
    } catch (e) {
      print('[BG][COLD_START] error during ensureColdStartInit: $e');
    }
  }
}
