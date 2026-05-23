import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/theme/theme_extensions.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/empty_state.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/core/widgets/star_rating.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/provider_detail_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_state.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ProviderDetailPage(
                            customer: customer,
                            provider: p,
                          ),
                        ),
                      ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          p.name[0],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
                              style: context.titleOnSurface,
                            ),
                            StarRating(rating: p.averageRating, size: 14),
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
