import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:mighty_delivery/extensions/shared_pref.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mighty_delivery/providers/helpers.dart';

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
  var response;
  try {
     response = await client.post(
      makeUri(serverUrl, LOGIN_URL),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        HttpHeaders.userAgentHeader: 'PostmanRuntime/7.43.0',
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
        HttpHeaders.connectionHeader: 'keep-alive',
        // 'Postman-Token': '<calculated when request is sent>',
        // 'Host': '<calculated when request is sent>',
        // 'Content-Length': '<calculated when request is sent>',
      },
      body: {
        'client_id': 'External_Integration',
        'client_secret': '3a165ec4-6a3f-a19e-657c-0739e26cb85e',
        'grant_type': 'password',
        'username': usernameOrEmail,
        'password': password,
        'scope': '',
      }
    );
  } catch (error) {
    _logger.severe('Login failed: $error');
  }

    if (response.statusCode >= 400) {
      _logger.severe('Login failed: ${response.body}');
      return {'error': LoginActions.proceed};
    }

    final responseData = json.decode(response.body);
    token = responseData['access_token'];

    setValue(ACCESS_TOKEN, token);
    setValue(IS_LOGGED_IN, true);

    // Print responseData and token to the console
    // print('Uri: ${makeUri(serverUrl, LOGIN_URL)}');
    // print('Response Data: $responseData');
    // print('Token: $token');
    
    return {'action': LoginActions.update};
  }
}