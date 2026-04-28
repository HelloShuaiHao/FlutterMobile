import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login does not block navigation on location service lifecycle', () {
    final source = File('lib/main/screens/LoginScreen.dart').readAsStringSync();
    final loginStart = source.indexOf('Future<void> loginApiCall()');
    final loginEnd =
        source.indexOf('Future<String> updateStoreCheckerData()', loginStart);
    final loginSource = source
        .substring(loginStart, loginEnd)
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    expect(
        loginSource
            .contains('await LocationTrackingService.instance.stopTracking()'),
        isFalse);
    expect(
        loginSource
            .contains('await LocationTrackingService.instance.startTracking('),
        isFalse);
    expect(
        loginSource
            .contains('DHomeFragment().launch(context, isNewTask: true);'),
        isTrue);
  });

  test('stop tracking does not wait forever for pending start', () {
    final source =
        File('lib/main/services/LocationTrackingService.dart').readAsStringSync();
    final stopStart = source.indexOf('Future<void> stopTracking()');
    final stopEnd = source.indexOf('Future<void> _configure()', stopStart);
    final stopSource = source.substring(stopStart, stopEnd);

    expect(stopSource.contains('_startingLock!.future.timeout('), isTrue);
    expect(stopSource.contains('on TimeoutException'), isTrue);
  });

  test('location start lifecycle does not revive after logout stop request', () {
    final source =
        File('lib/main/services/LocationTrackingService.dart').readAsStringSync();
    final startStart = source.indexOf('Future<void> startTracking({');
    final startEnd = source.indexOf('Future<void> stopTracking()', startStart);
    final startSource = source.substring(startStart, startEnd);
    final stopStart = source.indexOf('Future<void> stopTracking()');
    final stopEnd = source.indexOf('Future<void> _configure()', stopStart);
    final stopSource = source.substring(stopStart, stopEnd);

    expect(source.contains('bool _stopRequested = false;'), isTrue);
    expect(startSource.contains('_stopRequested = false;'), isTrue);
    expect(startSource.contains('_startingLock!.future.timeout('), isTrue);
    expect(startSource.contains('start retry skipped: stop requested'), isTrue);
    expect(startSource.contains('final startLock = Completer<void>();'),
        isTrue);
    expect(startSource.contains('identical(_startingLock, startLock)'), isTrue);
    expect(stopSource.contains('_stopRequested = true;'), isTrue);
  });

  test('restore path obtains first fix when cached location is missing', () {
    final source =
        File('lib/main/services/LocationTrackingService.dart').readAsStringSync();
    final startStart = source.indexOf('Future<void> startTracking({');
    final lockStart = source.indexOf('if (_startingLock != null)', startStart);
    final restoreSource = source.substring(startStart, lockStart);

    expect(restoreSource.contains('await _forceFirstFix(identityUserId);'),
        isTrue);
  });

  test('change pace cannot block first location upload after start', () {
    final source =
        File('lib/main/services/LocationTrackingService.dart').readAsStringSync();
    final startStart = source.indexOf('Future<void> startTracking({');
    final startEnd = source.indexOf('Future<void> stopTracking()', startStart);
    final startSource = source.substring(startStart, startEnd);

    expect(source.contains('Future<void> _tryChangePace('), isTrue);
    expect(source.contains('changePace(true)'), isTrue);
    expect(source.contains('.timeout(const Duration(seconds: 4))'), isTrue);
    expect(startSource.contains('await _tryChangePace('), isTrue);
    expect(startSource.contains('await bg.BackgroundGeolocation.changePace(true)'),
        isFalse);
  });

  test('home resume re-enters tracking restore when native service is running', () {
    final source =
        File('lib/delivery/fragment/DHomeFragment.dart').readAsStringSync();

    expect(source.contains('Location service already running'), isTrue);
    expect(
      source.contains('LocationTrackingService.instance.startTracking('),
      isTrue,
    );
  });
}
