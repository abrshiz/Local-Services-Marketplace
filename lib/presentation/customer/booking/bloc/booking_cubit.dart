import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/entities/time_slot.dart';
import 'package:localservicemarket/domain/repositories/booking_repository.dart';
import 'package:localservicemarket/presentation/customer/booking/bloc/booking_state.dart';

class BookingCubit extends Cubit<CustomerBookingState> {
  BookingCubit(this._bookingRepository) : super(const CustomerBookingState());

  final BookingRepository _bookingRepository;

  Future<void> loadSlots({
    required String providerId,
    required DateTime day,
  }) async {
    emit(state.copyWith(
      status: CustomerBookingStatus.loading,
      errorMessage: null,
      clearSlot: true,
    ));
    try {
      final slots = await _bookingRepository.getAvailableSlots(
        providerId: providerId,
        day: day,
      );
      emit(state.copyWith(
        status: CustomerBookingStatus.slotsLoaded,
        slots: slots,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: CustomerBookingStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  void selectSlot(TimeSlot slot) {
    emit(state.copyWith(selectedSlot: slot));
  }

  void setNotes(String notes) => emit(state.copyWith(notes: notes));

  Future<void> submitBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String addressId,
    required double totalPrice,
  }) async {
    final slot = state.selectedSlot;
    if (slot == null) {
      emit(state.copyWith(
        status: CustomerBookingStatus.failure,
        errorMessage: 'Please select a time slot',
      ));
      return;
    }

    emit(state.copyWith(
      status: CustomerBookingStatus.submitting,
      errorMessage: null,
    ));
    try {
      final booking = await _bookingRepository.createBooking(
        customerId: customerId,
        providerId: providerId,
        serviceId: serviceId,
        slotId: slot.slotId,
        addressId: addressId,
        totalPrice: totalPrice,
        notes: state.notes,
      );
      emit(state.copyWith(
        status: CustomerBookingStatus.success,
        createdBooking: booking,
      ));
    } on BookingFailure catch (e) {
      emit(state.copyWith(
        status: CustomerBookingStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  void reset() => emit(const CustomerBookingState());
}
