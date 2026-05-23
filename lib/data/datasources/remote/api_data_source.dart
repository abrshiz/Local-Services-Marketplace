import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

/// Contract shared by mock and REST implementations.
abstract class ApiDataSource {
  Future<void> ensureInitialized();

  Future<Map<String, dynamic>?> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
  });
  Future<Map<String, dynamic>?> currentUser();
  Future<void> logout();

  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getServices({
    String? categoryId,
    String? providerId,
  });
  Future<List<Map<String, dynamic>>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm,
    String? categoryId,
    double? minRating,
    PriceType? priceType,
    String? query,
  });

  Future<List<Map<String, dynamic>>> getSlotsForDay(String providerId, DateTime day);

  Future<Map<String, dynamic>> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String slotId,
    required String addressId,
    required double totalPrice,
    String notes,
  });

  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  );

  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    required bool asProvider,
    BookingStatus? status,
  });

  Future<Map<String, dynamic>> startService(String bookingId);
  Future<Map<String, dynamic>> completeService(String bookingId);

  Stream<List<Map<String, dynamic>>> watchProviderPending(String providerId);

  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  });

  Future<Map<String, dynamic>> processPayment({
    required String paymentId,
    required bool simulateSuccess,
  });

  Future<Map<String, dynamic>?> paymentForBooking(String bookingId);

  Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required String reviewerId,
    required String providerId,
    required int rating,
    String comment,
  });

  Future<bool> hasReview(String bookingId);
}
