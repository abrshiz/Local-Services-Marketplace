import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/time_slot.dart';

enum CustomerBookingStatus { initial, loading, slotsLoaded, submitting, success, failure }

class CustomerBookingState extends Equatable {
  const CustomerBookingState({
    this.status = CustomerBookingStatus.initial,
    this.slots = const [],
    this.selectedSlot,
    this.createdBooking,
    this.notes = '',
    this.errorMessage,
  });

  final CustomerBookingStatus status;
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final Booking? createdBooking;
  final String notes;
  final String? errorMessage;

  CustomerBookingState copyWith({
    CustomerBookingStatus? status,
    List<TimeSlot>? slots,
    TimeSlot? selectedSlot,
    Booking? createdBooking,
    String? notes,
    String? errorMessage,
    bool clearSlot = false,
  }) {
    return CustomerBookingState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
      createdBooking: createdBooking ?? this.createdBooking,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, slots, selectedSlot, createdBooking, notes, errorMessage];
}
