import 'PaginationModel.dart';

class ClaimListResponseModel {
  PaginationModel? pagination;
  List<ClaimItem>? data;

  ClaimListResponseModel({this.pagination, this.data});

  ClaimListResponseModel.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? new PaginationModel.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      data = <ClaimItem>[];
      json['data'].forEach((v) {
        data!.add(new ClaimItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class ClaimItem {
  int? id;
  int? clientId;
  String? clientName;
  String? trakingNo;
  String? profValue;
  String? detail;
  String? status;
  List<String>? attachmentFile;
  List<ClaimsHistory>? claimsHistory;
  String? createdAt;
  String? updatedAt;

  ClaimItem(
      {this.id,
      this.clientId,
      this.clientName,
      this.trakingNo,
      this.profValue,
      this.detail,
      this.status,
      this.attachmentFile,
        this.claimsHistory,
      this.createdAt,
      this.updatedAt});

  ClaimItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['client_id'];
    clientName = json['client_name'];
    trakingNo = json['traking_no'];
    profValue = json['prof_value'];
    detail = json['detail'];
    status = json['status'];
    attachmentFile = json['attachment_file'].cast<String>();
    claimsHistory= json["claims_history"] == null ? [] : List<ClaimsHistory>.from(json["claims_history"]!.map((x) => ClaimsHistory.fromJson(x)));
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['client_id'] = this.clientId;
    data['client_name'] = this.clientName;
    data['traking_no'] = this.trakingNo;
    data['prof_value'] = this.profValue;
    data['detail'] = this.detail;
    data['status'] = this.status;
    data['attachment_file'] = this.attachmentFile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class ClaimsHistory {
  int? id;
  int? claimId;
  int? amount;
  String? description;
  List<dynamic>? attachmentFile;
  DateTime? createdAt;
  DateTime? updatedAt;

  ClaimsHistory({
    this.id,
    this.claimId,
    this.amount,
    this.description,
    this.attachmentFile,
    this.createdAt,
    this.updatedAt,
  });

  factory ClaimsHistory.fromJson(Map<String, dynamic> json) => ClaimsHistory(
    id: json["id"],
    claimId: json["claim_id"],
    amount: json["amount"],
    description: json["description"],
    attachmentFile: json["attachment_file"] == null ? [] : List<dynamic>.from(json["attachment_file"]!.map((x) => x)),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "claim_id": claimId,
    "amount": amount,
    "description": description,
    "attachment_file": attachmentFile == null ? [] : List<dynamic>.from(attachmentFile!.map((x) => x)),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}