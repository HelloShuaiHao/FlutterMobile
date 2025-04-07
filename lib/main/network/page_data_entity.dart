// import 'dart:convert';

// import 'package:aidati/request/page_data_entity.g.dart';

// import '../generated/json/base/json_convert_content.dart';

// class PageDataEntity {
//   late int current;
//   late bool hitCount;
//   late List<dynamic> orders;
//   late int pages;
//   late List<dynamic> records;
//   late bool searchCount;
//   late int size;
//   late int total;

//   PageDataEntity();

//   factory PageDataEntity.fromJson(Map<String, dynamic> json) =>
//       $PageDataEntityFromJson(json);

//   Map<String, dynamic> toJson() => $PageDataEntityToJson(this);

//   List<T> getBeans<T>() {
//     return jsonConvert.convertListNotNull<T>(records) ?? [];
//   }

//   @override
//   String toString() {
//     return jsonEncode(this);
//   }
// }
