import '../../main/models/PaginationModel.dart';

class RewardsListModel {
  List<RewardsModel>? data;
  PaginationModel? pagination;

  RewardsListModel({this.data, this.pagination});

  factory RewardsListModel.fromJson(Map<String, dynamic> json) {
    return RewardsListModel(
      data: json['data'] != null ? (json['data'] as List).map((i) => RewardsModel.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}

class RewardsModel {
  int? id;
  int? userId;
  String? userName;
  String? type;
  String? transactionType;
  String? currency;
  int? amount;
  int? balance;
  int? walletBalance;
  String? datetime;
  int? orderId;
  String? createdAt;
  String? updatedAt;

  RewardsModel({
    this.id,
    this.userId,
    this.userName,
    this.type,
    this.transactionType,
    this.currency,
    this.amount,
    this.balance,
    this.walletBalance,
    this.datetime,
    this.orderId,
    this.createdAt,
    this.updatedAt,
  });

  factory RewardsModel.fromJson(Map<String, dynamic> json) {
    return RewardsModel(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      type: json['type'],
      transactionType: json['transaction_type'],
      currency: json['currency'],
      amount: json['amount'],
      balance: json['balance'],
      walletBalance: json['wallet_balance'],
      datetime: json['datetime'],
      orderId: json['order_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    data['type'] = this.type;
    data['currency'] = this.currency;
    data['amount'] = this.amount;
    data['balance'] = this.balance;
    data['wallet_balance'] = this.walletBalance;
    data['datetime'] = this.datetime;
    data['order_id'] = this.orderId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
