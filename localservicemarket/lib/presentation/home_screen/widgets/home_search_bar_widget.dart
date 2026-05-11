import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const HomeSearchBarWidget({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Downtown, New York',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find a Service',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Search services, providers...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(77),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
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
