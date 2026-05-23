import 'package:localservicemarket/domain/entities/payment.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';

abstract class PaymentRepository {
  Future<Payment> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  });
  Future<Payment> processPayment({
    required String paymentId,
    required bool simulateSuccess,
  });
  Future<Payment?> getPaymentForBooking(String bookingId);
}
