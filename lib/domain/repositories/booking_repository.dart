import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/time_slot.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';

abstract class BookingRepository {
  Future<List<TimeSlot>> getAvailableSlots({
    required String providerId,
    required DateTime day,
  });
  Future<Booking> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String slotId,
    required String addressId,
    required double totalPrice,
    String notes,
  });
  Future<Booking> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  });
  Future<List<Booking>> getBookingsForUser({
    required String userId,
    bool asProvider,
    BookingStatus? status,
  });
  Future<Booking> startService(String bookingId);
  Future<Booking> completeService(String bookingId);
  Stream<List<Booking>> watchProviderPending(String providerId);
}
