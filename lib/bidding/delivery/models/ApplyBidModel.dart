class Applybidmodel {
  int? id;
  int? orderId;
  num? bidAmount;
  String? notes;
  String? message;

  Applybidmodel({this.orderId, this.bidAmount, this.notes, this.message});

  Applybidmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    bidAmount = json['bid_amount'];
    notes = json['notes'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['bid_amount'] = this.bidAmount;
    data['notes'] = this.notes;
    data['message'] = this.message;
    return data;
  }
}
