import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';

class Booking extends Equatable {
  const Booking({
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.scheduledTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.addressId,
    this.slotId,
    this.notes = '',
    this.serviceStartedAt,
    this.serviceCompletedAt,
  });

  final String bookingId;
  final String customerId;
  final String providerId;
  final String serviceId;
  final String? slotId;
  final DateTime scheduledTime;
  final DateTime endTime;
  final BookingStatus status;
  final double totalPrice;
  final String addressId;
  final String notes;
  final DateTime? serviceStartedAt;
  final DateTime? serviceCompletedAt;

  Booking copyWith({
    String? bookingId,
    String? customerId,
    String? providerId,
    String? serviceId,
    String? slotId,
    DateTime? scheduledTime,
    DateTime? endTime,
    BookingStatus? status,
    double? totalPrice,
    String? addressId,
    String? notes,
    DateTime? serviceStartedAt,
    DateTime? serviceCompletedAt,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      slotId: slotId ?? this.slotId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      addressId: addressId ?? this.addressId,
      notes: notes ?? this.notes,
      serviceStartedAt: serviceStartedAt ?? this.serviceStartedAt,
      serviceCompletedAt: serviceCompletedAt ?? this.serviceCompletedAt,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        customerId,
        providerId,
        serviceId,
        slotId,
        scheduledTime,
        endTime,
        status,
        totalPrice,
        addressId,
        notes,
        serviceStartedAt,
        serviceCompletedAt,
      ];
}
