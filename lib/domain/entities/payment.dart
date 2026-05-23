import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/enums/payment_status.dart';

class Payment extends Equatable {
  const Payment({
    required this.paymentId,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.method,
    this.transactionRef,
    this.paidAt,
  });

  final String paymentId;
  final String bookingId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionRef;
  final DateTime? paidAt;

  Payment copyWith({
    String? paymentId,
    String? bookingId,
    double? amount,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionRef,
    DateTime? paidAt,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionRef: transactionRef ?? this.transactionRef,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  @override
  List<Object?> get props =>
      [paymentId, bookingId, amount, status, method, transactionRef, paidAt];
}
