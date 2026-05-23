import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
          return const Center(child: CircularProgressIndicator());
        }
        if (state.bookings.isEmpty) {
          return const Center(child: Text('No bookings yet'));
        }

        final active = context.read<TrackingCubit>().activeBooking(state.bookings);

        return RefreshIndicator(
          onRefresh: () =>
              context.read<TrackingCubit>().load(widget.customer.userId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active != null) ...[
                Text(
                  'Live status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _LiveTrackingCard(booking: active),
                const SizedBox(height: 24),
              ],
              Text(
                'All bookings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...state.bookings.map(
                (b) => _BookingTile(
                  booking: b,
                  onReview: b.status == BookingStatus.completed
                      ? () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Service tracking',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                StatusChip(status: booking.status),
              ],
            ),
            const SizedBox(height: 16),
            ...steps.map(
              (s) => ListTile(
                dense: true,
                leading: Icon(
                  s.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: s.$2 ? Colors.green : Colors.grey,
                ),
                title: Text(s.$1),
              ),
            ),
          ],
        ),
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
    final fmt = DateFormat.yMMMd().add_jm();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(fmt.format(booking.scheduledTime.toLocal())),
        subtitle: Text('\$${booking.totalPrice.toStringAsFixed(0)}'),
        trailing: StatusChip(status: booking.status),
        onTap: onReview,
      ),
    );
  }
}
