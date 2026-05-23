import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.bookingId,
    required super.customerId,
    required super.providerId,
    required super.serviceId,
    required super.scheduledTime,
    required super.endTime,
    required super.status,
    required super.totalPrice,
    required super.addressId,
    super.slotId,
    super.notes,
    super.serviceStartedAt,
    super.serviceCompletedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'] as String,
      customerId: json['customerId'] as String,
      providerId: json['providerId'] as String,
      serviceId: json['serviceId'] as String,
      slotId: json['slotId'] as String?,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: BookingStatus.fromString(json['status'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      addressId: json['addressId'] as String,
      notes: json['notes'] as String? ?? '',
      serviceStartedAt: json['serviceStartedAt'] != null
          ? DateTime.parse(json['serviceStartedAt'] as String)
          : null,
      serviceCompletedAt: json['serviceCompletedAt'] != null
          ? DateTime.parse(json['serviceCompletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'customerId': customerId,
        'providerId': providerId,
        'serviceId': serviceId,
        'slotId': slotId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'status': status.wireValue,
        'totalPrice': totalPrice,
        'addressId': addressId,
        'notes': notes,
        'serviceStartedAt': serviceStartedAt?.toIso8601String(),
        'serviceCompletedAt': serviceCompletedAt?.toIso8601String(),
      };
}
