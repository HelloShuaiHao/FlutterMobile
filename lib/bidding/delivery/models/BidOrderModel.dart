class BidOrderModel {
  String paymentType;
  List<int> deliveryManIds;
  List<int> acceptedDeliveryManIds = [];
  int orderHasBids;
  String paymentStatus;
  String clientImage;
  String createdAt;
  String clientName;
  String clientEmail;
  int orderId;
  int clientId;
  int isListening;
  String status;

  BidOrderModel({
    required this.paymentType,
    required this.deliveryManIds,
    required this.acceptedDeliveryManIds,
    required this.orderHasBids,
    required this.paymentStatus,
    required this.clientImage,
    required this.createdAt,
    required this.clientName,
    required this.clientEmail,
    required this.orderId,
    required this.isListening,
    required this.clientId,
    required this.status,
  });

  factory BidOrderModel.fromJson(Map<String, dynamic> json) {
    return BidOrderModel(
      paymentType: json['payment_type'] ?? '',
      deliveryManIds: List<int>.from(json['all_delivery_man_ids'] ?? []),
      acceptedDeliveryManIds:
          List<int>.from(json['accepted_delivery_man_ids'] ?? []),
      orderHasBids: json['order_has_bids'] ?? 0,
      paymentStatus: json['payment_status'] ?? '',
      clientName: json['client_name'] ?? '',
      clientImage: json['client_image'] ?? '',
      clientEmail: json['client_email'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toString(),
      orderId: json['order_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      isListening: json['delivery_man_lisnig'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_type': paymentType,
      'all_delivery_man_ids': deliveryManIds,
      'accepted_delivery_man_ids': acceptedDeliveryManIds,
      'order_has_bids': orderHasBids,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'client_image': clientImage,
      'client_name': clientName,
      'client_email': clientEmail,
      'delivery_man_lisnig': isListening,
      'order_id': orderId,
      'client_id': clientId,
      'status': status,
    };
  }
}
