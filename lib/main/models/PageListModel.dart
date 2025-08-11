import 'dart:convert';

import 'PaginationModel.dart';

PageListModel pageListModelfromJson(String str) => PageListModel.fromJson(json.decode(str));

String pageListModeltoJson(PageListModel data) => json.encode(data.toJson());

class PageListModel {
  PaginationModel? pagination;
  List<PageData>? data;

  PageListModel({
    this.pagination,
    this.data,
  });

  factory PageListModel.fromJson(Map<String, dynamic> json) => PageListModel(
        pagination: json["pagination"] == null ? null : PaginationModel.fromJson(json["pagination"]),
        data: json["data"] == null ? [] : List<PageData>.from(json["data"]!.map((x) => PageData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pagination": pagination?.toJson(),
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class PageData {
  int? id;
  String? title;
  String? description;
  String? slug;
  int? status;

  PageData({
    this.id,
    this.title,
    this.description,
    this.slug,
    this.status,
  });

  factory PageData.fromJson(Map<String, dynamic> json) => PageData(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        status: json["status"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "status": status,
        "slug": slug,
      };
}
