enum LocationEventAddress {
  normal('location.'),
  logout('logout'),
  gpsLost('GPSLost');

  const LocationEventAddress(this.value);

  final String value;
}

Map<String, dynamic> buildLocationEventPayload({
  required LocationEventAddress address,
  required String? vehicleId,
  required double latitude,
  required double longitude,
}) {
  return {
    'address': address.value,
    'VehicleId': vehicleId,
    'latitude': latitude,
    'longitude': longitude,
  };
}
