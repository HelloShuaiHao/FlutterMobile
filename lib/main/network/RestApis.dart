import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/services/LocationTrackingService.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/ClaimListResponseModel.dart';
import '../../main/models/DashboardCountModel.dart';
import '../../main/models/PageListModel.dart';
import '../../main/models/ReferralHistoryListModel.dart';
import '../../main/models/rewardsListModel.dart';

import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../languageConfiguration/ServerLanguageResponse.dart';
import '../../main.dart';
import '../../main/models/ChangePasswordResponse.dart';
import '../../main/models/CityDetailModel.dart';
import '../../main/models/CityListModel.dart';
import '../../main/models/CountryDetailModel.dart';
import '../../main/models/CountryListModel.dart';
import '../../main/models/DeliveryDocumentListModel.dart';
import '../../main/models/DocumentListModel.dart';
import '../../main/models/LDBaseResponse.dart';
import '../../main/models/LoginResponse.dart';
import '../../main/models/NotificationModel.dart';
import '../../main/models/OrderListModel.dart';
import '../../main/models/ParcelTypeListModel.dart';
import '../../main/models/PaymentGatewayListModel.dart';
import '../../main/screens/LoginScreen.dart';
import '../../main/utils/Constants.dart';
import '../models/AddressListModel.dart';
import '../models/AdminChatModel.dart';
import '../models/AppSettingModel.dart';
import '../models/AutoCompletePlacesListModel.dart';
import '../models/CouponListResponseModel.dart';
import '../models/CreateOrderDetailModel.dart';
import '../models/CustomerSupportModel.dart';
import '../models/DeliverymanVehicleListModel.dart';
import '../models/DirectionsResponse.dart';
import '../models/InvoiceSettingModel.dart';
import '../models/OrderDetailModel.dart';
import '../models/OrderRescheduleResponse.dart';
import '../models/OrdersLatLngResponseList.dart';
import '../models/PageResponse.dart';
import '../models/TotalAmountResponse.dart';
import '../models/UserProfileDetailModel.dart';
import '../models/VehicleModel.dart';
import '../models/WalletListModel.dart';
import '../models/WithDrawListModel.dart';
import 'NetworkUtils.dart';

//region Auth
Future<LoginResponse> signUpApi(Map request) async {
  Response response = await buildHttpResponse('new-register',
      request: request, method: HttpMethod.POST);

  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<LoginResponse> logInApi(Map request,
    {bool isSocialLogin = false}) async {
  // 构建 HTTP 请求
  Response response = await buildHttpResponse(
      isSocialLogin ? 'new-socialLogin' : 'new-login',
      request: request,
      method: HttpMethod.POST);

  // 检查响应状态码是否成功
  if (!response.statusCode.isSuccessful()) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  // 处理响应并返回 LoginResponse 对象
  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);

    // 设置用户相关的值到本地存储
    await setValue(USER_ID, loginResponse.data!.id.validate());
    await setValue(NAME, loginResponse.data!.name.validate());
    await setValue(USER_EMAIL, loginResponse.data!.email.validate());
    await setValue(USER_TOKEN, loginResponse.data!.apiToken.validate());
    await setValue(
        USER_CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
    await setValue(USER_TYPE, loginResponse.data!.userType.validate());
    await setValue(USER_NAME, loginResponse.data!.username.validate());
    await setValue(STATUS, loginResponse.data!.status.validate());
    await setValue(USER_ADDRESS, loginResponse.data!.address.validate());
    await setValue(COUNTRY_ID, loginResponse.data!.countryId.validate());
    await setValue(CITY_ID, loginResponse.data!.cityId.validate());
    await setValue(OTP_VERIFIED, loginResponse.data!.otpVerifyAt != null);
    await setValue(EMAIL_VERIFIED, loginResponse.data!.emailVerifiedAt != null);

    appStore.setUserProfile(loginResponse.data!.profileImage.validate());

    // 获取用户详细信息
    await userService
        .getUser(email: loginResponse.data!.email.validate())
        .then((value) async {
      log(value.toString());
      //  await setValue(UID, value.uid.validate());
    }).catchError((e) {
      log(e.toString());
      print("---------------${loginResponse.data!.loginType}");
      if (loginResponse.data!.loginType == LoginTypeGoogle ||
          loginResponse.data!.loginType == LoginTypeApple) {
      } else if (e.toString() == "User not found") {
        // toast("-----------------user not found");

        // if(loginResponse.data!.loginType == )
        authService.registerUserWithDB(loginResponse.data!.email.validate(),
            request["password"], loginResponse);
        // toast(language.userNotFound);
      }
    });
    await setValue(IS_VERIFIED_DELIVERY_MAN,
        !loginResponse.data!.documentVerifiedAt.isEmptyOrNull);
    await appStore.setUserEmail(loginResponse.data!.email.validate());
    if (getIntAsync(STATUS) == 1) {
      await appStore.setLogin(true);
    } else {
      await appStore.setLogin(false);
    }

    // if (!isSocialLogin) await setValue(USER_PASSWORD, request['password']);

    return loginResponse;
  }).catchError((e) {
    log(e.toString());
    throw e.toString();
  });
}

