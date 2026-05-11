import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AuthRoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const AuthRoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a...',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _RoleOption(
              icon: 'person',
              label: 'Customer',
              subtitle: 'Book services',
              value: 'customer',
              selectedValue: selectedRole,
              onTap: () => onRoleChanged('customer'),
            ),
            const SizedBox(width: 10),
            _RoleOption(
              icon: 'business',
              label: 'Service Provider',
              subtitle: 'Offer services',
              value: 'provider',
              selectedValue: selectedRole,
              onTap: () => onRoleChanged('provider'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryContainer
                : AppTheme.surfaceVariantLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.outlineLight,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(38),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.outlineLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppTheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
