import 'dart:convert';

import 'package:mighty_delivery/main/network/response_entity.g.dart';

//{'code': 200, 'msg': 'success', 'data':{xxx,xxx}}
class ResponseEntity<T> {
  T? data;
  String? msg;
  int? code;

  ResponseEntity();

  factory ResponseEntity.fromJson(Map<String, dynamic> json) =>
      $ResponseEntityFromJson(json);

  Map<String, dynamic> toJson() => $ResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
