import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/time_slot.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/repositories/booking_repository.dart';
import 'package:localservicemarket/domain/repositories/payment_repository.dart';

enum ProviderDashStatus { initial, loading, loaded, actionLoading, failure }

class ProviderDashboardState extends Equatable {
  const ProviderDashboardState({
    this.status = ProviderDashStatus.initial,
    this.pending = const [],
    this.allBookings = const [],
    this.slots = const [],
    this.earnings = 0,
    this.errorMessage,
  });

  final ProviderDashStatus status;
  final List<Booking> pending;
  final List<Booking> allBookings;
  final List<TimeSlot> slots;
  final double earnings;
  final String? errorMessage;

  ProviderDashboardState copyWith({
    ProviderDashStatus? status,
    List<Booking>? pending,
    List<Booking>? allBookings,
    List<TimeSlot>? slots,
    double? earnings,
    String? errorMessage,
  }) {
    return ProviderDashboardState(
      status: status ?? this.status,
      pending: pending ?? this.pending,
      allBookings: allBookings ?? this.allBookings,
      slots: slots ?? this.slots,
      earnings: earnings ?? this.earnings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, pending, allBookings, slots, earnings, errorMessage];
}

class ProviderDashboardCubit extends Cubit<ProviderDashboardState> {
  ProviderDashboardCubit(
    this._bookings,
    this._payments,
  ) : super(const ProviderDashboardState());

  final BookingRepository _bookings;
  final PaymentRepository _payments;

  StreamSubscription<List<Booking>>? _pendingSub;
  String? _providerId;

  Future<void> load(String providerId) async {
    _providerId = providerId;
    emit(state.copyWith(status: ProviderDashStatus.loading, errorMessage: null));
    try {
      final all = await _bookings.getBookingsForUser(
        userId: providerId,
        asProvider: true,
      );
      final pending = all
          .where((b) => b.status == BookingStatus.pending)
          .toList();
      final today = DateTime.now();
      final slots = await _bookings.getAvailableSlots(
        providerId: providerId,
        day: today,
      );

      var earnings = 0.0;
      for (final b in all.where((x) => x.status == BookingStatus.completed)) {
        final p = await _payments.getPaymentForBooking(b.bookingId);
        if (p != null) earnings += p.amount;
      }

      emit(state.copyWith(
        status: ProviderDashStatus.loaded,
        allBookings: all,
        pending: pending,
        slots: slots,
        earnings: earnings,
      ));

      await _pendingSub?.cancel();
      _pendingSub = _bookings.watchProviderPending(providerId).listen((list) {
        emit(state.copyWith(pending: list));
      });
    } catch (e) {
      emit(state.copyWith(
        status: ProviderDashStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> accept(String bookingId) async {
    emit(state.copyWith(status: ProviderDashStatus.actionLoading));
    try {
      await _bookings.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.confirmed,
      );
      if (_providerId != null) await load(_providerId!);
    } on BookingFailure catch (e) {
      emit(state.copyWith(
        status: ProviderDashStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> reject(String bookingId) async {
    emit(state.copyWith(status: ProviderDashStatus.actionLoading));
    try {
      await _bookings.updateBookingStatus(
        bookingId: bookingId,
        status: BookingStatus.cancelled,
      );
      if (_providerId != null) await load(_providerId!);
    } on BookingFailure catch (e) {
      emit(state.copyWith(
        status: ProviderDashStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> startService(String bookingId) async {
    await _bookings.startService(bookingId);
    if (_providerId != null) await load(_providerId!);
  }

  Future<void> completeService(String bookingId) async {
    await _bookings.completeService(bookingId);
    if (_providerId != null) await load(_providerId!);
  }

  Future<void> loadCalendarDay(DateTime day) async {
    if (_providerId == null) return;
    final slots = await _bookings.getAvailableSlots(
      providerId: _providerId!,
      day: day,
    );
    emit(state.copyWith(slots: slots));
  }

  @override
  Future<void> close() {
    _pendingSub?.cancel();
    return super.close();
  }
}