Future<void> logout(BuildContext context,
    {bool isFromLogin = false,
    bool isDeleteAccount = false,
    bool isVerification = false}) async {
  clearData() async {
    SpUtil.token.val = '';
    // await HttpUtils.init(unAuthHandle: () {});

    await removeKey(USER_ID);
    await removeKey(NAME);
    await removeKey(USER_TOKEN);
    await removeKey(USER_CONTACT_NUMBER);
    await removeKey(USER_PROFILE_PHOTO);
    await removeKey(USER_TYPE);
    await removeKey(USER_NAME);
    await removeKey(USER_ADDRESS);
    await removeKey(STATUS);
    await removeKey(COUNTRY_ID);
    await removeKey(COUNTRY_DATA);
    await removeKey(VEHICLE);
    await removeKey(CITY_ID);
    await removeKey(CITY_DATA);
    await removeKey(FILTER_DATA);
    await removeKey(IS_VERIFIED_DELIVERY_MAN);
    await removeKey(OTP_VERIFIED);
    await removeKey(EMAIL_VERIFIED);
    await removeKey(UID);
    await removeKey(LOGIN_TYPE);

    // 清除 vehicleId（重要：防止登出后继续上传位置）
    await LocationTrackingService.instance.stopTracking();
    SpUtil.remove("vehicleId");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vehicleId');
    await prefs.remove(USER_TOKEN);
    await prefs.setBool(IS_LOGGED_IN, false);

    // 清除密码（除非勾选了"记住我"）
    // 注意：USER_EMAIL 不在这里清除，因为需要在登录时重新设置
    if (!getBoolAsync(REMEMBER_ME)) {
      await removeKey(USER_EMAIL);
      await removeKey(USER_PASSWORD);
    }

    await appStore.setLogin(false);
    appStore.setFiltering(false);
    appStore.setUserProfile('');
    appStore.setUserEmail('');
    if (isFromLogin) {
      // toast(language.credentialNotMatch); comment this because show popup before logout
    } else {
      LoginScreen().launch(context, isNewTask: true);
    }
    if (isVerification) {
      LoginScreen().launch(context, isNewTask: true);
    }
  }

  if (getStringAsync(USER_TYPE) == DELIVERY_MAN &&
      !isVerification &&
      positionStream != null) {
    positionStream!.cancel();
  }
  if (isDeleteAccount) {
    clearData();
  } else if (isVerification) {
    clearData();
    LoginScreen().launch(context, isNewTask: true);
  } else {
    appStore.setLoading(true);
    clearData();
    appStore.setLoading(false);
    // await logoutApi().then((value) async {
    //   clearData();
    //   appStore.setLoading(false);
    // }).catchError((e) {
    //   appStore.setLoading(false);
    //   throw e.toString();
    // });
  }
}

Future<ChangePasswordResponseModel> changePassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('change-password',
          request: req, method: HttpMethod.POST)));
}

Future<ChangePasswordResponseModel> forgotPassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('new-forget-password',
          request: req, method: HttpMethod.POST)));
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  try {
    multiPartRequest.headers.addAll(buildHeaderTokens());
    final streamedResponse = await multiPartRequest.send();
    log(streamedResponse.statusCode.toString());
    final responseBody =
        await streamedResponse.stream.transform(utf8.decoder).join();
    log("Response Body: $responseBody");
    try {
      final decodedResponse = jsonDecode(responseBody);
      onSuccess?.call(decodedResponse);
    } catch (e) {
      // Handle JSON decoding error
      log("Failed to decode JSON: $e");
      onError?.call("Failed to decode response");
    }
  } catch (error) {
    // Catch network or other errors and pass them to onError
    log("Error in sending request: $error");
    onError?.call(error.toString());
  }
}

