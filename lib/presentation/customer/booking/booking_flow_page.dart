import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/customer/booking/bloc/booking_cubit.dart';
import 'package:localservicemarket/presentation/customer/booking/bloc/booking_state.dart';
import 'package:localservicemarket/presentation/customer/payment/payment_sheet.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({
    super.key,
    required this.customer,
    required this.provider,
    required this.service,
  });

  final Customer customer;
  final ServiceProvider provider;
  final Service service;

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _payOnline = true;

  String? get _addressId =>
      widget.customer.defaultAddressId ??
      (widget.customer.savedAddresses.isNotEmpty
          ? widget.customer.savedAddresses.first.addressId
          : null);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<BookingCubit>();
        cubit.loadSlots(
          providerId: widget.provider.userId,
          day: _selectedDay,
        );
        return cubit;
      },
      child: BlocConsumer<BookingCubit, CustomerBookingState>(
        listener: (context, state) async {
          if (state.status == CustomerBookingStatus.failure &&
              state.errorMessage != null) {
            await showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Booking unavailable'),
                content: Text(state.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
          if (state.status == CustomerBookingStatus.success &&
              state.createdBooking != null) {
            if (!context.mounted) return;
            if (_payOnline) {
              final paid = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => PaymentSheet(
                  bookingId: state.createdBooking!.bookingId,
                  amount: state.createdBooking!.totalPrice,
                ),
              );
              if (!context.mounted) return;
              if (paid == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking confirmed & paid')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Request sent — provider will confirm (cash on service)',
                  ),
                ),
              );
            }
            if (context.mounted) Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book service')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    title: Text(widget.service.title),
                    subtitle: Text(widget.provider.name),
                    trailing: Text(
                      '\$${widget.service.basePrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    context.read<BookingCubit>().loadSlots(
                          providerId: widget.provider.userId,
                          day: selected,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Available slots',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.status == CustomerBookingStatus.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.slots.isEmpty)
                  const Text('No slots for this day')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.slots.map((slot) {
                      final selected =
                          state.selectedSlot?.slotId == slot.slotId;
                      final fmt = DateFormat.jm();
                      return ChoiceChip(
                        label: Text(fmt.format(slot.startTime.toLocal())),
                        selected: selected,
                        onSelected: (_) =>
                            context.read<BookingCubit>().selectSlot(slot),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notes for provider',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onChanged: context.read<BookingCubit>().setNotes,
                ),
                SwitchListTile(
                  title: const Text('Pay online (card)'),
                  subtitle: const Text('Off = cash — awaits provider accept'),
                  value: _payOnline,
                  onChanged: (v) => setState(() => _payOnline = v),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.status == CustomerBookingStatus.submitting
                      ? null
                      : () {
                          final addr = _addressId;
                          if (addr == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No address on file'),
                              ),
                            );
                            return;
                          }
                          context.read<BookingCubit>().submitBooking(
                                customerId: widget.customer.userId,
                                providerId: widget.provider.userId,
                                serviceId: widget.service.serviceId,
                                addressId: addr,
                                totalPrice: widget.service.basePrice,
                              );
                        },
                  child: state.status == CustomerBookingStatus.submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Request booking'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
