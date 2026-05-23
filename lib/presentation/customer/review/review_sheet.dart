import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
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
    return BlocProvider(
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
              padding: EdgeInsets.all(32),
              child: Text('You already reviewed this booking.'),
            );
          }

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
                  'Rate your service',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      icon: Icon(
                        star <= state.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () =>
                          context.read<ReviewCubit>().setRating(star),
                    );
                  }),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                  ),
                  maxLines: 3,
                  onChanged: context.read<ReviewCubit>().setComment,
                ),
                const SizedBox(height: 16),
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
