

import 'package:mighty_delivery/generated/json/base/json_convert_content.dart';
import 'package:mighty_delivery/main/network/response_entity.dart';

ResponseEntity<T> $ResponseEntityFromJson<T>(Map<String, dynamic> json) {
  final ResponseEntity<T> responseEntity = ResponseEntity();
  final T? body = JsonConvert.fromJsonAsT<T>(json['data']);
  if (body != null) {
    responseEntity.data = body;
  }
 
  final String? message = jsonConvert.convert<String>(json['msg']);
  if (message != null) {
    responseEntity.msg = message;
  }
  final int? code1 = jsonConvert.convert<int>(json['code']);
  if (code1 != null) {
    responseEntity.code = code1;
  }
  
  return responseEntity;
}

Map<String, dynamic> $ResponseEntityToJson(ResponseEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data?.toJson();
  data['msg'] = entity.msg;
  data['code'] = entity.code;
  return data;
}

