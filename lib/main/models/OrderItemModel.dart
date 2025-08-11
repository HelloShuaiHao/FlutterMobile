class OrderItemModel {
  num? amount;
  var orderId;
  int? productId;
  int? quantity;

  OrderItemModel({this.amount, this.orderId, this.productId, this.quantity});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      amount: json['amount'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['order_id'] = this.orderId;
    data['product_id'] = this.productId;
    data['quantity'] = this.quantity;
    return data;
  }
}