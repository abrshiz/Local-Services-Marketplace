import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocProvider(
        create: (_) => sl<PaymentCubit>(),
        child: BlocConsumer<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state.status == PaymentFlowStatus.success) {
              Navigator.pop(context, true);
            }
            if (state.status == PaymentFlowStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Payment failed')),
              );
            }
          },
          builder: (context, state) {
            final processing = state.status == PaymentFlowStatus.processing;
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure checkout',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Encrypted payment',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Card number',
                      hintText: '4242 4242 4242 4242',
                      prefixIcon: Icon(Icons.credit_card_rounded),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'MM / YY'),
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
                  const SizedBox(height: 8),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: CheckboxListTile(
                      value: _simulateFailure,
                      onChanged: processing
                          ? null
                          : (v) => setState(() => _simulateFailure = v ?? false),
                      title: const Text('Simulate decline (demo)'),
                      activeColor: AppColors.primary,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pay now'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
