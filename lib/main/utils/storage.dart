// 本地存储
import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class SpUtil {
  // static const String baseUrlVal = "https://172.20.10.4:7500";
  // static const String baseUrlVal = "https://10.5.58.167:7500";
  // static const String baseUrlVal = "https://ai.bygpu.com:55316";
  // static const String baseUrlVal = "https://localhost:7500";
  // static const String baseUrlVal =
  //     "https://dev-apex-01.southeastasia.cloudapp.azure.com:7500";
  static const String baseUrlVal = "https://uat.simtech-sul.com:7500";
  static var baseUrl = baseUrlVal.val("baseUrl");

  // static const String baseAuthUrlVal = "https://172.20.10.4:7500";
  // static const String baseAuthUrlVal = "https://10.5.58.167:7600";
  // static const String baseAuthUrlVal = "https://localhost:7500";
  // static const String baseAuthUrlVal = "https://ai.bygpu.com:55316";
  // static const String baseAuthUrlVal =
  //     "https://dev-apex-01.southeastasia.cloudapp.azure.com:7600";
  static const String baseAuthUrlVal = "https://uat.simtech-sul.com:7600";
  static var baseAuthUrl = baseAuthUrlVal.val("baseAuthUrl");

  static var token = "".val("token");
  static var refresh_token = "".val("refresh_token");

  static var hasShownPermissionDialog =
      false.val("has_shown_permission_dialog");
  static var hasShownScanPermissionDialog =
      false.val("has_shown_scan_permission_dialog");

  static setJSON(String key, dynamic value) {
    GetStorage().write(key, jsonEncode(value));
  }

  static getJSON(String key) {
    final value = GetStorage().read(key);
    if (value == null) return null;
    return jsonDecode(value);
  }

  static remove(String key) {
    GetStorage().remove(key);
  }
}
