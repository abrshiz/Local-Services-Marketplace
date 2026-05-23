import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/theme/theme_extensions.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/star_rating.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/provider_detail_page.dart';
import 'package:localservicemarket/core/widgets/section_header.dart';
import 'package:localservicemarket/core/widgets/shimmer_box.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
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
        return Icons.plumbing_rounded;
      case 'electrical_services':
        return Icons.electrical_services_rounded;
      case 'yard':
        return Icons.yard_rounded;
      default:
        return Icons.cleaning_services_rounded;
    }
  }

  Color _accentFor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.accent,
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        if (state.status == DiscoveryStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 48, color: scheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Could not load providers',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.read<DiscoveryCubit>().load(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.status == DiscoveryStatus.loading &&
            state.categories.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              ShimmerBox(height: 52, borderRadius: 14),
              SizedBox(height: 20),
              ShimmerBox(height: 100),
              SizedBox(height: 12),
              ShimmerBox(height: 100),
            ],
          );
        }

        return RefreshIndicator(
          color: scheme.primary,
          onRefresh: () => context.read<DiscoveryCubit>().load(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: SearchBar(
                    hintText: 'Search services or providers…',
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
                    leading: Icon(
                      Icons.search_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: () => _showFilters(context, state),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: 'Categories'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = state.categories[i];
                      final selected =
                          state.selectedCategoryId == cat.categoryId;
                      final accent = _accentFor(i);
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        color: selected ? scheme.primaryContainer : null,
                        onTap: () => context.read<DiscoveryCubit>().setCategory(
                              selected ? null : cat.categoryId,
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_iconFor(cat.iconUrl), color: accent),
                            ),
                            const Spacer(),
                            Text(
                              cat.name,
                              style: context.titleOnSurface.copyWith(fontSize: 15),
                            ),
                            Text(
                              cat.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: state.categories.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Nearby providers',
                    actionLabel: '${state.providers.length} found',
                  ),
                ),
              ),
              if (state.providers.isEmpty && state.status == DiscoveryStatus.loaded)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No providers found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try another category or pull to refresh.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
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
                    final price = services.isNotEmpty
                        ? services.map((s) => s.basePrice).reduce((a, b) => a < b ? a : b)
                        : null;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: AppCard(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ProviderDetailPage(
                                  customer: widget.customer,
                                  provider: provider,
                                ),
                              ),
                            ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: scheme.primaryContainer,
                              child: Text(
                                provider.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.name,
                                          style: context.titleOnSurface.copyWith(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (provider.isVerified)
                                        const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.accent,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  StarRating(
                                    rating: provider.averageRating,
                                    size: 16,
                                  ),
                                  if (provider.distanceKm != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${provider.distanceKm!.toStringAsFixed(1)} km away',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.skills.map((s) => s.name).join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (price != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: state.providers.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Minimum rating · ${minRating.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setModal(() => minRating = v),
                  ),
                  DropdownButtonFormField<PriceType?>(
                    initialValue: priceType,
                    decoration: const InputDecoration(labelText: 'Price type'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Any')),
                      DropdownMenuItem(
                        value: PriceType.fixed,
                        child: Text('Fixed price'),
                      ),
                      DropdownMenuItem(
                        value: PriceType.hourly,
                        child: Text('Hourly'),
                      ),
                    ],
                    onChanged: (v) => setModal(() => priceType = v),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      context.read<DiscoveryCubit>().setFilters(
                            minRating: minRating > 0 ? minRating : null,
                            priceType: priceType,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Apply filters'),
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
