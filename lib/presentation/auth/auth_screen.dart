import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/data/datasources/remote/remote_api_data_source.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'customer@demo.com');
  final _password = TextEditingController(text: RemoteApiDataSource.demoPassword);
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  UserRole _registerRole = UserRole.customer;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Authentication error'),
                content: Text(state.errorMessage!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Icon(
                      Icons.home_repair_service_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Local Services',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Book trusted pros near you',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Login')),
                        ButtonSegment(value: false, label: Text('Register')),
                      ],
                      selected: {_isLogin},
                      onSelectionChanged: (s) =>
                          setState(() => _isLogin = s.first),
                    ),
                    const SizedBox(height: 24),
                    if (_isLogin) ...[
                      Form(
                        key: _loginFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                              validator: (v) =>
                                  v == null || v.length < 6 ? 'Min 6 chars' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Demo: customer@demo.com / provider1@demo.com',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (_loginFormKey.currentState!.validate()) {
                                  context.read<AuthCubit>().login(
                                        _email.text,
                                        _password.text,
                                      );
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign in'),
                      ),
                    ] else ...[
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Customer'),
                          Tab(text: 'Provider'),
                        ],
                        onTap: (i) => setState(() {
                          _registerRole =
                              i == 0 ? UserRole.customer : UserRole.provider;
                        }),
                      ),
                      const SizedBox(height: 16),
                      Form(
                        key: _registerFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (v) =>
                                  v == null || !v.contains('@') ? 'Invalid' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                            if (_registerRole == UserRole.provider) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _bio,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  prefixIcon: Icon(Icons.info_outline),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (_registerFormKey.currentState!.validate()) {
                                  context.read<AuthCubit>().register(
                                        name: _name.text,
                                        email: _email.text,
                                        password: _password.text,
                                        phone: _phone.text,
                                        role: _registerRole,
                                        bio: _bio.text,
                                      );
                                }
                              },
                        child: const Text('Create account'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
    );
  }
}
