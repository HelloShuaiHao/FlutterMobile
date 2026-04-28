const int dailyLogoutHour = 23;
const int dailyLogoutMinute = 50;
const String lastDailyForcedLogoutAtKey = 'LAST_DAILY_FORCED_LOGOUT_AT';

bool shouldForceDailyLogout({
  required DateTime now,
  required DateTime? lastLogoutAt,
  int hour = dailyLogoutHour,
  int minute = dailyLogoutMinute,
}) {
  final cutoff = DateTime(now.year, now.month, now.day, hour, minute);
  if (now.isBefore(cutoff)) return false;
  if (lastLogoutAt == null) return true;
  return !_isSameLocalDay(now, lastLogoutAt);
}

DateTime nextDailyLogoutAt(
  DateTime now, {
  int hour = dailyLogoutHour,
  int minute = dailyLogoutMinute,
}) {
  final today = DateTime(now.year, now.month, now.day, hour, minute);
  return now.isBefore(today) || now.isAtSameMomentAs(today)
      ? today
      : today.add(const Duration(days: 1));
}

bool _isSameLocalDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
