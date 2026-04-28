import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/proof_of_delivery_upload_fields.dart';

class ProofOfDeliveryService {
  static const String _uploadPath = '/api/delivery/proof-of-delivery/upload';

  Future<void> uploadProofOfDelivery({
    required String taskHeaderId,
    String? photoPath,
    List<String>? photoPaths,
    required Uint8List signatureBytes,
    String? notes,
  }) async {
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final finalNotes = (notes ?? '').trim();
    final photos = [
      ...?photoPaths,
      if ((photoPaths == null || photoPaths.isEmpty) && photoPath != null)
        photoPath,
    ];

    if (photos.isEmpty) {
      throw ArgumentError('At least one proof-of-delivery photo is required');
    }

    final formData = FormData.fromMap({
      'TaskHeaderId': taskHeaderId,
      'Notes': finalNotes,
      'TimeStamp': nowUtc,
      'SignatureFile': MultipartFile.fromBytes(
        signatureBytes,
        filename: 'signature-$taskHeaderId.png',
      ),
      ...buildProofOfDeliveryPhotoFields(
        photoCount: photos.length,
        notes: finalNotes,
        timestamp: nowUtc,
      ),
      for (var index = 0; index < photos.length; index++)
        'Photos[$index].PhotoFile': await MultipartFile.fromFile(
          photos[index],
          filename: File(photos[index]).uri.pathSegments.last,
        ),
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
