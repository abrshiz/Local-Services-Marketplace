import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/booking_model.dart';
import 'package:localservicemarket/data/models/time_slot_model.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/time_slot.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._api);

  final ApiDataSource _api;

  @override
  Future<List<TimeSlot>> getAvailableSlots({
    required String providerId,
    required DateTime day,
  }) async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getSlotsForDay(providerId, day);
      return list.map(TimeSlotModel.fromJson).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Booking> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String slotId,
    required String addressId,
    required double totalPrice,
    String notes = '',
  }) async {
    try {
      final json = await _api.createBooking(
        customerId: customerId,
        providerId: providerId,
        serviceId: serviceId,
        slotId: slotId,
        addressId: addressId,
        totalPrice: totalPrice,
        notes: notes,
      );
      return BookingModel.fromJson(json);
    } on SlotUnavailableException catch (e) {
      throw BookingFailure(e.message);
    } on ProviderUnavailableException catch (e) {
      throw BookingFailure(e.message);
    }
  }

  @override
  Future<Booking> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      final json = await _api.updateBookingStatus(bookingId, status);
      return BookingModel.fromJson(json);
    } on BookingException catch (e) {
      throw BookingFailure(e.message);
    }
  }

  @override
  Future<List<Booking>> getBookingsForUser({
    required String userId,
    bool asProvider = false,
    BookingStatus? status,
  }) async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getBookings(
        userId: userId,
        asProvider: asProvider,
        status: status,
      );
      return list.map(BookingModel.fromJson).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Booking> startService(String bookingId) async {
    try {
      final json = await _api.startService(bookingId);
      return BookingModel.fromJson(json);
    } catch (e) {
      throw BookingFailure(e.toString());
    }
  }

  @override
  Future<Booking> completeService(String bookingId) async {
    try {
      final json = await _api.completeService(bookingId);
      return BookingModel.fromJson(json);
    } catch (e) {
      throw BookingFailure(e.toString());
    }
  }

  @override
  Stream<List<Booking>> watchProviderPending(String providerId) {
    return _api.watchProviderPending(providerId).map(
          (list) => list.map(BookingModel.fromJson).toList(),
        );
  }
}
