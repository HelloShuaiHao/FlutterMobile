import 'PaginationModel.dart';

class CustomerSupportListModel {
  PaginationModel? pagination;
  List<CustomerSupport>? customerSupport;

  CustomerSupportListModel({
    this.pagination,
    this.customerSupport,
  });

  factory CustomerSupportListModel.fromJson(Map<String, dynamic> json) => CustomerSupportListModel(
        pagination: json["pagination"] == null ? null : PaginationModel.fromJson(json["pagination"]),
        customerSupport: json["customersupport"] == null
            ? []
            : List<CustomerSupport>.from(json["customersupport"]!.map((x) => CustomerSupport.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.customerSupport != null) {
      data['customersupport'] = this.customerSupport!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerSupport {
  int? supportId;
  int? userId;
  String? userName;
  String? supportType;
  String? message;
  String? resolutionDetail;
  String? status;
  String? image;
  String? video;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<SupportChatHistory>? supportChatHistory;

  CustomerSupport({
    this.supportId,
    this.userId,
    this.userName,
    this.supportType,
    this.message,
    this.resolutionDetail,
    this.status,
    this.image,
    this.video,
    this.createdAt,
    this.updatedAt,
    this.supportChatHistory,
  });

  factory CustomerSupport.fromJson(Map<String, dynamic> json) => CustomerSupport(
        supportId: json["support_id"],
        userId: json["user_id"],
        userName: json["user_name"],
        supportType: json["support_type"],
        message: json["message"],
        resolutionDetail: json["resolution_detail"],
        status: json["status"],
        image: json["support_image"] == null ? null : json["support_image"],
        video: json["support_videos"] == null ? null : json["support_videos"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        supportChatHistory: json["supportchathistory"] == null
            ? null
            : List<SupportChatHistory>.from(json["supportchathistory"]!.map((x) => SupportChatHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "support_id": supportId,
        "user_id": userId,
        "user_name": userName,
        "support_type": supportType,
        "message": message,
        "resolution_detail": resolutionDetail,
        "status": status,
        "stasupport_imagetus": image,
        "support_videos": video,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "supportchathistory": supportChatHistory == null
            ? null
            : List<SupportChatHistory>.from(supportChatHistory!.map((x) => x.toJson())),
      };
}

class SupportChatHistory {
  String? sendBy;
  String? message;
  String? datetime;

  SupportChatHistory({
    required this.sendBy,
    required this.message,
    required this.datetime,
  });
  SupportChatHistory.fromJson(Map<String, dynamic> json) {
    sendBy = json['send_by'];
    message = json['message'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['send_by'] = this.sendBy;
    data['message'] = this.message;
    data['datetime'] = this.datetime;

    return data;
  }
}
