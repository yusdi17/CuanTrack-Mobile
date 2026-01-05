import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'http://92.113.124.171:8002/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ),
);
void setupInterceptors() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('SENDING REQUEST: ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('GOT RESPONSE: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR: ${e.response?.statusCode} - ${e.message}');
        return handler.next(e);
      },
    ),
  );
}