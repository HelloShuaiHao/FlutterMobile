import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/main/utils/daily_logout_policy.dart';

void main() {
  group('daily logout policy', () {
    test('does not force logout before 23:50', () {
      expect(
        shouldForceDailyLogout(
          now: DateTime(2026, 4, 11, 23, 49),
          lastLogoutAt: null,
        ),
        isFalse,
      );
    });

    test('forces logout at 23:50 once per local day', () {
      final now = DateTime(2026, 4, 11, 23, 50);

      expect(shouldForceDailyLogout(now: now, lastLogoutAt: null), isTrue);
      expect(
        shouldForceDailyLogout(
          now: now,
          lastLogoutAt: DateTime(2026, 4, 11, 23, 50),
        ),
        isFalse,
      );
      expect(
        shouldForceDailyLogout(
          now: now,
          lastLogoutAt: DateTime(2026, 4, 10, 23, 50),
        ),
        isTrue,
      );
    });

    test('schedules the next 23:50 local logout time', () {
      expect(
        nextDailyLogoutAt(DateTime(2026, 4, 11, 12, 0)),
        DateTime(2026, 4, 11, 23, 50),
      );
      expect(
        nextDailyLogoutAt(DateTime(2026, 4, 11, 23, 51)),
        DateTime(2026, 4, 12, 23, 50),
      );
    });
  });
}
