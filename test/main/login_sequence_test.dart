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
}
