import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/entities/payment.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/repositories/payment_repository.dart';

enum PaymentFlowStatus { initial, processing, success, failure }

class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentFlowStatus.initial,
    this.payment,
    this.errorMessage,
  });

  final PaymentFlowStatus status;
  final Payment? payment;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, payment, errorMessage];
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._payments) : super(const PaymentState());

  final PaymentRepository _payments;

  Future<void> payOnline({
    required String bookingId,
    required double amount,
    PaymentMethod method = PaymentMethod.card,
    bool simulateSuccess = true,
  }) async {
    emit(const PaymentState(status: PaymentFlowStatus.processing));
    try {
      final initiated = await _payments.initiatePayment(
        bookingId: bookingId,
        amount: amount,
        method: method,
      );
      final result = await _payments.processPayment(
        paymentId: initiated.paymentId,
        simulateSuccess: simulateSuccess,
      );
      emit(PaymentState(status: PaymentFlowStatus.success, payment: result));
    } on PaymentFailure catch (e) {
      emit(PaymentState(
        status: PaymentFlowStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  void reset() => emit(const PaymentState());
}
