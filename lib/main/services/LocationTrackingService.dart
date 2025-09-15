import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import '../../main/utils/Constants.dart';

class LocationTrackingService {
  LocationTrackingService._();
  static final LocationTrackingService instance = LocationTrackingService._();

  static bool _configured = false;
  bool _started = false;
  Completer<void>? _startingLock;

  DateTime? _lastUploadAt;
  final Duration uploadInterval = const Duration(minutes: 5);

  bg.Location? _lastLocation;

  final _locationStreamController = StreamController<bg.Location>.broadcast();
  Stream<bg.Location> get locationStream => _locationStreamController.stream;

  Future<void> startTracking({
    required String identityUserId,
    String? bearerToken,
  }) async {
    print(
        '[BG] startTracking(identity=$identityUserId) configured=$_configured started=$_started lock=${_startingLock != null}');
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
      return;
    }

    _startingLock = Completer<void>();
    try {
      print('[BG] calling start() ...');
      await bg.BackgroundGeolocation.start();
      _started = true;
      print('[BG] start() success');
      await _forceFirstFix(identityUserId);
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
      heartbeatInterval: 180, // 5分钟；调试想快点可临时改 10
      stopOnTerminate: false,
      startOnBoot: true,
      foregroundService: true,
      allowIdenticalLocations: true,
      debug: true, // 调试用，确认事件。上线改 false
      logLevel: bg.Config.LOG_LEVEL_INFO,
    ));

    print('[BG] ready() -> enabled=${state.enabled}');
    if (state.enabled) _started = true;
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
    print('[BG] heartbeat @ ${DateTime.now().toIso8601String()}');
    try {
      final loc = await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 30000,
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_LOW,
        persist: true,
      );
      _onLocation(loc);
      final identityUserId = SpUtil.token.val;
      await _tryUpload(identityUserId: identityUserId);
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
      final r = await HttpUtils.post('/api/mobile/locations/create', data: {
        'latitude': loc.coords.latitude,
        'longitude': loc.coords.longitude,
        'timeStamp': loc.timestamp,
        'identityUserId': identityUserId,
        'address': 'location.'
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
