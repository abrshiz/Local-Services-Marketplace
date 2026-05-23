import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/di/injection.dart';
import 'package:localservicemarket/core/network/connectivity_cubit.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/domain/entities/service_category.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:localservicemarket/domain/repositories/discovery_repository.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
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
  late final Future<List<ServiceCategory>> _categoriesFuture;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  UserRole _registerRole = UserRole.customer;
  bool _isLogin = true;
  bool _obscurePassword = true;
  final Set<String> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoriesFuture = sl<DiscoveryRepository>().getCategories();
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
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          current.errorMessage != previous.errorMessage,
      listener: (context, state) {
        final offline =
            context.read<ConnectivityCubit>().state.showOfflinePage;
        if (!offline && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final submitting = state.isSubmitting;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B5BD6),
                  Color(0xFF4F46E5),
                  Color(0xFF06B6D4),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'LocalServe',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book trusted pros near you',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: AppCard(
                      borderRadius: 28,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: true,
                                  label: Text('Sign in'),
                                ),
                                ButtonSegment(
                                  value: false,
                                  label: Text('Register'),
                                ),
                              ],
                              selected: {_isLogin},
                              onSelectionChanged: (s) =>
                                  setState(() => _isLogin = s.first),
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              _AuthErrorBanner(message: state.errorMessage!),
                            ],
                            const SizedBox(height: 24),
                            if (_isLogin) ...[
                              _buildLogin(submitting),
                            ] else ...[
                              _buildRegister(submitting),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogin(bool submitting) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
            obscureText: true,
            validator: (v) =>
                v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: submitting
                ? null
                : () {
                    if (_loginFormKey.currentState!.validate()) {
                      context.read<AuthCubit>().login(
                            _email.text,
                            _password.text,
                          );
                    }
                  },
            child: submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister(bool submitting) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: scheme.onSurfaceVariant,
            onTap: (i) => setState(() {
              _registerRole = i == 0 ? UserRole.customer : UserRole.provider;
            }),
            tabs: const [
              Tab(text: 'Customer'),
              Tab(text: 'Provider'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _registerFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              if (_registerRole == UserRole.provider) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _bio,
                  decoration: const InputDecoration(
                    labelText: 'Short bio',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                _buildCategoryPicker(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: submitting
              ? null
              : () {
                  if (!_registerFormKey.currentState!.validate()) return;
                  if (_registerRole == UserRole.provider &&
                      _selectedCategoryIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Select at least one work category'),
                      ),
                    );
                    return;
                  }
                  context.read<AuthCubit>().register(
                        name: _name.text,
                        email: _email.text,
                        password: _password.text,
                        phone: _phone.text,
                        role: _registerRole,
                        bio: _bio.text,
                        categoryIds: _selectedCategoryIds.toList(),
                      );
                },
          child: submitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create account'),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker() {
    return FutureBuilder<List<ServiceCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text(
            'Could not load categories',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        final categories = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work categories',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose what services you offer',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected =
                    _selectedCategoryIds.contains(cat.categoryId);
                return FilterChip(
                  label: Text(cat.name),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedCategoryIds.add(cat.categoryId);
                      } else {
                        _selectedCategoryIds.remove(cat.categoryId);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  const _AuthErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
