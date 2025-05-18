import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as _get;
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/logutil.dart';
import '../utils/storage.dart';
import '../utils/toast.dart';
import 'log.dart';
import 'response_entity.dart';

typedef StreamCallBack = Function(String var1);

class HttpUtils {
  static late final Dio dio;
  static final CancelToken _cancelToken = CancelToken();
  static Function? _unAuthHandle;

  static init({Function? unAuthHandle}) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _unAuthHandle = unAuthHandle;

    BaseOptions options = BaseOptions();
    dio = Dio(options);

    dio.options = dio.options.copyWith(
      baseUrl: SpUtil.baseUrl.val,
      connectTimeout: const Duration(seconds: 15),
    );

    // Ignore SSL certificate errors (for development purposes only)
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      var headers = options.headers;
      var authorization = headers['Authorization']?.toString();
      if (authorization == null || authorization.isEmpty) {
        // 注意这里 defaultValue 和 val 的区别
        // defaultValue 是默认值，val 是获取值
        options.headers['Authorization'] = 'Bearer ${SpUtil.token.val}';
      }

      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      headers['APP_packageName'] = packageName;
      headers['APP_version'] = version;
      headers['APP_buildNumber'] = buildNumber;
      headers['APP_platform'] = Platform.isAndroid ? "Android" : "iOS";

      ///用来获取当前系统中的语言
      // Locale locale = Localizations.localeOf(_get.Get.context!);
      // headers['APP_LanguageCode'] = locale.languageCode;
      // headers['env'] = locale.languageCode == "zh" ? 1 : 2;

      handler.next(options);
    }));

    dio.interceptors.add(InterceptorsWrapper(onResponse: (response, handler) {
      var status = response.statusCode;
      if (status == 401) {
        _unAuthHandle?.call();
      } else {
        if (response.data != null && response.data is Map<String, dynamic>) {
          if (response.data!["code"] == 401) {
            _unAuthHandle?.call();
          }
        }
      }
      handler.next(response);
    }));

    // 添加拦截器
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    // dio.interceptors.add(MyLogInterceptor());

    if (kDebugMode) {
      // DdCheckPlugin().init(
      //   dio,
      //   initHost: '192.168.1.89', // Change to your computer IP
      //   projectName: "AI", // Custom Project Name
      // );
    }
  }

  static void cancelRequests({CancelToken? token}) {
    if (token != null) {
      token.cancel("cancelled");
    } else {
      _cancelToken.cancel("cancelled");
    }
  }

  static Future<ResponseEntity<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    bool loadingDialog = false,
    bool showErrorTip = true,
  }) async {
    if (loadingDialog) {
      showLoading();
    }
    try {
      var response = await dio.get(
        path,
        queryParameters: params,
        options: options,
      );
      // 对返回数据进行包装
      Map<String, dynamic> wrappedData = {
        "code": 0,
        "msg": "success",
        "data": response.data,
      };

      var entity = ResponseEntity<T>.fromJson(wrappedData);
      // var entity = ResponseEntity<T>.fromJson(response.data);
      // if (entity.code == 0) {
      //   return entity;
      // } else {
      //   if (showErrorTip) {
      //     showError(entity.msg);
      //   }
      //   return ResponseEntity<T>.fromJson({
      //     "code": 500,
      //   });
      // }
      return entity;
    } catch (e) {
      if (showErrorTip) {
        showError("网络错误");
      }
      return ResponseEntity<T>.fromJson({
        "code": 500,
      });
    } finally {
      if (loadingDialog) {
        dismissLoading();
      }
    }
  }

  static Future<ResponseEntity<T>> post<T>(
    String path, {
    data,
    Options? options,
    bool loadingDialog = false,
    bool showErrorTip = true,
  }) async {
    if (loadingDialog) {
      showLoading();
    }
    try {
      // Ensure Content-Type is set to application/x-www-form-urlencoded
      options ??= Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      var response = await dio.post(
        path,
        data: data,
        options: options,
      );

      // Wrap the response data
      Map<String, dynamic> wrappedData = {
        "code": 0,
        "msg": "success",
        "data": response.data,
      };

      var entity = ResponseEntity<T>.fromJson(wrappedData);
      return entity;
    } catch (e) {
      if (showErrorTip) {
        showError("网络错误");
      }
      return ResponseEntity<T>.fromJson({
        "code": 500,
      });
    } finally {
      if (loadingDialog) {
        dismissLoading();
      }
    }
  }

  static void postForStream(
    String path,
    void Function(String event) onData, {
    data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Function? onError,
    void Function()? onDone,
  }) async {
    Response<ResponseBody> response;
    try {
      response = await dio.post<ResponseBody>(
        path,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken ?? _cancelToken,
      );
      response.data?.stream
          .transform(unit8Transformer)
          .transform(const Utf8Decoder())
          .transform(const LineSplitter())
          .listen(
        onData,
        onDone: onDone,
        onError: (d) {
          onError?.call();
        },
        cancelOnError: true,
      );
    } catch (e) {
      logger.i(e);
      onError?.call();
    }
  }

  static StreamTransformer<Uint8List, List<int>> unit8Transformer =
      StreamTransformer.fromHandlers(
    handleData: (data, sink) {
      sink.add(List<int>.from(data));
    },
  );
}
