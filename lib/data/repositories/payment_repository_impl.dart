import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/payment_model.dart';
import 'package:localservicemarket/domain/entities/payment.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._api);

  final ApiDataSource _api;

  @override
  Future<Payment> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  }) async {
    try {
      final json = await _api.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        method: method,
      );
      return PaymentModel.fromJson(json);
    } catch (e) {
      throw PaymentFailure(e.toString());
    }
  }

  @override
  Future<Payment> processPayment({
    required String paymentId,
    required bool simulateSuccess,
  }) async {
    try {
      final json = await _api.processPayment(
        paymentId: paymentId,
        simulateSuccess: simulateSuccess,
      );
      return PaymentModel.fromJson(json);
    } on PaymentException catch (e) {
      throw PaymentFailure(e.message);
    }
  }

  @override
  Future<Payment?> getPaymentForBooking(String bookingId) async {
    try {
      await _api.ensureInitialized();
      final json = await _api.paymentForBooking(bookingId);
      if (json == null) return null;
      return PaymentModel.fromJson(json);
    } catch (e) {
      throw PaymentFailure(e.toString());
    }
  }
}
