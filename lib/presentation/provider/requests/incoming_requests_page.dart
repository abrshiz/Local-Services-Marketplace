import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/widgets/status_chip.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/presentation/provider/dashboard/bloc/provider_dashboard_cubit.dart';

class IncomingRequestsPage extends StatelessWidget {
  const IncomingRequestsPage({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderDashboardCubit, ProviderDashboardState>(
      builder: (context, state) {
        if (state.pending.isEmpty) {
          return const Center(
            child: Text('No pending requests — pull to refresh on Dashboard'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.pending.length,
          itemBuilder: (context, i) {
            final b = state.pending[i];
            final fmt = DateFormat.yMMMd().add_jm();
            return Dismissible(
              key: ValueKey(b.bookingId),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.green.shade100,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 24),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              secondaryBackground: Container(
                color: Colors.red.shade100,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.close, color: Colors.red),
              ),
              confirmDismiss: (dir) async {
                final cubit = context.read<ProviderDashboardCubit>();
                if (dir == DismissDirection.startToEnd) {
                  await cubit.accept(b.bookingId);
                } else {
                  await cubit.reject(b.bookingId);
                }
                return false;
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fmt.format(b.scheduledTime.toLocal()),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const StatusChip(status: BookingStatus.pending),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('\$${b.totalPrice.toStringAsFixed(0)}'),
                      if (b.notes.isNotEmpty) Text('Notes: ${b.notes}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context
                                  .read<ProviderDashboardCubit>()
                                  .reject(b.bookingId),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => context
                                  .read<ProviderDashboardCubit>()
                                  .accept(b.bookingId),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tip: swipe right to accept, left to reject',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
