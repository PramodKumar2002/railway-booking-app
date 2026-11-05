import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user_session.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
}

class ApiService {
  ApiService._internal();

  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  String? _customBaseUrl;

  /// Default API base URL:
  /// - Web / Desktop: http://localhost:5000
  /// - Android Emulator: http://10.0.2.2:5000
  String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {
      // Platform not supported or browser
    }
    return 'http://localhost:5000';
  }

  set baseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = UserSession().token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';

      Uri uri = Uri.parse('$base$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        final stringParams = queryParams.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        );
        uri = uri.replace(queryParameters: stringParams);
      }

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      final body = _safeDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: body,
          statusCode: response.statusCode,
        );
      }

      final errMsg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Request failed with status: ${response.statusCode}';

      return ApiResponse(
        success: false,
        message: errMsg,
        statusCode: response.statusCode,
        data: body,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network connection error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final base = baseUrl.replaceAll(RegExp(r'/+$'), '');
      final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final uri = Uri.parse('$base$path');

      final encodedBody = body != null ? jsonEncode(body) : null;

      final response = await http
          .post(uri, headers: _headers, body: encodedBody)
          .timeout(const Duration(seconds: 15));

      final responseData = _safeDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          data: responseData,
          statusCode: response.statusCode,
        );
      }

      final errMsg = (responseData is Map && responseData['message'] != null)
          ? responseData['message'].toString()
          : 'Server returned error status ${response.statusCode}';

      return ApiResponse(
        success: false,
        message: errMsg,
        statusCode: response.statusCode,
        data: responseData,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Could not connect to backend: ${e.toString()}',
      );
    }
  }

  dynamic _safeDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}
