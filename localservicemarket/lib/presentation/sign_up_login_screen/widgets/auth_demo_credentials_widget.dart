import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AuthDemoCredentialsWidget extends StatelessWidget {
  final Function(String email, String password) onCredentialSelected;

  const AuthDemoCredentialsWidget({
    super.key,
    required this.onCredentialSelected,
  });

  static const List<Map<String, String>> _credentials = [
    {
      'role': 'Customer',
      'email': 'alex.carter@localservice.app',
      'password': 'Service@2026',
    },
    {
      'role': 'Provider',
      'email': 'maria.santos@localservice.app',
      'password': 'Provider@2026',
    },
    {
      'role': 'Admin',
      'email': 'admin@localservice.app',
      'password': 'Admin@2026!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withAlpha(51), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Demo Accounts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._credentials.map(
            (cred) => _CredentialRow(
              credential: cred,
              onTap: () =>
                  onCredentialSelected(cred['email']!, cred['password']!),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final Map<String, String> credential;
  final VoidCallback onTap;

  const _CredentialRow({required this.credential, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                credential['role']!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    credential['email']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    credential['password']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: credential['email']!));
                onTap();
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
