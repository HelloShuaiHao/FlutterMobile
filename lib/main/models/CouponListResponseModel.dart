class CouponListResponseModel {
  int? status;
  Pagination? pagination;
  List<CouponModel>? data;

  CouponListResponseModel({this.status, this.pagination, this.data});

  CouponListResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
    if (json['data'] != null) {
      data = <CouponModel>[];
      json['data'].forEach((v) {
        data!.add(new CouponModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
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

class CouponModel {
  int? id;
  String? couponCode;
  String? startDate;
  String? endDate;
  String? valueType;
  int? discountAmount;
  String? cityType;
  Null? cityId;
  int? status;
  String? createdAt;
  String? updatedAt;
  Null? deletedAt;

  CouponModel(
      {this.id,
      this.couponCode,
      this.startDate,
      this.endDate,
      this.valueType,
      this.discountAmount,
      this.cityType,
      this.cityId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  CouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    couponCode = json['coupon_code'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    valueType = json['value_type'];
    discountAmount = json['discount_amount'];
    cityType = json['city_type'];
    cityId = json['city_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['coupon_code'] = this.couponCode;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['value_type'] = this.valueType;
    data['discount_amount'] = this.discountAmount;
    data['city_type'] = this.cityType;
    data['city_id'] = this.cityId;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}
