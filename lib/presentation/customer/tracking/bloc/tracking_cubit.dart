import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/repositories/booking_repository.dart';

enum TrackingStatus { initial, loading, loaded, failure }

class TrackingState extends Equatable {
  const TrackingState({
    this.status = TrackingStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  final TrackingStatus status;
  final List<Booking> bookings;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._bookings) : super(const TrackingState());

  final BookingRepository _bookings;

  Future<void> load(String customerId) async {
    emit(const TrackingState(status: TrackingStatus.loading));
    try {
      final list = await _bookings.getBookingsForUser(
        userId: customerId,
        asProvider: false,
      );
      emit(TrackingState(status: TrackingStatus.loaded, bookings: list));
    } catch (e) {
      emit(TrackingState(
        status: TrackingStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Booking? activeBooking(List<Booking> all) {
    return all.cast<Booking?>().firstWhere(
          (b) =>
              b!.status == BookingStatus.confirmed ||
              b.serviceStartedAt != null && b.status != BookingStatus.completed,
          orElse: () => null,
        );
  }
}
