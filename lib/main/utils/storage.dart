// 本地存储
import 'dart:convert';

import 'package:get_storage/get_storage.dart';


class SpUtil {
  // static const String baseUrlVal = "https://localhost";
  static const String baseUrlVal = "https://localhost:7013/api";
  static var baseUrl = baseUrlVal.val("baseUrl");
  static var token = "".val("token");

  static var hasShownPermissionDialog = false.val("has_shown_permission_dialog");
  static var hasShownScanPermissionDialog = false.val("has_shown_scan_permission_dialog");


  static setJSON(String key, dynamic value) {
    GetStorage().write(key, jsonEncode(value));
  }

  static getJSON(String key) {
    return jsonDecode(GetStorage().read(key));
  }

  static remove(String key){
    GetStorage().remove(key);
  }

  // static LoginResultEntity? getUser(){
  //   var user = jsonConvert.convert<LoginResultEntity>(getJSON(SPConstant.USERINFO));
  //   return user;
  // }

  // static setUser(LoginResultEntity entity){
  //   SpUtil.token.val = entity.token;
  //   SpUtil.setJSON(SPConstant.USERINFO, entity);
  // }

  // static isDebugMode(){
  //   return SpUtil.baseUrl.val == SpUtil.baseUrlValDebug;
  // }
}
