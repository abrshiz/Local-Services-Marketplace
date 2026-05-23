import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:localservicemarket/core/config/app_config.dart';
import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/core/network/connectivity_cubit.dart';
import 'package:localservicemarket/data/datasources/local/local_cache.dart';

Dio createApiClient(LocalCache cache) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
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
      onError: (error, handler) {
        if (isNetworkDioError(error)) {
          if (GetIt.I.isRegistered<ConnectivityCubit>()) {
            GetIt.I<ConnectivityCubit>().reportNetworkFailure();
          }
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: NetworkException(),
              type: error.type,
            ),
          );
          return;
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

Never throwApiException(DioException e) {
  if (isNetworkDioError(e)) {
    throw NetworkException();
  }
  final data = e.response?.data;
  if (data is Map && data['error'] is String) {
    throw Exception(data['error'] as String);
  }
  throw Exception(e.message ?? 'Something went wrong');
}
