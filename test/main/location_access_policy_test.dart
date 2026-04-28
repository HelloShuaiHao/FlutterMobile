import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/main/utils/location_access_policy.dart';

void main() {
  group('location access policy', () {
    test('blocks the app when permission or service is unavailable', () {
      expect(
        isLocationAccessBlocked(
          permissionGranted: false,
          serviceEnabled: true,
        ),
        isTrue,
      );
      expect(
        isLocationAccessBlocked(
          permissionGranted: true,
          serviceEnabled: false,
        ),
        isTrue,
      );
      expect(
        isLocationAccessBlocked(
          permissionGranted: true,
          serviceEnabled: true,
        ),
        isFalse,
      );
    });
  });
}
