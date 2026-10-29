import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class LoggingInterceptor extends Interceptor {
  final _authService = sl<AuthService>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final message =
        "URL: ${options.uri}\nTYPE: ${options.method}\nDATA: ${options.data}";
    Logger.logMessage(message, name: "REQUEST");
    // You can also print other request details like headers and data if needed.
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // You can inspect the response details here if needed.
    final message =
        "${response.requestOptions.uri}\nResponse: ${response.data}";
    Logger.logMessage(message, name: "RESPONSE");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors here if needed.
    final message =
        "REQUEST: ${err.requestOptions.uri}\nTYPE: ${err.requestOptions.method}\nDATA: ${err.requestOptions.data}\nCODE: ${err.response?.statusCode}\nRESPONSE: ${err.response?.data}";
    Logger.logMessage(message, name: "API ERROR", isCritical: true);
    // User is unauthorised
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.uri.toString().contains('logout')) {
      _authService.logout();
    }
    handler.next(err);
  }
}

class IsolateLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final message =
        "URL: ${options.uri}\nTYPE: ${options.method}\nDATA: ${options.data}";
    Logger.logMessage(message, name: "REQUEST");
    // You can also print other request details like headers and data if needed.
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // You can inspect the response details here if needed.
    final message =
        "${response.requestOptions.uri}\nStatus Code: ${response.statusCode}\nResponse: ${response.data}";
    Logger.logMessage(message, name: "RESPONSE");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors here if needed.
    final message =
        "REQUEST: ${err.requestOptions.uri}\nTYPE: ${err.requestOptions.method}\nDATA: ${err.requestOptions.data}\nCODE: ${err.response?.statusCode}\nRESPONSE: ${err.response?.data}";
    Logger.logMessage(message, name: "API ERROR", isCritical: true);
    handler.next(err);
  }
}
