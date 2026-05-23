import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/customer/booking/booking_flow_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_state.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search results')),
      body: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, state) {
          if (state.providers.isEmpty) {
            return const Center(child: Text('No providers match your search'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.providers.length,
            itemBuilder: (context, i) {
              final p = state.providers[i];
              final service = state.services
                  .where((s) => s.providerId == p.userId)
                  .firstOrNull;
              return Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('Rating ${p.averageRating}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: service == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BookingFlowPage(
                                customer: customer,
                                provider: p,
                                service: service,
                              ),
                            ),
                          ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
