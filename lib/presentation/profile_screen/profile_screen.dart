import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/profile_menu_item_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(theme),
            const SizedBox(height: 32),
            _buildSection(theme, 'Account', [
              ProfileMenuItemWidget(icon: Icons.person_outline_rounded, label: 'Personal Information', onTap: () {}),
              ProfileMenuItemWidget(icon: Icons.payment_rounded, label: 'Payment Methods', onTap: () {}),
              ProfileMenuItemWidget(icon: Icons.location_on_outlined, label: 'Saved Addresses', onTap: () {}),
            ]),
            const SizedBox(height: 24),
            _buildSection(theme, 'Settings', [
              ProfileMenuItemWidget(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () {}),
              ProfileMenuItemWidget(icon: Icons.security_rounded, label: 'Security', onTap: () {}),
              ProfileMenuItemWidget(icon: Icons.language_rounded, label: 'Language', onTap: () {}),
            ]),
            const SizedBox(height: 24),
            _buildSection(theme, 'Support', [
              ProfileMenuItemWidget(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: () {}),
              ProfileMenuItemWidget(icon: Icons.description_outlined, label: 'Privacy Policy', onTap: () {}),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.signUpLoginScreen,
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53935)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF3E5F5),
                child: Text(
                  'A',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                ),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Alex Johnson',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          'alex.johnson@example.com',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}
