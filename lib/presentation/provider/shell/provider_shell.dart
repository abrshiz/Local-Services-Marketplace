import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      ProviderDashboardPage(provider: widget.provider),
      IncomingRequestsPage(provider: widget.provider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Dashboard' : 'Incoming requests'),
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
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Badge(
              label: const Text(''),
              isLabelVisible: false,
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: const Icon(Icons.inbox),
            label: 'Requests',
          ),
        ],
      ),
    );
  }
}
