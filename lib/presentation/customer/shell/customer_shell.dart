import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/discovery_home_page.dart';
import 'package:localservicemarket/presentation/customer/discovery/pages/map_view_page.dart';
import 'package:localservicemarket/presentation/customer/tracking/tracking_page.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoveryHomePage(customer: widget.customer),
      MapViewPage(customer: widget.customer),
      TrackingPage(customer: widget.customer),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(['Discover', 'Map', 'Bookings'][_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }
}
