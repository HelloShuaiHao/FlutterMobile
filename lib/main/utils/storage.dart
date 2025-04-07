// 本地存储
import 'dart:convert';

import 'package:get_storage/get_storage.dart';


class SpUtil {
  // static const String baseUrlVal = "https://localhost";
  static const String baseUrlVal = "https://localhost:7013/api";
  static var baseUrl = baseUrlVal.val("baseUrl");
  static var token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkFFM0JCRUI3NkEwNkEyN0RBNDYxQTQyQjAyM0E4OTA5QkQyNTRGOUYiLCJ4NXQiOiJyanUtdDJvR29uMmtZYVFyQWpxSkNiMGxUNTgiLCJ0eXAiOiJhdCtqd3QifQ.eyJzdWIiOiJhOGU5MWUwMS0xOTg3LTI1M2MtN2Y1OS0zYTE4OWE1YTdiODEiLCJ1bmlxdWVfbmFtZSI6ImFkbWluIiwib2lfcHJzdCI6IlNpbVRlY2guQXBleF9BcHAiLCJvaV9hdV9pZCI6IjNhMTg5YWY5LTdhODgtYTA0My03NGUyLWE1ZjZkNmE1MWFjZiIsInByZWZlcnJlZF91c2VybmFtZSI6ImFkbWluIiwiZ2l2ZW5fbmFtZSI6ImFkbWluIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBhYnAuaW8iLCJlbWFpbF92ZXJpZmllZCI6IkZhbHNlIiwicGhvbmVfbnVtYmVyX3ZlcmlmaWVkIjoiRmFsc2UiLCJjbGllbnRfaWQiOiJTaW1UZWNoLkFwZXhfQXBwIiwib2lfdGtuX2lkIjoiM2ExOTEyMDQtOTQ3YS00ZmVjLTc3NzItNGI2ODU2MjhiNDljIiwiYXVkIjpbIklkZW50aXR5U2VydmljZSIsIkFkbWluaXN0cmF0aW9uU2VydmljZSIsIlN0b3JhZ2VTZXJ2aWNlIiwiUGFydG5lclNlcnZpY2UiLCJUcmFuc3BvcnRTZXJ2aWNlIiwiRGVsaXZlcnlTZXJ2aWNlIiwiT3JkZXJTZXJ2aWNlIiwiSW52ZW50b3J5U2VydmljZSIsIk1lc3NhZ2luZ1NlcnZpY2UiLCJXb3JrZmxvd1NlcnZpY2UiLCJFbmdpbmVTZXJ2aWNlIiwiSW50ZWdyYXRpb25TZXJ2aWNlIl0sInNjb3BlIjoib3BlbmlkIG9mZmxpbmVfYWNjZXNzIElkZW50aXR5U2VydmljZSBBZG1pbmlzdHJhdGlvblNlcnZpY2UgU3RvcmFnZVNlcnZpY2UgUGFydG5lclNlcnZpY2UgVHJhbnNwb3J0U2VydmljZSBEZWxpdmVyeVNlcnZpY2UgT3JkZXJTZXJ2aWNlIEludmVudG9yeVNlcnZpY2UgTWVzc2FnaW5nU2VydmljZSBXb3JrZmxvd1NlcnZpY2UgRW5naW5lU2VydmljZSBJbnRlZ3JhdGlvblNlcnZpY2UiLCJqdGkiOiJiNzE1YmUzMC1kM2RiLTQyZDgtYjQ3Ny0zYmQwZTNiMGI2ODAiLCJpc3MiOiJodHRwczovL2xvY2FsaG9zdDo3NjAwLyIsImV4cCI6MTc0Mzc1NzY4MywiaWF0IjoxNzQzNzU0MDgzfQ.iLUUvzqh72FNWVhqXkbU-DIq5KiRcvpNEjYWoZAXqcnyYb2vA7QEwAP0kdTHrhKvN5x75nG20mbngBJzaW5aSxWXZbfuqXNPVa5o-2zL70KBfeZznlS0obuGgFIVe1WSCwDEOx7Ql36aljgmJnIuxtr80gSrsvUBYIUSvj613xQ6gLqI85bW2KJOBZe1p_5QwykbSCdmC-DwqrwNpVQWs3irYhkR0o2rYZRi_ljKgHleRicF9wOfW5hW45TDnN8tSnTOD0407IWizcaEkz_FatW3wEbr6quzFeF9C0C6GJxESFp8pLkVMndqDlyO4fMb_MLcj8pKJS3bVwiFzvdgaQ".val("token");

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
