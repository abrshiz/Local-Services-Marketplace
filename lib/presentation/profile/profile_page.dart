import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:localservicemarket/core/config/app_config.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/theme/theme_cubit.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/domain/entities/address.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});

  final User user;

  Future<void> _confirmLogout(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer = user is Customer;
    final isProvider = user is ServiceProvider;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        AppCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role == UserRole.provider ? 'Service provider' : 'Customer',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            final isDark = mode == ThemeMode.dark;
            return AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Easier on your eyes at night'),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                value: isDark,
                onChanged: (v) => context.read<ThemeCubit>().setDark(v),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              Icons.cloud_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Backend API'),
            subtitle: Text(
              AppConfig.useMockApi
                  ? 'Offline mock (development only)'
                  : AppConfig.apiBaseUrl,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            dense: true,
          ),
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Account',
          children: [
            _InfoTile(
              icon: Icons.alternate_email_rounded,
              label: 'Email',
              value: user.email,
            ),
            _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: user.phone.isNotEmpty ? user.phone : '—',
            ),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member since',
              value: DateFormat.yMMMM().format(user.createdAt.toLocal()),
            ),
          ],
        ),
        if (isCustomer) ...[
          Builder(
            builder: (context) {
              final customer = user as Customer;
              Address? defaultAddr;
              for (final a in customer.savedAddresses) {
                if (a.addressId == customer.defaultAddressId) {
                  defaultAddr = a;
                  break;
                }
              }
              defaultAddr ??=
                  customer.savedAddresses.isNotEmpty
                      ? customer.savedAddresses.first
                      : null;
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Rewards',
                    children: [
                      _InfoTile(
                        icon: Icons.stars_rounded,
                        label: 'Loyalty points',
                        value: '${customer.loyaltyPoints}',
                      ),
                      if (defaultAddr != null)
                        _InfoTile(
                          icon: Icons.home_outlined,
                          label: 'Default address',
                          value: defaultAddr.fullLine,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
        if (isProvider) ...[
          Builder(
            builder: (context) {
              final provider = user as ServiceProvider;
              return Column(
                children: [
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Provider',
                    children: [
                      _InfoTile(
                        icon: Icons.star_rounded,
                        label: 'Rating',
                        value: provider.averageRating.toStringAsFixed(1),
                      ),
                      _InfoTile(
                        icon: Icons.verified_user_outlined,
                        label: 'Verification',
                        value: provider.isVerified ? 'Verified' : 'Pending',
                      ),
                      if (provider.bio.isNotEmpty)
                        _InfoTile(
                          icon: Icons.info_outline_rounded,
                          label: 'Bio',
                          value: provider.bio,
                        ),
                      if (provider.skills.isNotEmpty)
                        _InfoTile(
                          icon: Icons.handyman_outlined,
                          label: 'Skills',
                          value: provider.skills.map((s) => s.name).join(', '),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          label: const Text(
            'Sign out',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.error),
            backgroundColor: AppColors.error.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
