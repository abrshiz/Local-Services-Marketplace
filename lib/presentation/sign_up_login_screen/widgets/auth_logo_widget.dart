import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_export.dart';

class AuthLogoWidget extends StatelessWidget {
  final bool isOnDark;
  const AuthLogoWidget({super.key, this.isOnDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: isOnDark
                ? Colors.white.withAlpha(38)
                : AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: isOnDark
                ? Border.all(color: Colors.white.withAlpha(77), width: 1.5)
                : null,
          ),
          child: Icon(
            Icons.home_repair_service_rounded,
            color: isOnDark ? Colors.white : AppTheme.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Local Service',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isOnDark ? Colors.white : theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your trusted local services marketplace',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isOnDark
                ? Colors.white.withAlpha(204)
                : theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
