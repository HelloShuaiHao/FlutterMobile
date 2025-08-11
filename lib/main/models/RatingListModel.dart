class RatingLiModel {
  List<Rating>? rating;

  RatingLiModel({
    this.rating,
  });

  factory RatingLiModel.fromJson(Map<String, dynamic> json) => RatingLiModel(
    rating: json["rating"] == null ? [] : List<Rating>.from(json["rating"]!.map((x) => Rating.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "rating": rating == null ? [] : List<dynamic>.from(rating!.map((x) => x.toJson())),
  };
}

class Rating {
  int? id;
  int? orderId;
  int? StoreId;
  String? productName;
  int? userId;
  String? userName;
  num? rating;
  String? review;
  DateTime? createdAt;
  DateTime? updatedAt;

  Rating({
    this.id,
    this.orderId,
    this.StoreId,
    this.productName,
    this.userId,
    this.userName,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json["id"],
    orderId: json["order_id"],
    StoreId: json["store_id"],
    productName: json["product_name"],
    userId: json["user_id"],
    userName: json["user_name"],
    rating: json["rating"],
    review: json["review"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "store_id": StoreId,
    "product_name": productName,
    "user_id": userId,
    "user_name": userName,
    "rating": rating,
    "review": review,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
