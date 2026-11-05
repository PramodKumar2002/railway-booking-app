import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/utils/validators.dart';
import 'package:my_app/widgets/auth_background.dart';
import 'package:my_app/widgets/auth_button.dart';
import 'package:my_app/widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptedTerms = false;
  bool _isSubmitting = false;
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await AuthService().register(
      fullName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      acceptedTerms: _acceptedTerms,
    );

    if (!mounted) return;

    if (!result.success) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: AppTheme.success,
      ),
    );

    Navigator.of(context).pushReplacementNamed(
      '/otp',
      arguments: {
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;

    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child:
                  isWide
                      ? Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.directions_train_rounded,
                                    size: 52,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Railway Booking',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Create your account and reserve your next journey with confidence.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textSecondary.withValues(
                                        alpha: 0.9,
                                      ),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _FeaturePill(
                                    icon: Icons.route_rounded,
                                    label: 'Book routes easily',
                                  ),
                                  const SizedBox(height: 12),
                                  _FeaturePill(
                                    icon: Icons.travel_explore_rounded,
                                    label: 'Track journeys',
                                  ),
                                  const SizedBox(height: 12),
                                  _FeaturePill(
                                    icon: Icons.support_agent_rounded,
                                    label: 'Dedicated support',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ),
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC101D2A),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white12,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.38),
                                        blurRadius: 30,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Create Your Account',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Start your journey with us',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 26),
                                        AuthTextField(
                                          label: 'Full Name',
                                          hintText: 'Your full name',
                                          controller: _nameController,
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          validator: AppValidators.validateName,
                                        ),
                                        const SizedBox(height: 16),
                                        AuthTextField(
                                          label: 'Email',
                                          hintText: 'name@example.com',
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          prefixIcon: Icons.email_outlined,
                                          validator:
                                              AppValidators.validateEmail,
                                        ),
                                        const SizedBox(height: 16),
                                        AuthTextField(
                                          label: 'Phone Number',
                                          hintText: '+1 234 567 890',
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          prefixIcon:
                                              Icons.phone_android_rounded,
                                          validator:
                                              AppValidators.validatePhone,
                                        ),
                                        const SizedBox(height: 16),
                                        AuthTextField(
                                          label: 'Password',
                                          hintText: 'Create a password',
                                          controller: _passwordController,
                                          obscureText: !_passwordVisible,
                                          prefixIcon:
                                              Icons.lock_outline_rounded,
                                          suffixIcon: IconButton(
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      _passwordVisible =
                                                          !_passwordVisible,
                                                ),
                                            icon: Icon(
                                              _passwordVisible
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          validator:
                                              (value) =>
                                                  AppValidators.validatePassword(
                                                    value,
                                                    minLength: 8,
                                                  ),
                                        ),
                                        const SizedBox(height: 16),
                                        AuthTextField(
                                          label: 'Confirm Password',
                                          hintText: 'Repeat your password',
                                          controller:
                                              _confirmPasswordController,
                                          obscureText: !_confirmPasswordVisible,
                                          prefixIcon: Icons.lock_reset_rounded,
                                          suffixIcon: IconButton(
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      _confirmPasswordVisible =
                                                          !_confirmPasswordVisible,
                                                ),
                                            icon: Icon(
                                              _confirmPasswordVisible
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          validator:
                                              (value) =>
                                                  AppValidators.validateConfirmPassword(
                                                    value,
                                                    _passwordController.text,
                                                  ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _acceptedTerms,
                                              onChanged:
                                                  (value) => setState(
                                                    () =>
                                                        _acceptedTerms =
                                                            value ?? false,
                                                  ),
                                            ),
                                            Expanded(
                                              child: RichText(
                                                text: const TextSpan(
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: 'I agree to the ',
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          'Terms & Conditions',
                                                      style: TextStyle(
                                                        color: AppTheme.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        AuthButton(
                                          label: 'Send OTP',
                                          isLoading: _isSubmitting,
                                          icon: Icons.send_rounded,
                                          onPressed: _submitRegistration,
                                        ),
                                        const SizedBox(height: 18),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Already have an account?',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pushReplacementNamed(
                                                        '/login',
                                                      ),
                                                  child: const Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      color: AppTheme.primary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 440),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xCC101D2A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white12,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.38),
                                  blurRadius: 30,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create Your Account',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Start your journey with us',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AuthTextField(
                                    label: 'Full Name',
                                    hintText: 'Your full name',
                                    controller: _nameController,
                                    prefixIcon: Icons.person_outline_rounded,
                                    validator: AppValidators.validateName,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    label: 'Email',
                                    hintText: 'name@example.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: AppValidators.validateEmail,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    label: 'Phone Number',
                                    hintText: '+1 234 567 890',
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icons.phone_android_rounded,
                                    validator: AppValidators.validatePhone,
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    label: 'Password',
                                    hintText: 'Create a password',
                                    controller: _passwordController,
                                    obscureText: !_passwordVisible,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _passwordVisible =
                                                    !_passwordVisible,
                                          ),
                                      icon: Icon(
                                        _passwordVisible
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            AppValidators.validatePassword(
                                              value,
                                              minLength: 8,
                                            ),
                                  ),
                                  const SizedBox(height: 16),
                                  AuthTextField(
                                    label: 'Confirm Password',
                                    hintText: 'Repeat your password',
                                    controller: _confirmPasswordController,
                                    obscureText: !_confirmPasswordVisible,
                                    prefixIcon: Icons.lock_reset_rounded,
                                    suffixIcon: IconButton(
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _confirmPasswordVisible =
                                                    !_confirmPasswordVisible,
                                          ),
                                      icon: Icon(
                                        _confirmPasswordVisible
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            AppValidators.validateConfirmPassword(
                                              value,
                                              _passwordController.text,
                                            ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _acceptedTerms,
                                        onChanged:
                                            (value) => setState(
                                              () =>
                                                  _acceptedTerms =
                                                      value ?? false,
                                            ),
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                            ),
                                            children: [
                                              TextSpan(text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms & Conditions',
                                                style: TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  AuthButton(
                                    label: 'Send OTP',
                                    isLoading: _isSubmitting,
                                    icon: Icons.send_rounded,
                                    onPressed: _submitRegistration,
                                  ),
                                  const SizedBox(height: 18),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Already have an account?',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap:
                                                () => Navigator.of(
                                                  context,
                                                ).pushReplacementNamed(
                                                  '/login',
                                                ),
                                            child: const Text(
                                              'Login',
                                              style: TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
