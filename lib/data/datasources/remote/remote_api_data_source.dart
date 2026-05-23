import 'dart:async';

import 'package:dio/dio.dart';
import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/data/datasources/local/local_cache.dart';
import 'package:localservicemarket/data/datasources/remote/api_client.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

class RemoteApiDataSource implements ApiDataSource {
  RemoteApiDataSource(this._dio, this._cache);

  final Dio _dio;
  final LocalCache _cache;

  static const _api = '/api/v1';
  static const demoPassword = 'password123';

  @override
  Future<void> ensureInitialized() async {
    await _dio.get('/health');
  }

  Future<T> _get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get<T>(path, queryParameters: query);
      return res.data as T;
    } on DioException catch (e) {
      throwApiException(e);
    }
  }

  Future<T> _post<T>(String path, {Object? data}) async {
    try {
      final res = await _dio.post<T>(path, data: data);
      return res.data as T;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Invalid email or password');
      }
      if (e.response?.statusCode == 409) {
        final msg = (e.response?.data as Map?)?['error'] as String?;
        throw AuthException(msg ?? 'Conflict');
      }
      if (e.response?.statusCode == 402) {
        throw PaymentException(
          (e.response?.data as Map?)?['error'] as String? ?? 'Payment failed',
        );
      }
      throwApiException(e);
    }
  }

  Future<T> _patch<T>(String path, {Object? data}) async {
    try {
      final res = await _dio.patch<T>(path, data: data);
      return res.data as T;
    } on DioException catch (e) {
      throwApiException(e);
    }
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await _post<Map<String, dynamic>>(
      '$_api/auth/login',
      data: {'email': email, 'password': password},
    );
    final token = res['token'] as String?;
    final user = res['user'] as Map<String, dynamic>?;
    if (token != null) await _cache.setAuthToken(token);
    if (user != null) await _cache.setSessionUserId(user['userId'] as String);
    return user;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
  }) async {
    final res = await _post<Map<String, dynamic>>(
      '$_api/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role.wireValue,
        'bio': bio,
      },
    );
    final token = res['token'] as String?;
    final user = res['user'] as Map<String, dynamic>;
    if (token != null) await _cache.setAuthToken(token);
    await _cache.setSessionUserId(user['userId'] as String);
    return user;
  }

  @override
  Future<Map<String, dynamic>?> currentUser() async {
    if (_cache.getAuthToken() == null) return null;
    try {
      return await _get<Map<String, dynamic>>('$_api/auth/me');
    } catch (_) {
      await _cache.setAuthToken(null);
      await _cache.setSessionUserId(null);
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('$_api/auth/logout');
    } catch (_) {}
    await _cache.setAuthToken(null);
    await _cache.setSessionUserId(null);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _list(await _get('$_api/categories'));
  }

  @override
  Future<List<Map<String, dynamic>>> getServices({
    String? categoryId,
    String? providerId,
  }) async {
    return _list(
      await _get('$_api/services', query: {
        if (categoryId != null) 'categoryId': categoryId,
        if (providerId != null) 'providerId': providerId,
      }),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? categoryId,
    double? minRating,
    PriceType? priceType,
    String? query,
  }) async {
    return _list(
      await _get('$_api/providers/nearby', query: {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
        if (categoryId != null) 'categoryId': categoryId,
        if (minRating != null) 'minRating': minRating,
        if (priceType != null) 'priceType': priceType.wireValue,
        if (query != null && query.isNotEmpty) 'query': query,
      }),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getSlotsForDay(
    String providerId,
    DateTime day,
  ) async {
    final dayStr = DateTime(day.year, day.month, day.day).toIso8601String();
    return _list(
      await _get('$_api/slots', query: {
        'providerId': providerId,
        'day': dayStr,
      }),
    );
  }

  @override
  Future<Map<String, dynamic>> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String slotId,
    required String addressId,
    required double totalPrice,
    String notes = '',
  }) async {
    try {
      return Map<String, dynamic>.from(
        await _post('$_api/bookings', data: {
          'providerId': providerId,
          'serviceId': serviceId,
          'slotId': slotId,
          'addressId': addressId,
          'totalPrice': totalPrice,
          'notes': notes,
        }) as Map,
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] as String? ?? e.message;
      if (e.response?.statusCode == 409) {
        if (msg != null && msg.toLowerCase().contains('slot')) {
          throw SlotUnavailableException(msg);
        }
        throw ProviderUnavailableException(msg ?? 'Provider unavailable');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    return Map<String, dynamic>.from(
      await _patch('$_api/bookings/$bookingId/status', data: {
        'status': status.wireValue,
      }) as Map,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    required bool asProvider,
    BookingStatus? status,
  }) async {
    return _list(
      await _get('$_api/bookings', query: {
        'asProvider': asProvider,
        if (status != null) 'status': status.wireValue,
      }),
    );
  }

  @override
  Future<Map<String, dynamic>> startService(String bookingId) async {
    return Map<String, dynamic>.from(
      await _post('$_api/bookings/$bookingId/start') as Map,
    );
  }

  @override
  Future<Map<String, dynamic>> completeService(String bookingId) async {
    return Map<String, dynamic>.from(
      await _post('$_api/bookings/$bookingId/complete') as Map,
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> watchProviderPending(String providerId) {
    return Stream.periodic(const Duration(seconds: 4)).asyncMap((_) async {
      try {
        return _list(
          await _get('$_api/bookings/pending', query: {'providerId': providerId}),
        );
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    });
  }

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  }) async {
    return Map<String, dynamic>.from(
      await _post('$_api/payments', data: {
        'bookingId': bookingId,
        'amount': amount,
        'method': method.wireValue,
      }) as Map,
    );
  }

  @override
  Future<Map<String, dynamic>> processPayment({
    required String paymentId,
    required bool simulateSuccess,
  }) async {
    return Map<String, dynamic>.from(
      await _post('$_api/payments/$paymentId/process', data: {
        'simulateSuccess': simulateSuccess,
      }) as Map,
    );
  }

  @override
  Future<Map<String, dynamic>?> paymentForBooking(String bookingId) async {
    final data = await _get<dynamic>('$_api/payments', query: {'bookingId': bookingId});
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  @override
  Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required String reviewerId,
    required String providerId,
    required int rating,
    String comment = '',
  }) async {
    try {
      return Map<String, dynamic>.from(
        await _post('$_api/reviews', data: {
          'bookingId': bookingId,
          'providerId': providerId,
          'rating': rating,
          'comment': comment,
        }) as Map,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException(
          (e.response?.data as Map?)?['error'] as String? ?? 'Duplicate review',
        );
      }
      rethrow;
    }
  }

  @override
  Future<bool> hasReview(String bookingId) async {
    final res = await _get<Map<String, dynamic>>(
      '$_api/reviews/exists',
      query: {'bookingId': bookingId},
    );
    return res['exists'] == true;
  }
}
