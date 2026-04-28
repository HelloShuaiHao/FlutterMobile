bool isLocationAccessBlocked({
  required bool permissionGranted,
  required bool serviceEnabled,
}) {
  return !permissionGranted || !serviceEnabled;
}
