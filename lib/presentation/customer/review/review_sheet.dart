import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/customer/review/bloc/review_cubit.dart';

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({
    super.key,
    required this.booking,
    required this.customer,
  });

  final Booking booking;
  final Customer customer;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocProvider(
        create: (_) {
          final cubit = sl<ReviewCubit>();
          cubit.checkExisting(widget.booking.bookingId);
          return cubit;
        },
        child: BlocConsumer<ReviewCubit, ReviewState>(
          listener: (context, state) {
            if (state.status == ReviewFlowStatus.success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thanks for your review!')),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ReviewFlowStatus.alreadySubmitted) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'You already reviewed this booking.',
                  textAlign: TextAlign.center,
                ),
              );
            }

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
                  Text(
                    'Rate your experience',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How was the service?',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        icon: Icon(
                          star <= state.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 40,
                        ),
                        onPressed: () =>
                            context.read<ReviewCubit>().setRating(star),
                      );
                    }),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Comment (optional)',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    onChanged: context.read<ReviewCubit>().setComment,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: state.status == ReviewFlowStatus.submitting
                        ? null
                        : () => context.read<ReviewCubit>().submit(
                              bookingId: widget.booking.bookingId,
                              reviewerId: widget.customer.userId,
                              providerId: widget.booking.providerId,
                            ),
                    child: state.status == ReviewFlowStatus.submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit review'),
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
