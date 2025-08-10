import 'package:dio/dio.dart';

import '../utils/logutil.dart';

class MyLogInterceptor extends Interceptor {
  MyLogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    StringBuffer log = StringBuffer();
    log.write('*** Request ***\n');
    _printKV(log, 'uri', options.uri);

    if (request) {
      _printKV(log, 'method', options.method);
      _printKV(log, 'responseType', options.responseType.toString());
      _printKV(log, 'followRedirects', options.followRedirects);
      _printKV(log, 'persistentConnection', options.persistentConnection);
      _printKV(log, 'connectTimeout', options.connectTimeout);
      _printKV(log, 'sendTimeout', options.sendTimeout);
      _printKV(log, 'receiveTimeout', options.receiveTimeout);
      _printKV(
        log,
        'receiveDataWhenStatusError',
        options.receiveDataWhenStatusError,
      );
      _printKV(log, 'extra', options.extra);
    }
    if (requestHeader) {
      log.write('headers:\n');
      options.headers.forEach((key, v) => _printKV(log, ' $key', v));
    }
    if (requestBody) {
      log.write('data:\n');
      _printAll(log, options.data);
    }

    logger.i(log);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _printResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (error) {
      StringBuffer log = StringBuffer();
      log.write('*** DioException ***:\n');
      log.write('uri: ${err.requestOptions.uri}\n');
      log.write('$err\n');
      if (err.response != null) {
        _printResponse(err.response!);
      }
      logger.i(log);
    }
    handler.next(err);
  }

  void _printResponse(Response response) {
    StringBuffer log = StringBuffer();
    _printKV(log, 'uri', response.requestOptions.uri);
    if (responseHeader) {
      _printKV(log, 'statusCode', response.statusCode);
      if (response.isRedirect == true) {
        _printKV(log, 'redirect', response.realUri);
      }

      log.write('headers:\n');
      response.headers
          .forEach((key, v) => _printKV(log, ' $key', v.join('\r\n\t')));
    }
    if (responseBody) {
      log.write('Response Text:\n');
      _printAll(log, response.toString());
    }
    log.write('\n');
    logger.i(log);
  }

  void _printKV(StringBuffer log, String key, Object? v) {
    log.write('$key: $v\n');
  }

  void _printAll(log, msg) {
    msg.toString().split('\n').forEach((v) => log.write("$v\n"));
  }
}