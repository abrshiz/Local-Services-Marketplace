import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/empty_state.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Search')),
      body: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, state) {
          if (state.providers.isEmpty) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              subtitle: 'Try a different search term or filter.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.providers.length,
            itemBuilder: (context, i) {
              final p = state.providers[i];
              final service = state.services
                  .where((s) => s.providerId == p.userId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          p.name[0],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text('${p.averageRating} ★ rating'),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
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
