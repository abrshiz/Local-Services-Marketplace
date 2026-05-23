import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/presentation/customer/payment/bloc/payment_cubit.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  final String bookingId;
  final double amount;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  bool _simulateFailure = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentCubit>(),
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentFlowStatus.success) {
            Navigator.pop(context, true);
          }
          if (state.status == PaymentFlowStatus.failure) {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Payment failed'),
                content: Text(state.errorMessage ?? 'Try again'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final processing = state.status == PaymentFlowStatus.processing;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Secure payment',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('\$${widget.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Card number',
                    hintText: '4242 4242 4242 4242',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'MM/YY'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'CVC'),
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  value: _simulateFailure,
                  onChanged: processing
                      ? null
                      : (v) => setState(() => _simulateFailure = v ?? false),
                  title: const Text('Simulate decline (demo)'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: processing
                      ? null
                      : () => context.read<PaymentCubit>().payOnline(
                            bookingId: widget.bookingId,
                            amount: widget.amount,
                            simulateSuccess: !_simulateFailure,
                          ),
                  child: processing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Pay now'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