/// Profile Update

Future<UserData> getUserDetail(int id) async {
  // 禁用实际的 API 调用，直接返回空数据或 mock 数据
  print('getUserDetail API call disabled.');
  return UserData(); // 或填充你需要的 mock 字段
}

/// Create Order Api
Future<LDBaseResponse> createOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteOrder(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('order-delete/$id', method: HttpMethod.POST)));
}

Future<OrderDetailModel> getOrderDetails(int id) async {
  return OrderDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('order-detail?id=$id', method: HttpMethod.GET)));
}

/// ParcelType Api
Future<ParcelTypeListModel> getParcelTypeList({int? page}) async {
  return ParcelTypeListModel.fromJson(await handleResponse(
      await buildHttpResponse('staticdata-list?type=parcel_type&per_page=-1',
          method: HttpMethod.GET)));
}

Future<CountryListModel> getCountryList() async {
  return CountryListModel.fromJson(await handleResponse(await buildHttpResponse(
      'country-list?per_page=-1',
      method: HttpMethod.GET)));
}

Future<CountryDetailModel> getCountryDetail(int id) async {
  return CountryDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('country-detail?id=$id',
          method: HttpMethod.GET)));
}

Future<CityListModel> getCityList(
    {required int countryId, String? name}) async {
  return CityListModel.fromJson(await handleResponse(await buildHttpResponse(
      name != null
          ? 'city-list?country_id=$countryId&search=$name&per_page=-1'
          : 'city-list?country_id=$countryId&per_page=-1',
      method: HttpMethod.GET)));
}

Future<CityDetailModel> getCityDetail(int id) async {
  return CityDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('city-detail?id=$id', method: HttpMethod.GET)));
}

///Vehicle
Future<VehicleListModel> getVehicleList(
    {String? type,
    int? perPage,
    int? page,
    int? cityID,
    bool isDeleted = false,
    int? totalItem,
    int? totalPage = 10}) async {
  if (cityID != null) {
    return VehicleListModel.fromJson(await handleResponse(
        await buildHttpResponse(
            'vehicle-list?city_id=$cityID&per_page=-1&status=1',
            method: HttpMethod.GET)));
  } else {
    return VehicleListModel.fromJson(await handleResponse(
        await buildHttpResponse('vehicle-list?per_page=-1',
            method: HttpMethod.GET)));
  }
}

/// get OrderList
Future<OrderListModel> getOrderList(
    {required int page,
    String? orderStatus,
    String? fromDate,
    String? toDate,
    String? excludeStatus}) async {
  String endPoint =
      'order-list?client_id=${getIntAsync(USER_ID)}&city_id=${getIntAsync(CITY_ID)}&page=$page';

  if (orderStatus.validate().isNotEmpty) {
    endPoint += '&status=$orderStatus';
  }

  if (excludeStatus.validate().isNotEmpty) {
    endPoint += '&exclude_status=$excludeStatus';
  }

  if (fromDate.validate().isNotEmpty && toDate.validate().isNotEmpty) {
    endPoint +=
        '&from_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate.validate()))}&to_date=${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate.validate()))}';
  }

  return OrderListModel.fromJson(await handleResponse(
      await buildHttpResponse(endPoint, method: HttpMethod.GET)));
}

/// get deliveryBoy orderList
Future<OrderListModel> getDeliveryBoyOrderList(
    {required int page,
    required int deliveryBoyID,
    required int countryId,
    required int cityId,
    required String orderStatus}) async {
  return OrderListModel.fromJson(await handleResponse(await buildHttpResponse(
      'order-list?delivery_man_id=$deliveryBoyID&page=$page&city_id=$cityId&country_id=$countryId&status=$orderStatus',
      method: HttpMethod.GET)));
}

