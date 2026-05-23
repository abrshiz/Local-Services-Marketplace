import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/section_header.dart';
import 'package:localservicemarket/core/widgets/status_chip.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/presentation/provider/dashboard/bloc/provider_dashboard_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<ProviderDashboardCubit>().load(widget.provider.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderDashboardCubit, ProviderDashboardState>(
      builder: (context, state) {
        if (state.status == ProviderDashStatus.loading &&
            state.allBookings.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () =>
              context.read<ProviderDashboardCubit>().load(widget.provider.userId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total earnings',
                      value: '\$${state.earnings.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: '${state.pending.length}',
                      icon: Icons.hourglass_top_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SectionHeader(title: 'Schedule'),
              AppCard(
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 30)),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    context
                        .read<ProviderDashboardCubit>()
                        .loadCalendarDay(selected);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  DateFormat.MMMd().format(_selectedDay),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...state.slots.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          s.isAvailable
                              ? Icons.event_available_rounded
                              : Icons.event_busy_rounded,
                          color: s.isAvailable
                              ? AppColors.success
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${DateFormat.jm().format(s.startTime.toLocal())} – '
                          '${DateFormat.jm().format(s.endTime.toLocal())}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Active jobs'),
              ...state.allBookings
                  .where((b) =>
                      b.status == BookingStatus.confirmed ||
                      (b.serviceStartedAt != null &&
                          b.status != BookingStatus.completed))
                  .map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat.jm()
                                          .format(b.scheduledTime.toLocal()),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  StatusChip(status: b.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                b.serviceStartedAt == null
                                    ? 'Ready to start'
                                    : 'Service in progress',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              if (b.status == BookingStatus.confirmed &&
                                  b.serviceStartedAt == null)
                                FilledButton(
                                  onPressed: () => context
                                      .read<ProviderDashboardCubit>()
                                      .startService(b.bookingId),
                                  child: const Text('Start service'),
                                ),
                              if (b.serviceStartedAt != null &&
                                  b.status != BookingStatus.completed)
                                FilledButton(
                                  onPressed: () => context
                                      .read<ProviderDashboardCubit>()
                                      .completeService(b.bookingId),
                                  child: const Text('Mark complete'),
                                ),
                            ],
                          ),
                        ),
                      )),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
