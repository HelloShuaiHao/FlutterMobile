class Acceptorrejectbidmodel {
  int? orderId;
  String? message;

  Acceptorrejectbidmodel({this.orderId, this.message});

  Acceptorrejectbidmodel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['message'] = this.message;
    return data;
  }
}