/// update status
Future updateStatus({String? orderStatus, int? orderId}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('order-update/$orderId');
  multiPartRequest.fields['status'] = orderStatus.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

/// update order
Future updateOrder(
    {String? pickupDatetime,
    String? deliveryDatetime,
    String? clientName,
    String? deliveryman,
    String? orderStatus,
    String? reason,
    int? orderId,
    File? picUpSignature,
    File? deliverySignature,
    List<File>? selectedFiles}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('order-update/$orderId');
  if (pickupDatetime != null)
    multiPartRequest.fields['pickup_datetime'] = pickupDatetime;
  if (deliveryDatetime != null)
    multiPartRequest.fields['delivery_datetime'] = deliveryDatetime;
  if (clientName != null)
    multiPartRequest.fields['pickup_confirm_by_client'] = clientName;
  if (deliveryman != null)
    multiPartRequest.fields['pickup_confirm_by_delivery_man'] = deliveryman;
  if (reason != null) multiPartRequest.fields['reason'] = reason;
  if (orderStatus != null) multiPartRequest.fields['status'] = orderStatus;

  if (picUpSignature != null)
    multiPartRequest.files.add(await MultipartFile.fromPath(
        'pickup_time_signature', picUpSignature.path));
  if (deliverySignature != null)
    multiPartRequest.files.add(await MultipartFile.fromPath(
        'delivery_time_signature', deliverySignature.path));

  if (selectedFiles != null) {
    for (var file in selectedFiles) {
      if (file.path.isNotEmpty) {
        multiPartRequest.files
            .add(await MultipartFile.fromPath('prof_file[]', file.path));
      }
    }
  }
  print("==> ${multiPartRequest.toString()}");
  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<PaymentGatewayListModel> getPaymentGatewayList() async {
  return PaymentGatewayListModel.fromJson(await handleResponse(
      await buildHttpResponse('paymentgateway-list?status=1',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> savePayment(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'payment-save',
      request: request,
      method: HttpMethod.POST)));
}

Future<WithDrawListModel> getWithDrawList({int? page}) async {
  return WithDrawListModel.fromJson(await handleResponse(
      await buildHttpResponse('withdrawrequest-list?page=$page',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWithDrawRequest(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-withdrawrequest',
      method: HttpMethod.POST,
      request: request)));
}

/// Get Notification List
Future<NotificationListModel> getNotification(
    {required int page, Map? request}) async {
  if (request != null) {
    return NotificationListModel.fromJson(await handleResponse(
        await buildHttpResponse('notification-list?limit=20&page=$page',
            request: request, method: HttpMethod.POST)));
  } else {
    return NotificationListModel.fromJson(await handleResponse(
        await buildHttpResponse('notification-list?limit=20&page=$page',
            method: HttpMethod.POST)));
  }
}

/// Get Document List
Future<DocumentListModel> getDocumentList({int? page}) async {
  return DocumentListModel.fromJson(await handleResponse(
      await buildHttpResponse('document-list?status=1&per_page=-1',
          method: HttpMethod.GET)));
}

/// Get Delivery Document List
Future<DeliveryDocumentListModel> getDeliveryPersonDocumentList(
    {int? page}) async {
  return DeliveryDocumentListModel.fromJson(await handleResponse(
      await buildHttpResponse('delivery-man-document-list?per_page=-1',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteDeliveryDoc(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'delivery-man-document-delete/$id',
      method: HttpMethod.POST)));
}

/// App Setting
Future<AppSettingModel> getAppSetting() async {
  return AppSettingModel.fromJson(await handleResponse(
      await buildHttpResponse('get-appsetting', method: HttpMethod.GET)));
}

/// Cancel AutoAssign order
Future<LDBaseResponse> cancelAutoAssignOrder(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'order-auto-assign',
      request: request,
      method: HttpMethod.POST)));
}

Future<AutoCompletePlacesListModel> placeAutoCompleteApi(
    {String searchText = '',
    String countryCode = "in",
    String language = 'en'}) async {
  return AutoCompletePlacesListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'place-autocomplete-api?country_code=$countryCode&language=$language&search_text=$searchText',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> deleteUser(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'delete-user',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> userAction(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'user-forceDelete',
      request: request,
      method: HttpMethod.POST)));
}

Future<WalletListModel> getWalletList({required int page}) async {
  return WalletListModel.fromJson(await handleResponse(await buildHttpResponse(
      'wallet-list?page=$page',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWallet(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-wallet',
      method: HttpMethod.POST,
      request: request)));
}

/// Update Bank Info
Future updateBankDetail(
    {String? bankName,
    String? bankCode,
    String? accountName,
    String? accountNumber,
    String? bankAddress,
    String? routingNumber,
    String? bankIban,
    String? bankSwift}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
  multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] =
      getStringAsync(USER_CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] = getStringAsync(USER_NAME).validate();
  multiPartRequest.fields['user_bank_account[bank_name]'] = bankName.validate();
  multiPartRequest.fields['user_bank_account[bank_code]'] = bankCode.validate();
  multiPartRequest.fields['user_bank_account[account_holder_name]'] =
      accountName.validate();
  multiPartRequest.fields['user_bank_account[account_number]'] =
      accountNumber.validate();
  multiPartRequest.fields['user_bank_account[bank_address]'] =
      bankAddress.validate();
  multiPartRequest.fields['user_bank_account[routing_number]'] =
      routingNumber.validate();
  multiPartRequest.fields['user_bank_account[bank_iban]'] = bankIban.validate();
  multiPartRequest.fields['user_bank_account[bank_swift]'] =
      bankSwift.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'logout?clear=player_id',
      method: HttpMethod.GET)));
}

