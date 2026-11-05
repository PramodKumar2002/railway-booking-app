import 'package:my_app/services/api_service.dart';

class ContactResult {
  const ContactResult({
    required this.success,
    required this.message,
    this.referenceId,
  });

  final bool success;
  final String message;
  final String? referenceId;
}

class ContactService {
  ContactService._internal();

  static final ContactService _instance = ContactService._internal();

  factory ContactService() => _instance;

  final ApiService _api = ApiService();

  Future<ContactResult> submitContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'subject': subject.trim(),
      'message': message.trim(),
    };

    final response = await _api.post('/api/contact', body: payload);

    if (response.success && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      String? refId;
      if (data['data'] is Map && data['data']['referenceId'] != null) {
        refId = data['data']['referenceId'].toString();
      }

      return ContactResult(
        success: true,
        message: data['message']?.toString() ?? 'Message submitted successfully.',
        referenceId: refId,
      );
    }

    return ContactResult(
      success: false,
      message: response.message ?? 'Failed to submit contact message. Please try again.',
    );
  }
}
