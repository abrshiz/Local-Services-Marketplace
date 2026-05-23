import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ProviderDashboardCubit>().load(widget.provider.userId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Earnings',
                      value: '\$${state.earnings.toStringAsFixed(0)}',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: '${state.pending.length}',
                      icon: Icons.pending_actions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Calendar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Card(
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
              const SizedBox(height: 8),
              Text(
                'Slots on ${DateFormat.MMMd().format(_selectedDay)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...state.slots.map(
                (s) => ListTile(
                  dense: true,
                  leading: Icon(
                    s.isAvailable ? Icons.event_available : Icons.event_busy,
                    color: s.isAvailable ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    '${DateFormat.jm().format(s.startTime.toLocal())} – '
                    '${DateFormat.jm().format(s.endTime.toLocal())}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Active jobs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...state.allBookings
                  .where((b) =>
                      b.status == BookingStatus.confirmed ||
                      (b.serviceStartedAt != null &&
                          b.status != BookingStatus.completed))
                  .map((b) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  DateFormat.jm()
                                      .format(b.scheduledTime.toLocal()),
                                ),
                                trailing: StatusChip(status: b.status),
                                subtitle: b.serviceStartedAt == null
                                    ? const Text('Not started')
                                    : const Text('In progress'),
                              ),
                              if (b.status == BookingStatus.confirmed &&
                                  b.serviceStartedAt == null)
                                OutlinedButton(
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
                                  child: const Text('Complete service'),
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
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
