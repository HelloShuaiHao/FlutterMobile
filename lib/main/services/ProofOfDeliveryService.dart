import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';

class ProofOfDeliveryService {
  static const String _uploadPath = '/api/delivery/proof-of-delivery/upload';

  Future<void> uploadProofOfDelivery({
    required String taskHeaderId,
    required String photoPath,
    required Uint8List signatureBytes,
    String? notes,
  }) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final finalNotes = (notes ?? '').trim();

    final formData = FormData.fromMap({
      'TaskHeaderId': taskHeaderId,
      'Notes': finalNotes,
      'TimeStamp': nowUtc,
      'SignatureFile': MultipartFile.fromBytes(
        signatureBytes,
        filename: 'signature-$taskHeaderId.png',
      ),
      'Photos[0].PhotoFile': await MultipartFile.fromFile(
        photoPath,
        filename: File(photoPath).uri.pathSegments.last,
      ),
      'Photos[0].PhotoType': '1',
      'Photos[0].Description':
          finalNotes.isNotEmpty ? finalNotes : 'Delivery photo',
      'Photos[0].Timestamp': nowUtc,
    });

    await HttpUtils.dio.post(
      _uploadPath,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }
}
