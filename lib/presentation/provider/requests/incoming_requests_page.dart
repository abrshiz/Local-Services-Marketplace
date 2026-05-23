import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/empty_state.dart';
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
          return const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'Inbox zero',
            subtitle: 'New booking requests will appear here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: state.pending.length,
          itemBuilder: (context, i) {
            final b = state.pending[i];
            final fmt = DateFormat.MMMd().add_jm();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(b.bookingId),
                direction: DismissDirection.horizontal,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.success),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close_rounded, color: AppColors.error),
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
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              Icons.notifications_active_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fmt.format(b.scheduledTime.toLocal()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const StatusChip(status: BookingStatus.pending),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${b.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      if (b.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          b.notes,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context
                                  .read<ProviderDashboardCubit>()
                                  .reject(b.bookingId),
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () => context
                                  .read<ProviderDashboardCubit>()
                                  .accept(b.bookingId),
                              child: const Text('Accept'),
                            ),
                          ),
                        ],
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
