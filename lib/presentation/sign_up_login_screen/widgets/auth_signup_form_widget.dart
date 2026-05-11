import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AuthSignupFormWidget extends StatefulWidget {
  final bool isLoading;
  final String selectedRole;
  final Function(Map<String, String>) onSubmit;

  const AuthSignupFormWidget({
    super.key,
    required this.isLoading,
    required this.selectedRole,
    required this.onSubmit,
  });

  @override
  State<AuthSignupFormWidget> createState() => _AuthSignupFormWidgetState();
}

class _AuthSignupFormWidgetState extends State<AuthSignupFormWidget> {
  // TODO: Replace with Riverpod/Bloc for production
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isProvider = widget.selectedRole == 'provider';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isProvider ? 'Become a Provider' : 'Create Account',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isProvider
                ? 'Start offering your services today'
                : 'Join thousands of happy customers',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          // Full name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.plusJakartaSans(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Your full name',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              if (value.trim().length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'you@example.com',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.plusJakartaSans(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+1 (555) 000-0000',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: CustomIconWidget(
                  iconName: 'phone',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              if (value.length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Min. 8 characters',
              helperText: 'Use uppercase, numbers, and symbols for security',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: IconButton(
                onPressed: () {
                  // TODO: Replace with Riverpod/Bloc for production
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: CustomIconWidget(
                  iconName: _obscurePassword ? 'visibility' : 'visibility_off',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Terms acceptance
          GestureDetector(
            onTap: () {
              // TODO: Replace with Riverpod/Bloc for production
              setState(() => _acceptTerms = !_acceptTerms);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (val) {
                      // TODO: Replace with Riverpod/Bloc for production
                      setState(() => _acceptTerms = val ?? false);
                    },
                    activeColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: (widget.isLoading || !_acceptTerms)
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit({
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'password': _passwordController.text,
                          'role': widget.selectedRole,
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary.withAlpha(102),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isProvider ? 'Register as Provider' : 'Create Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
