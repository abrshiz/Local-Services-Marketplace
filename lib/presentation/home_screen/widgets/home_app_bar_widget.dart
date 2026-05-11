import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: theme.colorScheme.surface,
      shadowColor: theme.colorScheme.outline,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_repair_service_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'LocalService',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        background: Container(color: theme.colorScheme.surface),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to notifications screen
          },
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: theme.colorScheme.onSurface,
                size: 26,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              // Logout: navigate back to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signUpLoginScreen,
                (route) => false,
              );
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.primaryContainer,
              child: Text(
                'A',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
