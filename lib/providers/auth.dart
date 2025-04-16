import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/main/utils/storage.dart';
import 'package:mighty_delivery/providers/helpers.dart';
import '../main/network/http_utils.dart'; // Import HttpUtils

enum LoginActions {
  update,
  proceed
}                                                                                          

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
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  /// flag to indicate that the application has successfully loaded all initial data
  bool dataInit = false;

  bool get isAuth {
    return token != null;
  }

  Future<Map<String, LoginActions>> login(String usernameOrEmail, String password, String serverUrl) async {
    try {
      var response = await HttpUtils.post(
        serverUrl,
        data: {
          'client_id': 'SimTech.Apex_App',
          'grant_type': 'password',
          'username': usernameOrEmail,
          'password': password,
          'scope': 'IdentityService AdministrationService StorageService PartnerService TransportService DeliveryService OrderService InventoryService MessagingService WorkflowService EngineService IntegrationService MobileService',
        },
      );

      if (response.code == 0) {
        token = response.data['access_token'];
        SpUtil.token.val = token!; // Save token using SpUtil
        await HttpUtils.init(unAuthHandle: (){
        });

        print("token get:" + SpUtil.token.val);
        SpUtil.setJSON(IS_LOGGED_IN, true); // Save login status using SpUtil
        return {'action': LoginActions.update};
      } else {
        _logger.severe('Login failed: ${response.msg}');
        return {'error': LoginActions.proceed};
      }
    } catch (error) {
      _logger.severe('Login failed: $error');
      return {'error': LoginActions.proceed};
    }
  }
}