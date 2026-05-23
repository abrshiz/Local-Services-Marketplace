import 'package:dio/dio.dart';
import 'package:localservicemarket/core/config/app_config.dart';
import 'package:localservicemarket/data/datasources/local/local_cache.dart';

Dio createApiClient(LocalCache cache) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = cache.getAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

Never throwApiException(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['error'] is String) {
    throw Exception(data['error'] as String);
  }
  throw Exception(e.message ?? 'Network error');
}
