String resolveTaskDate({String? savedDate, DateTime? now}) {
  final trimmed = savedDate?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;

  final current = now ?? DateTime.now();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${current.year}-${two(current.month)}-${two(current.day)}';
}
