import 'package:flutter/material.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/chat/conversations_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/discovery_home_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/map_view_page.dart';
import 'package:localservicemarket/presentation/customer/tracking/tracking_page.dart';
import 'package:localservicemarket/presentation/profile/profile_page.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  static const _titles = [
    'Discover',
    'Nearby map',
    'Messages',
    'My bookings',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoveryHomePage(customer: widget.customer),
      MapViewPage(customer: widget.customer),
      ConversationsPage(user: widget.customer),
      TrackingPage(customer: widget.customer),
      ProfilePage(user: widget.customer),
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
                    'Hi, ${widget.customer.name.split(' ').first}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    _titles[_index],
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
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Bookings',
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
