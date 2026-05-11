import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class HomeFeaturedServicesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final bool isLoading;
  final bool isTablet;
  final Function(Map<String, dynamic>) onServiceTap;

  const HomeFeaturedServicesWidget({
    super.key,
    required this.services,
    required this.isLoading,
    required this.onServiceTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxisCount = isTablet ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Services',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View all',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => const ServiceCardSkeletonWidget(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _ServiceCard(
                  service: services[index],
                  onTap: () => onServiceTap(services[index]),
                  animationDelay: index * 60,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;
  final int animationDelay;

  const _ServiceCard({
    required this.service,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = widget.service;
    final rating = service['rating'] as double;
    final price = service['basePrice'] as double;
    final isHourly = service['priceType'] == 'HOURLY';
    final isVerified = service['isVerified'] as bool;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CustomImageWidget(
                          imageUrl: service['serviceImageUrl'] as String,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                          semanticLabel:
                              service['serviceSemanticLabel'] as String,
                        ),
                      ),
                      if (isVerified)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                service['distance'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ClipOval(
                              child: CustomImageWidget(
                                imageUrl: service['providerImageUrl'] as String,
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    service['providerSemanticLabel'] as String,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                service['providerName'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB300),
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isHourly
                                  ? '\$${price.toInt()}/hr'
                                  : '\$${price.toInt()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
