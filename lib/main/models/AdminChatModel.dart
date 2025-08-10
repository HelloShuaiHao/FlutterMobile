import 'PaginationModel.dart';

class AdminChatModel {
  PaginationModel? pagination;
  List<AdminChat>? data;

  AdminChatModel({
    this.pagination,
    this.data,
  });

  factory AdminChatModel.fromJson(Map<String, dynamic> json) => AdminChatModel(
        pagination: json["pagination"] == null ? null : PaginationModel.fromJson(json["pagination"]),
        data: json["data"] == null ? [] : List<AdminChat>.from(json["data"]!.map((x) => AdminChat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination?.toJson(),
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class AdminChat {
  int? id;
  int? userId;
  String? sendBy;
  String? message;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? profileImage;

  AdminChat({
    this.id,
    this.userId,
    this.sendBy,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
  });

  factory AdminChat.fromJson(Map<String, dynamic> json) => AdminChat(
        id: json["id"],
        userId: json["user_id"],
        sendBy: json["send_by"],
        message: json["message"],
        profileImage: json["profile_image"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "send_by": sendBy,
        "message": message,
        "profile_image": profileImage,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
