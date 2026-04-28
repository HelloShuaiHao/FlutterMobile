import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logout waits for clearData so logout event can finish first', () {
    final source = File('lib/main/network/RestApis.dart').readAsStringSync();
    final logoutStart = source.indexOf('Future<void> logout(');
    final logoutEnd = source.indexOf('/// Profile Update', logoutStart);
    final logoutSource = source
        .substring(logoutStart, logoutEnd)
        .split('\n')
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    expect(
      logoutSource.contains(RegExp(r'(?<!await )clearData\(\);')),
      isFalse,
    );
    expect(logoutSource.contains('await clearData();'), isTrue);
  });

  test('logout location event has a short timeout and cannot block logout', () {
    final source = File('lib/main/services/LocationTrackingService.dart')
        .readAsStringSync();
    final methodStart =
        source.indexOf('Future<void> sendCurrentLocationEvent(');
    final methodEnd =
        source.indexOf('Future<String?> _readVehicleId()', methodStart);
    final methodSource = source.substring(methodStart, methodEnd);

    expect(methodSource.contains('timeout('), isTrue);
    expect(methodSource.contains('TimeoutException'), isTrue);
  });
}
