import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/theme/app_theme.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/presentation/auth/auth_screen.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_state.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/shell/customer_shell.dart';
import 'package:localservicemarket/presentation/customer/tracking/bloc/tracking_cubit.dart';
import 'package:localservicemarket/presentation/provider/dashboard/bloc/provider_dashboard_cubit.dart';
import 'package:localservicemarket/presentation/provider/shell/provider_shell.dart';

class LocalServiceMarketApp extends StatelessWidget {
  const LocalServiceMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Services Marketplace',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => sl<AuthCubit>()..checkSession(),
        child: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const AuthScreen();
          case AuthStatus.authenticated:
            final user = state.user!;
            if (user.role == UserRole.provider && user is ServiceProvider) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => sl<ProviderDashboardCubit>(),
                  ),
                ],
                child: ProviderShell(provider: user),
              );
            }
            if (user is Customer) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (_) => sl<DiscoveryCubit>()),
                  BlocProvider(create: (_) => sl<TrackingCubit>()),
                ],
                child: CustomerShell(customer: user),
              );
            }
            return const AuthScreen();
        }
      },
    );
  }
}
