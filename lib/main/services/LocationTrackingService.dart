import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  static bool _configured = false;
  bool _started = false;
  Completer<void>? _startingLock;

  DateTime? _lastUploadAt;
  // 与 heartbeatInterval对齐，确保每次心跳都能通过时间窗口判断
  final Duration uploadInterval = const Duration(minutes: 3);
  // final Duration uploadInterval = const Duration(seconds: 10);

  bg.Location? _lastLocation;

  // ===== New: periodic forced uploader support =====
  Timer? _periodicTimer; // 每3分钟兜底强制上传一次
  String? _cachedIdentityUserId; // 缓存登录时传入的 identity (目前是 token, 占位即可)

  final _locationStreamController = StreamController<bg.Location>.broadcast();
  Stream<bg.Location> get locationStream => _locationStreamController.stream;

  Future<void> startTracking({
    required String identityUserId,
    String? bearerToken,
  }) async {
    print(
        '[BG] startTracking(identity=$identityUserId) configured=$_configured started=$_started lock=${_startingLock != null}');
    _cachedIdentityUserId = identityUserId; // cache for timer fallback
    if (_startingLock != null) {
      await _startingLock!.future;
      print('[BG] waited previous start. started=$_started');
      if (_started) {
        await _tryUpload(force: true, identityUserId: identityUserId);
      }
      return;
    }

    if (!_configured) {
      await _configure();
    }

    // 尝试请求权限
    try {
      final auth = await bg.BackgroundGeolocation.requestPermission();
      print('[BG] permission result=$auth (忽略枚举判断 - 版本无 AuthorizationStatus)');
      // 如果返回 int 且为典型拒绝码(例如 2)，可在此提前 return。
      if (auth == 2) {
        print('[BG] permission denied code=2 -> abort start');
        return;
      }
    } catch (e) {
      print(
          '[BG] requestPermission not supported or error: $e -> 继续尝试 start()');
    }

    final state = await bg.BackgroundGeolocation.state;
    print(
        '[BG] current state enabled=${state.enabled} isMoving=${state.isMoving}');
    if (state.enabled) {
      _started = true;
      print('[BG] already enabled -> skip start()');
      await _forceFirstFix(identityUserId);
      _startPeriodicUploader();
      return;
    }

    _startingLock = Completer<void>();
    try {
      print('[BG] calling start() ...');
      await bg.BackgroundGeolocation.start();
      _started = true;
      print('[BG] start() success');
      await _forceFirstFix(identityUserId);
      _startPeriodicUploader();
    } catch (e) {
      print('[BG] start() error: $e');
      rethrow;
    } finally {
      _startingLock?.complete();
      _startingLock = null;
    }
  }

  Future<void> stopTracking() async {
    if (_startingLock != null) await _startingLock!.future;
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
    if (_configured) return;
    print('[BG] configuring plugin...');
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onHeartbeat(_onHeartbeat);

    final state = await bg.BackgroundGeolocation.ready(bg.Config(
      reset: false,
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
      distanceFilter: 1000,
      disableElasticity: true,
      heartbeatInterval: 180,
      stopOnTerminate: false,
      startOnBoot: true,
      foregroundService: true,
      enableHeadless: true,
      allowIdenticalLocations: true,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_INFO,
      notification: bg.Notification(
        title: 'Location Service Running',
        text: 'Tracking delivery position',
        channelName: 'DeliveryTracking',
      ),
    ));

    print('[BG] ready() -> enabled=${state.enabled}');
    if (state.enabled) {
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
    print(
        '[BG] onLocation lat=${location.coords.latitude} lon=${location.coords.longitude}');
  }

  void _onLocationError(bg.LocationError error) {
    print('[BG] onLocationError $error');
  }

  void _onHeartbeat(bg.HeartbeatEvent event) async {
    final now = DateTime.now();
    print('[BG] heartbeat @ ${now.toIso8601String()}');
    try {
      final loc = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 30000,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        persist: true,
      );
      _onLocation(loc);
      final identityUserId = _cachedIdentityUserId ?? SpUtil.token.val;
      final last = _lastUploadAt;
      if (last != null) {
        final delta = now.difference(last);
        print(
            '[BG] since last upload: ${delta.inSeconds}s (threshold=${uploadInterval.inSeconds}s)');
      } else {
        print('[BG] since last upload: first run');
      }
      await _tryUpload(identityUserId: identityUserId);
      // 如果需要每次心跳无条件上传，改成下面这一行并注释掉上面一行：
      // await _tryUpload(force: true, identityUserId: identityUserId);
    } catch (e) {
      print('[BG] heartbeat getCurrentPosition error: $e');
    }
  }

  Future<void> _tryUpload({
    bool force = false,
    required String identityUserId,
  }) async {
    if (identityUserId.isEmpty) {
      print('[BG] identityUserId empty -> skip upload');
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
      // 读取登录/选择车辆时保存的 vehicleId
      final vehicleId = SpUtil.getJSON("vehicleId");
      if (vehicleId == null || vehicleId.toString().isEmpty) {
        print(
            '[BG] warning: vehicleId missing in storage, will upload without it');
      }
      final r = await HttpUtils.postJson('/api/mobile/locations/create', data: {
        // 按照 Postman 成功示例，仅携带 address / VehicleId / latitude / longitude
        'address': 'location.',
        'VehicleId': vehicleId, // 后端示例使用首字母大写
        'latitude': loc.coords.latitude,
        'longitude': loc.coords.longitude,
        // 如果后端以后需要再加 identityUserId / timeStamp，再放开：
        // 'identityUserId': someGuid,
        // 'timeStamp': loc.timestamp.toIso8601String(),
      });
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

  void dispose() {
    _locationStreamController.close();
  }
}
