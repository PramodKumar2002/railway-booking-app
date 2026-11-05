import 'package:my_app/models/user_session.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/otp_service.dart';
import 'package:my_app/utils/validators.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.userId,
    this.token,
    this.otp,
  });

  final bool success;
  final String message;
  final String? userId;
  final String? token;
  final String? otp;
}

class AuthService {
  final ApiService _api = ApiService();

  static String? lastRegisteredEmail;
  static String? lastRegisteredPhone;

  Future<AuthResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) {
      return AuthResult(success: false, message: emailError);
    }

    final passwordError = AppValidators.validatePassword(password);
    if (passwordError != null) {
      return AuthResult(success: false, message: passwordError);
    }

    try {
      final response = await _api.post(
        '/api/auth/login',
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (response.success && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token']?.toString();
        final user = data['user'] as Map<String, dynamic>?;

        UserSession().setSession(
          email: user?['email']?.toString() ?? email.trim(),
          id: user?['id']?.toString() ?? user?['_id']?.toString(),
          fullName: user?['fullName']?.toString(),
          phone: user?['phone']?.toString(),
          token: token,
        );

        return AuthResult(
          success: true,
          message: data['message']?.toString() ?? 'Login successful.',
          userId: user?['id']?.toString() ?? user?['_id']?.toString(),
          token: token,
        );
      }

      // If backend returned a specific error message (e.g. incorrect password, account not found)
      if (response.message != null && response.message!.isNotEmpty) {
        return AuthResult(
          success: false,
          message: response.message!,
        );
      }

      return const AuthResult(
        success: false,
        message: 'Invalid credentials. Please check your email and password.',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Could not connect to backend server: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final nameError = AppValidators.validateName(fullName);
    if (nameError != null) {
      return AuthResult(success: false, message: nameError);
    }

    final emailError = AppValidators.validateEmail(email);
    if (emailError != null) {
      return AuthResult(success: false, message: emailError);
    }

    final phoneError = AppValidators.validatePhone(phone);
    if (phoneError != null) {
      return AuthResult(success: false, message: phoneError);
    }

    final passwordError = AppValidators.validatePassword(
      password,
      minLength: 8,
    );
    if (passwordError != null) {
      return AuthResult(success: false, message: passwordError);
    }

    final confirmPasswordError = AppValidators.validateConfirmPassword(
      confirmPassword,
      password,
    );
    if (confirmPasswordError != null) {
      return AuthResult(success: false, message: confirmPasswordError);
    }

    if (!acceptedTerms) {
      return const AuthResult(
        success: false,
        message: 'Please accept the terms and conditions to continue.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    lastRegisteredEmail = cleanEmail;
    lastRegisteredPhone = cleanPhone;
    OtpService().setLastIdentifier(email: cleanEmail, phone: cleanPhone);

    try {
      final response = await _api.post(
        '/api/auth/send-otp',
        body: {
          'fullName': fullName.trim(),
          'email': cleanEmail,
          'phone': cleanPhone,
          'password': password,
        },
      );

      if (response.success) {
        String? otpValue;
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          otpValue = data['otp']?.toString();
        }

        return AuthResult(
          success: true,
          message: response.message ?? 'OTP generated and sent successfully.',
          userId: 'pending-user',
          otp: otpValue,
        );
      } else {
        return AuthResult(
          success: false,
          message: response.message ?? 'Registration request failed.',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Could not connect to backend server: ${e.toString()}',
      );
    }
  }

  void logout() {
    UserSession().clearSession();
  }
}
