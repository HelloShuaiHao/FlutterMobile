String vehicleSearchLabel(Map<String, dynamic> vehicle) {
  final type = vehicle['vehicleTypeName']?.toString().trim() ?? '';
  final registerNo = selectedVehiclePlate(vehicle);

  if (type.isEmpty) return registerNo;
  if (registerNo.isEmpty) return type;
  return '$type - $registerNo';
}

String selectedVehiclePlate(Map<String, dynamic> vehicle) {
  return vehicle['vehicleRegisterNo']?.toString().trim() ?? '';
}

List<Map<String, dynamic>> filterVehicles(
  List<Map<String, dynamic>> vehicles,
  String query,
) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return List<Map<String, dynamic>>.from(vehicles);

  return vehicles.where((vehicle) {
    final label = vehicleSearchLabel(vehicle).toLowerCase();
    final id = vehicle['id']?.toString().toLowerCase() ?? '';
    return label.contains(normalizedQuery) || id.contains(normalizedQuery);
  }).toList();
}
