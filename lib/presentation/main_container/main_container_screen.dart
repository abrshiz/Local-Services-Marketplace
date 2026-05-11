import '../../core/app_export.dart';
import '../home_screen/home_screen.dart';
import '../bookings_list_screen/bookings_list_screen.dart';
import '../messages_screen/messages_screen.dart';
import '../profile_screen/profile_screen.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _navIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookingsListScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          if (isTablet)
            AppNavigation(
              currentIndex: _navIndex,
              onDestinationSelected: (index) {
                setState(() => _navIndex = index);
              },
            ),
          if (isTablet)
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant,
            ),
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : AppNavigation(
              currentIndex: _navIndex,
              onDestinationSelected: (index) {
                setState(() => _navIndex = index);
              },
            ),
    );
  }
}
