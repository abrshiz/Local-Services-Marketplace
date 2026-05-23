import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/widgets/shimmer_box.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/presentation/customer/booking/booking_flow_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_state.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/search_results_page.dart';

class DiscoveryHomePage extends StatefulWidget {
  const DiscoveryHomePage({super.key, required this.customer});

  final Customer customer;

  @override
  State<DiscoveryHomePage> createState() => _DiscoveryHomePageState();
}

class _DiscoveryHomePageState extends State<DiscoveryHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryCubit>().load();
  }

  IconData _iconFor(String iconUrl) {
    switch (iconUrl) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'yard':
        return Icons.yard;
      default:
        return Icons.cleaning_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        if (state.status == DiscoveryStatus.loading &&
            state.categories.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerBox(height: 48),
              SizedBox(height: 16),
              ShimmerBox(height: 120),
              SizedBox(height: 12),
              ShimmerBox(height: 120),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<DiscoveryCubit>().load(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SearchBar(
                    hintText: 'Search providers or services',
                    onSubmitted: (q) {
                      context.read<DiscoveryCubit>().setQuery(q);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: context.read<DiscoveryCubit>(),
                            child: SearchResultsPage(customer: widget.customer),
                          ),
                        ),
                      );
                    },
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () => _showFilters(context, state),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = state.categories[i];
                      final selected = state.selectedCategoryId == cat.categoryId;
                      return Card(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.read<DiscoveryCubit>().setCategory(
                                selected ? null : cat.categoryId,
                              ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(_iconFor(cat.iconUrl), size: 28),
                                const Spacer(),
                                Text(
                                  cat.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  cat.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: state.categories.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Nearby providers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final provider = state.providers[i];
                    final services = state.services
                        .where((s) => s.providerId == provider.userId)
                        .toList();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(provider.name[0]),
                        ),
                        title: Text(provider.name),
                        subtitle: Text(
                          '${provider.averageRating.toStringAsFixed(1)} ★ · '
                          '${provider.skills.map((s) => s.name).join(', ')}',
                        ),
                        trailing: provider.isVerified
                            ? const Icon(Icons.verified, color: Colors.blue)
                            : null,
                        onTap: services.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => BookingFlowPage(
                                      customer: widget.customer,
                                      provider: provider,
                                      service: services.first,
                                    ),
                                  ),
                                ),
                      ),
                    );
                  },
                  childCount: state.providers.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  void _showFilters(BuildContext context, DiscoveryState state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        var minRating = state.minRating ?? 0.0;
        PriceType? priceType = state.priceTypeFilter;
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Min rating: ${minRating.toStringAsFixed(1)}'),
                  Slider(
                    value: minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: minRating.toStringAsFixed(1),
                    onChanged: (v) => setModal(() => minRating = v),
                  ),
                  DropdownButtonFormField<PriceType?>(
                    initialValue: priceType,
                    decoration: const InputDecoration(labelText: 'Price type'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any')),
                      DropdownMenuItem(
                        value: PriceType.fixed,
                        child: Text('Fixed'),
                      ),
                      DropdownMenuItem(
                        value: PriceType.hourly,
                        child: Text('Hourly'),
                      ),
                    ],
                    onChanged: (v) => setModal(() => priceType = v),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.read<DiscoveryCubit>().setFilters(
                            minRating: minRating > 0 ? minRating : null,
                            priceType: priceType,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
