import 'package:localservicemarket/domain/entities/payment.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/enums/payment_status.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.paymentId,
    required super.bookingId,
    required super.amount,
    required super.status,
    required super.method,
    super.transactionRef,
    super.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: json['paymentId'] as String,
      bookingId: json['bookingId'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: PaymentStatus.fromString(json['status'] as String),
      method: PaymentMethod.fromString(json['method'] as String),
      transactionRef: json['transactionRef'] as String?,
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'paymentId': paymentId,
        'bookingId': bookingId,
        'amount': amount,
        'status': status.wireValue,
        'method': method.wireValue,
        'transactionRef': transactionRef,
        'paidAt': paidAt?.toIso8601String(),
      };
}
