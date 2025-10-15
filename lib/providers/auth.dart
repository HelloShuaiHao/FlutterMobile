import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import '../main/network/http_utils.dart'; // Import HttpUtils

enum LoginActions { update, proceed }

class MyAuthProvider with ChangeNotifier {
  final _logger = Logger('AuthProvider');

  String? token;
  String? serverUrl;
  String? serverVersion;
  Map<String, String> metadata = {};

  static const MIN_APP_VERSION_URL = 'min-app-version';
  static const SERVER_VERSION_URL = 'version';
  static const REGISTRATION_URL = 'register';
  static const LOGIN_URL = 'connect/token';

  late http.Client client;

  MyAuthProvider([http.Client? client, bool? checkMetadata]) {
    this.client = client ?? createHttpClient();
  }
  static http.Client createHttpClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  /// flag to indicate that the application has successfully loaded all initial data
  bool dataInit = false;

  bool get isAuth {
    return token != null;
  }

  Future<Map<String, dynamic>> login(
      String usernameOrEmail, String password, String serverUrl) async {
    try {
      var response = await HttpUtils.post(
        serverUrl,
        data: {
          'client_id': 'SimTech.Apex_App',
          'grant_type': 'password',
          'username': usernameOrEmail,
          'password': password,
          'scope':
              'TransportService PartnerService DeliveryService MobileService offline_access',
        },
      );

      if (response.code == 0) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];
        final expiresIn = response.data['expires_in'];
        final tokenType = response.data['token_type'];

        token = accessToken;
        SpUtil.token.val = accessToken;
        SpUtil.refresh_token.val = refreshToken ?? '';
        // 同步更新 Dio 全局 header
        HttpUtils.refreshTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        // 统一使用 SharedPreferences 保存登录状态，避免仅写入 GetStorage 导致进程重启后丢失
        // （主入口 main.dart 里只从 SharedPreferences 读取 IS_LOGGED_IN）
        try {
          await appStore.setLogin(true); // 会写入 SharedPreferences
        } catch (e) {
          _logger.warning('Set login state failed: $e');
        }

        print("[Auth] token acquired length=${accessToken?.length}");

        return {
          'action': LoginActions.update,
          'access_token': accessToken,
          'refresh_token': refreshToken,
          'expires_in': expiresIn,
          'token_type': tokenType,
        };
      } else {
        print('Login failed: ${response.msg}');
        return {
          'error': LoginActions.proceed,
          'msg': response.msg,
        };
      }
    } catch (error) {
      _logger.severe('Login failed: $error');
      return {
        'error': LoginActions.proceed,
        'msg': error.toString(),
      };
    }
  }
}
