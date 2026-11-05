import 'package:my_app/models/user_session.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/services/auth_service.dart';

class OtpResult {
  const OtpResult({
    required this.success,
    required this.message,
    this.otp,
    this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String? otp;
  final String? token;
  final Map<String, dynamic>? user;
}

class OtpService {
  OtpService._internal();

  static final OtpService _instance = OtpService._internal();

  factory OtpService() => _instance;

  final ApiService _api = ApiService();

  String? _lastEmail;
  String? _lastPhone;
  DateTime? _expiresAt;

  void setLastIdentifier({required String email, required String phone}) {
    if (email.trim().isNotEmpty) {
      _lastEmail = email.trim().toLowerCase();
    }
    if (phone.trim().isNotEmpty) {
      _lastPhone = phone.trim();
    }
    _expiresAt = DateTime.now().add(const Duration(minutes: 5));
  }

  String get lastEmail => _lastEmail ?? AuthService.lastRegisteredEmail ?? '';
  String get lastPhone => _lastPhone ?? AuthService.lastRegisteredPhone ?? '';

  /// Send or initiate an OTP generation request on the backend
  Future<OtpResult> sendOtp({
    required String email,
    required String phone,
    String? fullName,
    String? password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phone.trim();

    if (cleanEmail.isEmpty && cleanPhone.isEmpty) {
      return const OtpResult(
        success: false,
        message: 'Email or phone number is required to receive the OTP.',
      );
    }

    setLastIdentifier(email: cleanEmail, phone: cleanPhone);

    try {
      ApiResponse<dynamic> response;
      if (fullName != null && password != null) {
        response = await _api.post(
          '/api/auth/send-otp',
          body: {
            'fullName': fullName.trim(),
            'email': cleanEmail,
            'phone': cleanPhone,
            'password': password,
          },
        );
      } else {
        response = await _api.post(
          '/api/auth/resend-otp',
          body: {
            'email': cleanEmail,
            'phone': cleanPhone,
          },
        );
      }

      if (response.success) {
        _expiresAt = DateTime.now().add(const Duration(minutes: 5));
        String? otpValue;
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          otpValue = data['otp']?.toString();
        }

        return OtpResult(
          success: true,
          message: response.message ??
              (otpValue != null
                  ? 'OTP generated successfully: $otpValue'
                  : 'OTP sent to your registered contact.'),
          otp: otpValue,
        );
      } else {
        return OtpResult(
          success: false,
          message: response.message ?? 'Failed to send OTP. Please try again.',
        );
      }
    } catch (e) {
      return OtpResult(
        success: false,
        message: 'Connection error while sending OTP: ${e.toString()}',
      );
    }
  }

  /// Verify entered OTP against the backend database
  Future<OtpResult> verifyOtp(
    String enteredOtp, {
    String? email,
    String? phone,
  }) async {
    final normalized = enteredOtp.replaceAll(RegExp(r'\s+'), '').trim();
    if (normalized.length != 6 || int.tryParse(normalized) == null) {
      return const OtpResult(
        success: false,
        message: 'Enter a valid 6-digit OTP.',
      );
    }

    final targetEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim().toLowerCase()
        : lastEmail;
    final targetPhone = (phone != null && phone.trim().isNotEmpty)
        ? phone.trim()
        : lastPhone;

    if (targetEmail.isEmpty && targetPhone.isEmpty) {
      return const OtpResult(
        success: false,
        message: 'No registration session found. Please enter your email.',
      );
    }

    try {
      final response = await _api.post(
        '/api/auth/verify-otp',
        body: {
          'email': targetEmail,
          'phone': targetPhone,
          'otp': normalized,
        },
      );

      if (response.success) {
        String? token;
        Map<String, dynamic>? user;

        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          token = data['token']?.toString();
          user = data['user'] as Map<String, dynamic>?;

          if (user != null) {
            UserSession().setSession(
              email: user['email']?.toString() ?? targetEmail,
              id: user['id']?.toString() ?? user['_id']?.toString(),
              fullName: user['fullName']?.toString(),
              phone: user['phone']?.toString(),
              token: token,
            );
          }
        }

        _expiresAt = null;

        return OtpResult(
          success: true,
          message: response.message ??
              'Registration completed successfully! Your account is saved.',
          token: token,
          user: user,
        );
      } else {
        return OtpResult(
          success: false,
          message: response.message ?? 'Invalid OTP. Please check the code and try again.',
        );
      }
    } catch (e) {
      return OtpResult(
        success: false,
        message: 'Connection error while verifying OTP: ${e.toString()}',
      );
    }
  }

  /// Request a fresh OTP from backend
  Future<OtpResult> resendOtp({
    required String email,
    required String phone,
  }) async {
    final targetEmail = email.trim().isNotEmpty ? email.trim().toLowerCase() : lastEmail;
    final targetPhone = phone.trim().isNotEmpty ? phone.trim() : lastPhone;

    if (targetEmail.isEmpty && targetPhone.isEmpty) {
      return const OtpResult(
        success: false,
        message: 'Email or phone identifier is required to resend OTP.',
      );
    }

    try {
      final response = await _api.post(
        '/api/auth/resend-otp',
        body: {
          'email': targetEmail,
          'phone': targetPhone,
        },
      );

      if (response.success) {
        _expiresAt = DateTime.now().add(const Duration(minutes: 5));
        String? otpValue;
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          otpValue = data['otp']?.toString();
        }

        return OtpResult(
          success: true,
          message: response.message ??
              (otpValue != null
                  ? 'New OTP generated: $otpValue'
                  : 'A new OTP has been sent.'),
          otp: otpValue,
        );
      } else {
        return OtpResult(
          success: false,
          message: response.message ?? 'Failed to resend OTP.',
        );
      }
    } catch (e) {
      return OtpResult(
        success: false,
        message: 'Could not connect to backend server: ${e.toString()}',
      );
    }
  }

  int getRemainingSeconds() {
    if (_expiresAt == null) {
      return 0;
    }

    final remaining = _expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  void clear() {
    _lastEmail = null;
    _lastPhone = null;
    _expiresAt = null;
  }
}
