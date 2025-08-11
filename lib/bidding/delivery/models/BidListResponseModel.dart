class BidListResponseModel {
  // Pagination? pagination;
  List<BidListData>? data;

  BidListResponseModel({ this.data});

  BidListResponseModel.fromJson(Map<String, dynamic> json) {
    // pagination = json['pagination'] != null
    //     ? new Pagination.fromJson(json['pagination'])
    //     : null;
    if (json['data'] != null) {
      data = <BidListData>[];
      json['data'].forEach((v) {
        data!.add(new BidListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // if (this.pagination != null) {
    //   data['pagination'] = this.pagination!.toJson();
    // }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pagination {
  int? totalItems;
  int? perPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {this.totalItems, this.perPage, this.currentPage, this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['total_items'];
    perPage = json['per_page'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_items'] = this.totalItems;
    data['per_page'] = this.perPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class BidListData {
  int? id;
  int? orderId;
  num? bidAmount;
  num? totalAmount;
  String? notes;
  int? isBidAccept;
  String? createdAt;
  String? updatedAt;

  BidListData(
      {this.id,
      this.orderId,
      this.bidAmount,
      this.totalAmount,
      this.notes,
      this.isBidAccept,
      this.createdAt,
      this.updatedAt});

  BidListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    bidAmount = json['bid_amount'];
    totalAmount = json['total_amount'];
    notes = json['notes'];
    isBidAccept = json['is_bid_accept'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order_id'] = this.orderId;
    data['bid_amount'] = this.bidAmount;
    data['total_amount'] = this.totalAmount;
    data['notes'] = this.notes;
    data['is_bid_accept'] = this.isBidAccept;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
