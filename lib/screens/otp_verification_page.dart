import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/services/otp_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/utils/validators.dart';
import 'package:my_app/widgets/auth_background.dart';
import 'package:my_app/widgets/auth_button.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  static const routeName = '/otp';

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  bool _canResend = false;
  int _remainingSeconds = 60;
  Timer? _timer;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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
    _startCountdown();
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _getOtpValue() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtpValue();
    final validation = AppValidators.validateOtp(otp);
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation), backgroundColor: AppTheme.error),
      );
      return;
    }

    final effectiveEmail = widget.email.trim().isNotEmpty
        ? widget.email.trim()
        : OtpService().lastEmail;
    final effectivePhone = widget.phone.trim().isNotEmpty
        ? widget.phone.trim()
        : OtpService().lastPhone;

    setState(() => _isVerifying = true);
    final result = await OtpService().verifyOtp(
      otp,
      email: effectiveEmail,
      phone: effectivePhone,
    );

    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: AppTheme.success,
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _resendOtp() async {
    final effectiveEmail = widget.email.trim().isNotEmpty
        ? widget.email.trim()
        : OtpService().lastEmail;
    final effectivePhone = widget.phone.trim().isNotEmpty
        ? widget.phone.trim()
        : OtpService().lastPhone;

    final service = OtpService();
    final response = await service.resendOtp(
      email: effectiveEmail,
      phone: effectivePhone,
    );

    if (!mounted) return;

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: AppTheme.success,
      ),
    );
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xCC101D2A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12, width: 1),
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
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppTheme.primary,
                              size: 32,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Verify Your Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.email.isNotEmpty
                              ? 'Enter the 6-digit OTP sent to ${widget.email}'
                              : (OtpService().lastEmail.isNotEmpty
                                  ? 'Enter the 6-digit OTP sent to ${OtpService().lastEmail}'
                                  : 'Enter the 6-digit OTP sent to your email/phone'),
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.9),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 46,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      _focusNodes[index].hasFocus
                                          ? AppTheme.primary
                                          : Colors.white12,
                                  width: 1.2,
                                ),
                              ),
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (index < 5) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_focusNodes[index + 1]);
                                    }
                                  }
                                  if (value.isEmpty && index > 0) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_focusNodes[index - 1]);
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _canResend
                                  ? 'You can resend the OTP now.'
                                  : 'Resend in ${_remainingSeconds}s',
                              style: TextStyle(
                                color:
                                    _canResend
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _canResend ? _resendOtp : null,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color:
                                        _canResend
                                            ? AppTheme.primary
                                            : Colors.white38,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/register');
                            },
                            child: const Text(
                              'Change Email/Phone',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        AuthButton(
                          label: 'Verify OTP',
                          isLoading: _isVerifying,
                          icon: Icons.check_circle_rounded,
                          onPressed: _verifyOtp,
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
    );
  }
}
