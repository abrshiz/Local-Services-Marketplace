import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/auth_demo_credentials_widget.dart';
import './widgets/auth_login_form_widget.dart';
import './widgets/auth_role_selector_widget.dart';
import './widgets/auth_signup_form_widget.dart';
import './widgets/auth_logo_widget.dart';
import './widgets/auth_tab_widget.dart';

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  bool _isLogin = true;
  String _selectedRole = 'customer';
  bool _isLoading = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
        );
    _formFade = CurvedAnimation(parent: _formController, curve: Curves.easeOut);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    // TODO: Replace with Riverpod/Bloc for production
    _formController.reset();
    setState(() => _isLogin = !_isLogin);
    _formController.forward();
  }

  Future<void> _handleSubmit(Map<String, String> formData) async {
    final email = formData['email'];
    final password = formData['password'];

    // TODO: Replace with real authentication for production
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isLoading = false);

      // Simple demo validation
      if (email == 'user@example.com' && password == 'password123') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainContainer,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid email or password. Hint: user@example.com / password123',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: isTablet
            ? _buildTabletLayout(theme)
            : _buildPhoneLayout(theme, screenHeight),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme, double screenHeight) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              _buildHeaderSection(theme),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: _buildFormSection(theme),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          width: 480,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const AuthLogoWidget(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildFormSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FadeTransition(
        opacity: _logoFade,
        child: ScaleTransition(
          scale: _logoScale,
          child: const AuthLogoWidget(isOnDark: true),
        ),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return SlideTransition(
      position: _formSlide,
      child: FadeTransition(
        opacity: _formFade,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auth mode toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  AuthTabWidget(
                    label: 'Sign In',
                    isActive: _isLogin,
                    onTap: () {
                      if (!_isLogin) _switchAuthMode();
                    },
                  ),
                  AuthTabWidget(
                    label: 'Create Account',
                    isActive: !_isLogin,
                    onTap: () {
                      if (_isLogin) _switchAuthMode();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Role selector
            AuthRoleSelectorWidget(
              selectedRole: _selectedRole,
              onRoleChanged: (role) {
                // TODO: Replace with Riverpod/Bloc for production
                setState(() => _selectedRole = role);
              },
            ),
            const SizedBox(height: 20),
            // Form
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isLogin
                  ? AuthLoginFormWidget(
                      key: const ValueKey('login'),
                      isLoading: _isLoading,
                      onSubmit: _handleSubmit,
                    )
                  : AuthSignupFormWidget(
                      key: const ValueKey('signup'),
                      isLoading: _isLoading,
                      selectedRole: _selectedRole,
                      onSubmit: _handleSubmit,
                    ),
            ),
            const SizedBox(height: 20),
            // Switch link
            Center(
              child: GestureDetector(
                onTap: _switchAuthMode,
                child: RichText(
                  text: TextSpan(
                    text: _isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(
                        text: _isLogin ? 'Sign Up' : 'Sign In',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Demo credentials
            if (_isLogin)
              AuthDemoCredentialsWidget(
                onCredentialSelected: (email, password) {
                  // TODO: Handle demo credentials selection
                },
              ),
          ],
        ),
      ),
    );
  }
}
