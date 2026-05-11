
import '../core/app_export.dart';

class AppNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const AppNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    if (isTablet) {
      return NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        destinations: const [
          NavigationRailDestination(
            icon: CustomIconWidget(iconName: 'home_outlined'),
            selectedIcon: CustomIconWidget(iconName: 'home'),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: CustomIconWidget(iconName: 'calendar_outlined'),
            selectedIcon: CustomIconWidget(iconName: 'calendar_today'),
            label: Text('Bookings'),
          ),
          NavigationRailDestination(
            icon: CustomIconWidget(iconName: 'chat_outlined'),
            selectedIcon: CustomIconWidget(iconName: 'chat'),
            label: Text('Messages'),
          ),
          NavigationRailDestination(
            icon: CustomIconWidget(iconName: 'person_outlined'),
            selectedIcon: CustomIconWidget(iconName: 'person'),
            label: Text('Profile'),
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: CustomIconWidget(iconName: 'home_outlined'),
          selectedIcon: CustomIconWidget(iconName: 'home'),
          label: 'Home',
        ),
        NavigationDestination(
          icon: CustomIconWidget(iconName: 'calendar_outlined'),
          selectedIcon: CustomIconWidget(iconName: 'calendar_today'),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: CustomIconWidget(iconName: 'chat_outlined'),
          selectedIcon: CustomIconWidget(iconName: 'chat'),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: CustomIconWidget(iconName: 'person_outlined'),
          selectedIcon: CustomIconWidget(iconName: 'person'),
          label: 'Profile',
        ),
      ],
    );
  }
}
