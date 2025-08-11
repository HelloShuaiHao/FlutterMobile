class BidResponse {
  bool? success;
  List<Data>? data;
  String? startAddress;
  String? endAddress;

  BidResponse({this.success, this.data, this.startAddress, this.endAddress});

  BidResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    startAddress = json['start_address'];
    endAddress = json['end_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['start_address'] = this.startAddress;
    data['end_address'] = this.endAddress;
    return data;
  }
}

class Data {
  int? deliveryManId;
  num? bidAmount;
  String? notes;
  String? deliveryManName;
  String? deliveryManImage;
  int? isBidAccept;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.deliveryManId,
      this.bidAmount,
      this.notes,
      this.isBidAccept,
      this.deliveryManImage,
      this.deliveryManName,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    deliveryManId = json['delivery_man_id'];
    deliveryManName = json['delivery_man_name'];
    bidAmount = json['bid_amount'];
    notes = json['notes'];
    isBidAccept = json['is_bid_accept'];
    deliveryManImage = json['profile_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['delivery_man_id'] = this.deliveryManId;
    data['delivery_man_name'] = this.deliveryManName;
    data['bid_amount'] = this.bidAmount;
    data['notes'] = this.notes;
    data['is_bid_accept'] = this.isBidAccept;
    data['profile_image'] = this.deliveryManImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
