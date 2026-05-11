import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class HomeNearbyProvidersWidget extends StatelessWidget {
  final bool isLoading;

  const HomeNearbyProvidersWidget({super.key, required this.isLoading});

  static final List<Map<String, dynamic>> _providersMaps = [
    {
      'providerId': 'pvd_001',
      'name': 'Maria Santos',
      'skill': 'Cleaning Expert',
      'rating': 4.8,
      'reviewCount': 124,
      'distance': '1.2 km',
      'isVerified': true,
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_115651084-1764892528190.png',
      'semanticLabel':
          'Professional female cleaner with brown hair smiling in uniform',
      'isAvailable': true,
    },
    {
      'providerId': 'pvd_002',
      'name': 'James Okonkwo',
      'skill': 'Master Plumber',
      'rating': 4.6,
      'reviewCount': 89,
      'distance': '0.8 km',
      'isVerified': true,
      'imageUrl':
          'https://images.unsplash.com/photo-1659353591742-9fa64d94738e',
      'semanticLabel':
          'Middle-aged African man in blue work uniform holding wrench',
      'isAvailable': false,
    },
    {
      'providerId': 'pvd_003',
      'name': 'Priya Nair',
      'skill': 'Electrician',
      'rating': 4.9,
      'reviewCount': 203,
      'distance': '2.4 km',
      'isVerified': true,
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_125538482-1766485545000.png',
      'semanticLabel':
          'Young Indian woman electrician in safety gear with tools',
      'isAvailable': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Nearby Providers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See all',
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => LoadingSkeletonWidget(
              width: double.infinity,
              height: 72,
              borderRadius: 14,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _providersMaps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final provider = _providersMaps[index];
              return _ProviderListItem(provider: provider);
            },
          ),
      ],
    );
  }
}

class _ProviderListItem extends StatelessWidget {
  final Map<String, dynamic> provider;

  const _ProviderListItem({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = provider['isAvailable'] as bool;
    final isVerified = provider['isVerified'] as bool;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: CustomImageWidget(
                  imageUrl: provider['imageUrl'] as String,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  semanticLabel: provider['semanticLabel'] as String,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppTheme.success
                        : theme.colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      provider['name'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        color: AppTheme.primary,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  provider['skill'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB300),
                      size: 13,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      (provider['rating'] as double).toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      ' (${provider['reviewCount']})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      provider['distance'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? AppTheme.successContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Busy',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? AppTheme.success
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
