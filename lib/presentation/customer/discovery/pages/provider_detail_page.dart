import 'package:flutter/material.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/core/widgets/star_rating.dart';
import 'package:localservicemarket/domain/entities/provider_profile.dart';
import 'package:localservicemarket/domain/entities/provider_review.dart';
import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/domain/repositories/chat_repository.dart';
import 'package:localservicemarket/domain/repositories/discovery_repository.dart';
import 'package:localservicemarket/presentation/chat/chat_thread_page.dart';
import 'package:localservicemarket/presentation/customer/booking/booking_flow_page.dart';

class ProviderDetailPage extends StatefulWidget {
  const ProviderDetailPage({
    super.key,
    required this.customer,
    required this.provider,
  });

  final Customer customer;
  final ServiceProvider provider;

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  late Future<({ProviderProfile profile, List<ProviderReview> reviews})> _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final discovery = sl<DiscoveryRepository>();
    _data = () async {
      final profile = await discovery.getProviderProfile(widget.provider.userId);
      final reviews = await discovery.getProviderReviews(widget.provider.userId);
      return (profile: profile, reviews: reviews);
    }();
  }

  Future<void> _messageProvider(ServiceProvider provider) async {
    try {
      final conv = await sl<ChatRepository>().openConversation(provider.userId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ChatThreadPage(
            conversationId: conv.conversationId,
            peerName: provider.name,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<({ProviderProfile profile, List<ProviderReview> reviews})>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load provider'),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: () => setState(_load), child: const Text('Retry')),
                ],
              ),
            );
          }
          final profile = snapshot.data!.profile;
          final reviews = snapshot.data!.reviews;
          final p = profile.provider;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          StarRating(
                            rating: p.averageRating,
                            reviewCount: profile.reviewCount,
                          ),
                          const Spacer(),
                          if (p.isVerified)
                            const Chip(
                              avatar: Icon(Icons.verified_rounded, size: 18),
                              label: Text('Verified'),
                            ),
                        ],
                      ),
                      if (p.distanceKm != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p.distanceKm!.toStringAsFixed(1)} km away',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      if (p.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(p.bio, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                      if (p.skills.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: p.skills
                              .map((s) => Chip(label: Text(s.name)))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _messageProvider(p),
                              icon: const Icon(Icons.chat_bubble_outline_rounded),
                              label: const Text('Message'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Services',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (profile.services.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('No services listed yet.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final s = profile.services[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _ServiceTile(
                          service: s,
                          onBook: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BookingFlowPage(
                                customer: widget.customer,
                                provider: p,
                                service: s,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: profile.services.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              if (reviews.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Text('No reviews yet.'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final r = reviews[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    r.reviewerName,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  StarRating(
                                    rating: r.rating.toDouble(),
                                    showValue: false,
                                    size: 16,
                                  ),
                                ],
                              ),
                              if (r.comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(r.comment),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onBook});

  final Service service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final priceLabel = service.priceType == PriceType.hourly
        ? '\$${service.basePrice.toStringAsFixed(0)}/hr'
        : '\$${service.basePrice.toStringAsFixed(0)}';
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onBook,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(88, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Book'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
