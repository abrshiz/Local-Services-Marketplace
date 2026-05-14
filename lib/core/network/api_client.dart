import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class ApiClient {
  late Dio dio;
  
  // Replace with your actual backend URL
  static const String baseUrl = 'https://api.yourmarketplace.com/v1';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add JWT Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthService().token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Global error handling (e.g., auto-logout on 401)
          if (e.response?.statusCode == 401) {
            await AuthService().logout();
            // You might want to trigger a navigation to the login screen here
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper methods for common requests
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
