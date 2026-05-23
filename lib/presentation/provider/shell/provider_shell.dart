import 'package:flutter/material.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/chat/conversations_page.dart';
import 'package:localservicemarket/presentation/profile/profile_page.dart';
import 'package:localservicemarket/presentation/provider/dashboard/provider_dashboard_page.dart';
import 'package:localservicemarket/presentation/provider/requests/incoming_requests_page.dart';

class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key, required this.provider});

  final ServiceProvider provider;

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell> {
  int _index = 0;

  static const _titles = ['Overview', 'Requests', 'Messages', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProviderDashboardPage(provider: widget.provider),
      IncomingRequestsPage(provider: widget.provider),
      ConversationsPage(user: widget.provider),
      ProfilePage(user: widget.provider),
    ];

    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Provider workspace',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    _index == 3 ? widget.provider.name : _titles[_index],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Expanded(child: IndexedStack(index: _index, children: pages)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_customize_outlined),
              selectedIcon: Icon(Icons.dashboard_customize_rounded),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox_outlined),
              selectedIcon: Icon(Icons.inbox_rounded),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
