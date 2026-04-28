import 'package:flutter_test/flutter_test.dart';
import 'package:mighty_delivery/main/utils/proof_of_delivery_upload_fields.dart';

void main() {
  group('proof of delivery upload fields', () {
    test('creates indexed metadata for every selected photo', () {
      final fields = buildProofOfDeliveryPhotoFields(
        photoCount: 3,
        notes: 'Left at reception',
        timestamp: '2026-04-11T15:50:00.000Z',
      );

      expect(fields['Photos[0].PhotoType'], '1');
      expect(fields['Photos[1].PhotoType'], '1');
      expect(fields['Photos[2].PhotoType'], '1');
      expect(fields['Photos[0].Description'], 'Left at reception');
      expect(fields['Photos[1].Timestamp'], '2026-04-11T15:50:00.000Z');
      expect(fields.containsKey('Photos[3].PhotoType'), isFalse);
    });
  });
}
