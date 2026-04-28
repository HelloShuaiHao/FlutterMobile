import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/delivery/utils/vehicle_search_utils.dart';

void main() {
  group('vehicle search utils', () {
    final vehicles = [
      {'id': '1', 'vehicleTypeName': 'Van', 'vehicleRegisterNo': 'SGA1234'},
      {'id': '2', 'vehicleTypeName': 'Truck', 'vehicleRegisterNo': 'TMA7788'},
    ];

    test('builds a readable vehicle label', () {
      expect(vehicleSearchLabel(vehicles.first), 'Van - SGA1234');
    });

    test('filters by type or registration number case-insensitively', () {
      expect(filterVehicles(vehicles, 'van').map((e) => e['id']), ['1']);
      expect(filterVehicles(vehicles, '7788').map((e) => e['id']), ['2']);
      expect(filterVehicles(vehicles, '').length, 2);
    });
  });
}
