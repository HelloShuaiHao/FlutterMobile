
// import 'package:aidati/request/page_data_entity.dart';

// import '../generated/json/base/json_convert_content.dart';

// PageDataEntity $PageDataEntityFromJson(Map<String, dynamic> json) {
//   final PageDataEntity pageDataEntity = PageDataEntity();
//   final int? current = jsonConvert.convert<int>(json['current']);
//   if (current != null) {
//     pageDataEntity.current = current;
//   }
//   final bool? hitCount = jsonConvert.convert<bool>(json['hitCount']);
//   if (hitCount != null) {
//     pageDataEntity.hitCount = hitCount;
//   }
//   final List<dynamic>? orders =
//       jsonConvert.convertListNotNull<dynamic>(json['orders']);
//   if (orders != null) {
//     pageDataEntity.orders = orders;
//   }
//   final int? pages = jsonConvert.convert<int>(json['pages']);
//   if (pages != null) {
//     pageDataEntity.pages = pages;
//   }
//   final List<dynamic>? records =
//       jsonConvert.convertListNotNull<dynamic>(json['records']);
//   if (records != null) {
//     pageDataEntity.records = records;
//   }
//   final bool? searchCount = jsonConvert.convert<bool>(json['searchCount']);
//   if (searchCount != null) {
//     pageDataEntity.searchCount = searchCount;
//   }
//   final int? size = jsonConvert.convert<int>(json['size']);
//   if (size != null) {
//     pageDataEntity.size = size;
//   }
//   final int? total = jsonConvert.convert<int>(json['total']);
//   if (total != null) {
//     pageDataEntity.total = total;
//   }
//   return pageDataEntity;
// }

// Map<String, dynamic> $PageDataEntityToJson(PageDataEntity entity) {
//   final Map<String, dynamic> data = <String, dynamic>{};
//   data['current'] = entity.current;
//   data['hitCount'] = entity.hitCount;
//   data['orders'] = entity.orders;
//   data['pages'] = entity.pages;
//   data['records'] = entity.records;
//   data['searchCount'] = entity.searchCount;
//   data['size'] = entity.size;
//   data['total'] = entity.total;
//   return data;
// }
