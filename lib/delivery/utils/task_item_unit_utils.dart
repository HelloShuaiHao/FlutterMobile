String normalizeTaskItemUnit(String? rawUnit) {
  final trimmed = rawUnit?.trim() ?? '';
  if (trimmed.isEmpty) return 'U';

  final normalized = trimmed.toLowerCase().replaceAll('.', '');

  const unitMap = <String, String>{
    'u': 'U',
    'unit': 'U',
    'units': 'U',
    'pc': 'U',
    'pcs': 'U',
    'piece': 'U',
    'pieces': 'U',
    'ea': 'U',
    'each': 'U',
    'item': 'U',
    'items': 'U',
    '个': 'U',
    '件': 'U',
    'box': 'CTN',
    'boxes': 'CTN',
    'carton': 'CTN',
    'cartons': 'CTN',
    'ctn': 'CTN',
    '箱': 'CTN',
    'kg': 'KG',
    'kgs': 'KG',
    'kilogram': 'KG',
    'kilograms': 'KG',
    'g': 'G',
    'gram': 'G',
    'grams': 'G',
    'lb': 'LB',
    'lbs': 'LB',
    'pound': 'LB',
    'pounds': 'LB',
    'mm': 'MM',
    'millimeter': 'MM',
    'millimeters': 'MM',
    'cm': 'CM',
    'centimeter': 'CM',
    'centimeters': 'CM',
    'm': 'M',
    'meter': 'M',
    'meters': 'M',
  };

  return unitMap[normalized] ?? trimmed.toUpperCase();
}

String taskItemMergeKey(Map<String, dynamic> item) {
  final itemName = item['name']?.toString().trim() ?? 'Unknown Item';
  final unit = normalizeTaskItemUnit(item['uomName']?.toString());
  return '$itemName||$unit';
}

String formatTaskItemCountLabel(int count, String? rawUnit) {
  final unit = normalizeTaskItemUnit(rawUnit);
  return '$count $unit';
}
