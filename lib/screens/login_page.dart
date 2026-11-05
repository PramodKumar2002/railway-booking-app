import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/utils/validators.dart';
import 'package:my_app/widgets/auth_background.dart';
import 'package:my_app/widgets/auth_button.dart';
import 'package:my_app/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final authService = AuthService();
    final result = await authService.login(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) {
      return;
    }

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

    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;

    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child:
                  isWide
                      ? Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.train_rounded,
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
                                    'Travel smarter, faster, and more comfortably across every route.',
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
                                    icon: Icons.confirmation_number_rounded,
                                    label: 'Fast booking',
                                  ),
                                  const SizedBox(height: 12),
                                  _FeaturePill(
                                    icon: Icons.notifications_active_rounded,
                                    label: 'Live updates',
                                  ),
                                  const SizedBox(height: 12),
                                  _FeaturePill(
                                    icon: Icons.security_rounded,
                                    label: 'Secure access',
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
                                    maxWidth: 470,
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: isWide ? 16 : 0,
                                    vertical: 12,
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
                                        color: Colors.black.withValues(
                                          alpha: 0.38,
                                        ),
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.account_circle_rounded,
                                              color: AppTheme.primary,
                                              size: 30,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Welcome Back',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Sign in to continue your journey',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 26),
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
                                          label: 'Password',
                                          hintText: 'Enter your password',
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
                                                  ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: _rememberMe,
                                                  onChanged:
                                                      (value) => setState(
                                                        () =>
                                                            _rememberMe =
                                                                value ?? false,
                                                      ),
                                                ),
                                                const Text(
                                                  'Remember Me',
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap:
                                                    () => ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Password reset flow will be added later.',
                                                        ),
                                                      ),
                                                    ),
                                                child: const Text(
                                                  'Forgot Password?',
                                                  style: TextStyle(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 28),
                                        AuthButton(
                                          label: 'Login',
                                          isLoading: _isSubmitting,
                                          icon: Icons.login_rounded,
                                          onPressed: _submitLogin,
                                        ),
                                        const SizedBox(height: 18),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Don't have an account?",
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
                                                        '/register',
                                                      ),
                                                  child: const Text(
                                                    'Register',
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
                      : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: FadeTransition(
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
                                    color: Colors.black.withValues(
                                      alpha: 0.38,
                                    ),
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
                                    const Icon(
                                      Icons.train_rounded,
                                      color: AppTheme.primary,
                                      size: 42,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Sign in to continue your journey',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
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
                                      label: 'Password',
                                      hintText: 'Enter your password',
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
                                              ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _rememberMe,
                                              onChanged:
                                                  (value) => setState(
                                                    () =>
                                                        _rememberMe =
                                                            value ?? false,
                                                  ),
                                            ),
                                            const Text(
                                              'Remember Me',
                                              style: TextStyle(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap:
                                                () => ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Password reset flow will be added later.',
                                                    ),
                                                  ),
                                                ),
                                            child: const Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    AuthButton(
                                      label: 'Login',
                                      isLoading: _isSubmitting,
                                      icon: Icons.login_rounded,
                                      onPressed: _submitLogin,
                                    ),
                                    const SizedBox(height: 18),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Don't have an account?",
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
                                                    '/register',
                                                  ),
                                              child: const Text(
                                                'Register',
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
