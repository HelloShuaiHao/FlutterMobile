import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/main/utils/location_event_payload.dart';

void main() {
  group('location event payload', () {
    test('uses the same API shape for normal, logout, and GPS lost events', () {
      expect(
        buildLocationEventPayload(
          address: LocationEventAddress.normal,
          vehicleId: '42',
          latitude: 1.3521,
          longitude: 103.8198,
        ),
        {
          'address': 'location.',
          'VehicleId': '42',
          'latitude': 1.3521,
          'longitude': 103.8198,
        },
      );

      expect(
        buildLocationEventPayload(
          address: LocationEventAddress.logout,
          vehicleId: '42',
          latitude: 1.3521,
          longitude: 103.8198,
        )['address'],
        'logout',
      );

      expect(
        buildLocationEventPayload(
          address: LocationEventAddress.gpsLost,
          vehicleId: '42',
          latitude: 1.3521,
          longitude: 103.8198,
        )['address'],
        'GPSLost',
      );
    });

    test('keeps vehicle id nullable for existing headless behavior', () {
      expect(
        buildLocationEventPayload(
          address: LocationEventAddress.gpsLost,
          vehicleId: null,
          latitude: 1,
          longitude: 2,
        ),
        {
          'address': 'GPSLost',
          'VehicleId': null,
          'latitude': 1.0,
          'longitude': 2.0,
        },
      );
    });
  });
}
