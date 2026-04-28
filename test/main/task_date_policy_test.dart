import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/main/utils/task_date_policy.dart';

void main() {
  group('task date policy', () {
    test('uses current local date when saved date is empty', () {
      expect(
        resolveTaskDate(now: DateTime(2026, 4, 11, 8, 30)),
        '2026-04-11',
      );
      expect(
        resolveTaskDate(savedDate: '', now: DateTime(2026, 4, 11, 8, 30)),
        '2026-04-11',
      );
    });

    test('keeps a saved selected date when present', () {
      expect(
        resolveTaskDate(savedDate: '2026-04-10', now: DateTime(2026, 4, 11)),
        '2026-04-10',
      );
    });
  });
}