Future<EarningList> getPaymentList({required int page}) async {
  return EarningList.fromJson(await handleResponse(await buildHttpResponse(
      'payment-list?page=$page&delivery_man_id=${getIntAsync(USER_ID)}&type=earning',
      method: HttpMethod.GET)));
}

Future<UserProfileDetailModel> getUserProfile() async {
  return UserProfileDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('user-profile-detail?id=${getIntAsync(USER_ID)}',
          method: HttpMethod.GET)));
}

Future<InvoiceSettingModel> getInvoiceSetting() async {
  return InvoiceSettingModel.fromJson(await handleResponse(
      await buildHttpResponse('get-setting', method: HttpMethod.GET)));
}

Future<LDBaseResponse> updateUserStatus(Map req) async {
  // 禁用实际的 API 调用，直接返回 mock 数据
  print('updateUserStatus API call disabled.');
  return LDBaseResponse(); // 或填充你需要的 mock 字段
}

Future updateUid(String? uid) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
  multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL).validate();
  multiPartRequest.fields['username'] = getStringAsync(USER_NAME).validate();
  multiPartRequest.fields['uid'] = uid.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    log(error.toString());
  });
}

Future updatePlayerId() async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = getIntAsync(USER_ID).toString();
  multiPartRequest.fields['email'] = getStringAsync(USER_EMAIL).validate();
  multiPartRequest.fields['username'] = getStringAsync(USER_NAME).validate();
  multiPartRequest.fields['player_id'] = getStringAsync(PLAYER_ID);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    log(error.toString());
  });
}

Future<AddressListModel> getAddressList({int? page}) async {
  return AddressListModel.fromJson(await handleResponse(await buildHttpResponse(
      page != null
          ? 'useraddress-list?page=$page&user_id=${getIntAsync(USER_ID)}&city_id=${getIntAsync(CITY_ID)}'
          : 'useraddress-list?per_page=-1&user_id=${getIntAsync(USER_ID)}&city_id=${getIntAsync(CITY_ID)}',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveUserAddress(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'useraddress-save',
      method: HttpMethod.POST,
      request: req)));
}

Future<LDBaseResponse> deleteUserAddress(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'useraddress-delete/$id',
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> verifyOtpEmail(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'verify-otp-for-email',
      request: req,
      method: HttpMethod.POST)));
}

Future<LDBaseResponse> resendOtpEmail() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'resend-otp-for-email',
      method: HttpMethod.POST)));
}

Future<DirectionsResponse> getDistanceBetweenLatLng(
    String origins, String destinations) async {
  return DirectionsResponse.fromJson(await handleResponse(
      await buildHttpResponse(
          'distance-matrix-api?origins=$origins&destinations=$destinations',
          method: HttpMethod.GET)));
}

//Language Data
Future<ServerLanguageResponse> getLanguageList(versionNo) async {
  return ServerLanguageResponse.fromJson(await handleResponse(
          await buildHttpResponse('language-table-list?version_no=$versionNo',
              method: HttpMethod.GET))
      .then((value) => value));
}

// Get DeliveryMan Dashboard count List
Future<DashboardCount> getDashboardCount(
    {String? startDate, String? endDate}) async {
  String endpoint = 'deliveryman-dashboard-data';
  if (startDate != null && endDate != null) {
    endpoint += '?from_date=$startDate&to_date=$endDate';
  }
  // return DashboardCount.fromJson(await handleResponse(await buildHttpResponse(endpoint, method: HttpMethod.GET)));

  // 返回一个空的 DashboardCount 对象，不调用 API
  return DashboardCount(
    todayOrder: 0,
    pendingOrder: 0,
    completeOrder: 0,
    inprogressOrder: 0,
    commission: 0.0,
    walletBalance: 0.0,
    pendingWithdrawRequest: 0,
    completeWithdrawRequest: 0,
  );
}

