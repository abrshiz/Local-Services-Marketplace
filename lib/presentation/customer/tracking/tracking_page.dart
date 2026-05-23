import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/empty_state.dart';
import 'package:localservicemarket/core/widgets/section_header.dart';
import 'package:localservicemarket/core/widgets/status_chip.dart';
import 'package:localservicemarket/domain/entities/booking.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/presentation/customer/review/review_sheet.dart';
import 'package:localservicemarket/presentation/customer/tracking/bloc/tracking_cubit.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key, required this.customer});

  final Customer customer;

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  void initState() {
    super.initState();
    context.read<TrackingCubit>().load(widget.customer.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        if (state.status == TrackingStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state.bookings.isEmpty) {
          return const EmptyState(
            icon: Icons.calendar_month_outlined,
            title: 'No bookings yet',
            subtitle: 'Discover services and book your first appointment.',
          );
        }

        final active =
            context.read<TrackingCubit>().activeBooking(state.bookings);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              context.read<TrackingCubit>().load(widget.customer.userId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              if (active != null) ...[
                const SectionHeader(title: 'Live tracking'),
                _LiveTrackingCard(booking: active),
                const SizedBox(height: 20),
              ],
              const SectionHeader(title: 'All bookings'),
              ...state.bookings.map(
                (b) => _BookingTile(
                  booking: b,
                  onReview: b.status == BookingStatus.completed
                      ? () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ReviewSheet(
                              booking: b,
                              customer: widget.customer,
                            ),
                          )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveTrackingCard extends StatelessWidget {
  const _LiveTrackingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Requested', true),
      ('Confirmed', booking.status.index >= BookingStatus.confirmed.index),
      (
        'In progress',
        booking.serviceStartedAt != null &&
            booking.status != BookingStatus.completed,
      ),
      ('Completed', booking.status == BookingStatus.completed),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Service in progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.asMap().entries.map((e) {
            final done = e.value.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done
                          ? AppColors.success
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done ? AppColors.success : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check_rounded : Icons.circle,
                      size: 16,
                      color: done
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    e.value.$1,
                    style: TextStyle(
                      fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                      color: done
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking, this.onReview});

  final Booking booking;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMd().add_jm();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onReview,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fmt.format(booking.scheduledTime.toLocal()),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${booking.totalPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (onReview != null)
                    const Text(
                      'Tap to leave a review',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            StatusChip(status: booking.status),
          ],
        ),
      ),
    );
  }
}
