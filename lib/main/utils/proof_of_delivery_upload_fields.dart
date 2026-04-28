Map<String, String> buildProofOfDeliveryPhotoFields({
  required int photoCount,
  required String notes,
  required String timestamp,
}) {
  final description = notes.trim().isNotEmpty ? notes.trim() : 'Delivery photo';
  return {
    for (var index = 0; index < photoCount; index++) ...{
      'Photos[$index].PhotoType': '1',
      'Photos[$index].Description': description,
      'Photos[$index].Timestamp': timestamp,
    },
  };
}