Future<PageListModel> getPagesList() async {
  return PageListModel.fromJson(await handleResponse(await buildHttpResponse(
    'pages-list',
    method: HttpMethod.GET,
  )));
}

/// get completed OrderList
Future<OrderListModel> getUserOrderHistoryList({required int page}) async {
  String endPoint =
      'order-list?client_id=${getIntAsync(USER_ID)}&page=$page&status=completed&exclude_status=draft';
  OrderListModel orders = OrderListModel.fromJson(await handleResponse(
      await buildHttpResponse(endPoint, method: HttpMethod.GET)));
  return orders;
}

Future<AdminChatModel> getChatList(int? page) async {
  return AdminChatModel.fromJson(await handleResponse(await buildHttpResponse(
    'chatsystem-list?page=$page',
    method: HttpMethod.GET,
  )));
}

Future<LDBaseResponse> saveChat(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'chatmessage-save',
      method: HttpMethod.POST,
      request: req)));
}

Future<LDBaseResponse> saveCustomerSupport(Map req) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'customersupport-save',
      method: HttpMethod.POST,
      request: req)));
}

Future<CustomerSupportListModel> getCustomerSupportList(
    {int? page, int? support_id}) async {
  String endpoint = 'customersupport-list';
  if (page != null && page > 0) {
    endpoint += '?page=$page';
  } else if (support_id != null && support_id > 0) {
    endpoint += '?support_id=$support_id';
  }
  return CustomerSupportListModel.fromJson(
      await handleResponse(await buildHttpResponse(
    endpoint,
    method: HttpMethod.GET,
  )));
}

Future<RewardsListModel> getRewardsList({int? page}) async {
  return RewardsListModel.fromJson(await handleResponse(await buildHttpResponse(
    'reward-list?page=$page',
    method: HttpMethod.GET,
  )));
}

Future<ReferralHistoryListModel> getReferralList({int? page}) async {
  return ReferralHistoryListModel.fromJson(
      await handleResponse(await buildHttpResponse(
    'reference-list?page=$page',
    method: HttpMethod.GET,
  )));
}

Future<ordersLatLngResponseList> getLatLngOfOrders() async {
  return ordersLatLngResponseList
      .fromJson(await handleResponse(await buildHttpResponse(
    'order-location-list',
    method: HttpMethod.GET,
  )));
}

Future<PageResponse> getPageDetailsById({String? id}) async {
  return PageResponse.fromJson(await handleResponse(await buildHttpResponse(
    'page-detail?id=$id',
    method: HttpMethod.GET,
  )));
}

Future<CreateOrderDetailsResponse> getCreateOrderDetails(int id) async {
  return CreateOrderDetailsResponse.fromJson(
      await handleResponse(await buildHttpResponse(
    'multipledetails-list?city_id=$id',
    method: HttpMethod.GET,
  )));
}

Future<TotalAmountResponse> getTotalAmountForOrder(Map req) async {
  return TotalAmountResponse.fromJson(await handleResponse(
      await buildHttpResponse('calculatetotal-get',
          method: HttpMethod.POST, request: req)));
}

Future<DeliverymanVehicleListModel> getDeliveryManVehicleList(int page) async {
  return DeliverymanVehicleListModel.fromJson(
      await handleResponse(await buildHttpResponse(
    'deliverymanvehiclehistory-list?page=$page',
    method: HttpMethod.GET,
  )));
}

Future<ClaimListResponseModel> getClaimList(int page) async {
  return ClaimListResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(
    'claims-list?page=$page',
    method: HttpMethod.GET,
  )));
}

Future<OrderRescheduleResponse> rescheduleOrder(Map request) async {
  return OrderRescheduleResponse.fromJson(await handleResponse(
      await buildHttpResponse('reschedule-save',
          method: HttpMethod.POST, request: request)));
}

Future<CouponListResponseModel> getCouponListApi(int page) async {
  return CouponListResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(
    'coupon-list?page=$page',
    method: HttpMethod.GET,
  )));
}
