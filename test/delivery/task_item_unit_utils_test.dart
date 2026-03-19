import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/delivery/utils/task_item_unit_utils.dart';

void main() {
  group('normalizeTaskItemUnit', () {
    test('normalizes common piece aliases to U', () {
      expect(normalizeTaskItemUnit('pcs'), 'U');
      expect(normalizeTaskItemUnit('Pcs'), 'U');
      expect(normalizeTaskItemUnit('piece'), 'U');
      expect(normalizeTaskItemUnit(' each '), 'U');
      expect(normalizeTaskItemUnit(null), 'U');
    });

    test('normalizes common carton aliases to CTN', () {
      expect(normalizeTaskItemUnit('box'), 'CTN');
      expect(normalizeTaskItemUnit('Boxes'), 'CTN');
      expect(normalizeTaskItemUnit('carton'), 'CTN');
      expect(normalizeTaskItemUnit('ctn'), 'CTN');
    });
  });

  group('taskItemMergeKey', () {
    test('includes normalized unit so mixed units do not merge together', () {
      final pcsKey = taskItemMergeKey({
        'name': 'Apple',
        'uomName': 'pcs',
      });
      final ctnKey = taskItemMergeKey({
        'name': 'Apple',
        'uomName': 'box',
      });

      expect(pcsKey, isNot(equals(ctnKey)));
    });
  });
}
