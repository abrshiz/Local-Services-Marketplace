import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/network/connectivity_cubit.dart';
import 'package:localservicemarket/core/theme/app_theme.dart';
import 'package:localservicemarket/core/theme/theme_cubit.dart';
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
import 'package:localservicemarket/presentation/shared/no_internet_page.dart';

class LocalServiceMarketApp extends StatelessWidget {
  const LocalServiceMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Local Services Marketplace',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, conn) {
                  return Stack(
                    children: [
                      if (child != null) child,
                      if (conn.showOfflinePage)
                        const Positioned.fill(child: NoInternetPage()),
                    ],
                  );
                },
              );
            },
            home: BlocProvider(
              create: (_) => sl<AuthCubit>()..checkSession(),
              child: const _RootRouter(),
            ),
          );
        },
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.home_repair_service_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CircularProgressIndicator(color: scheme.primary),
                  ],
                ),
              ),
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
