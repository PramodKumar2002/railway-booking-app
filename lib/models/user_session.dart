import 'package:flutter/foundation.dart';

class UserSession with ChangeNotifier {
  UserSession._internal();

  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  String? _id;
  String? _email;
  String? _fullName;
  String? _phone;
  String? _token;
  bool _isAuthenticated = false;

  String? get id => _id;
  String? get email => _email;
  String? get fullName => _fullName;
  String? get phone => _phone;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  String get displayName => (_fullName != null && _fullName!.isNotEmpty)
      ? _fullName!
      : (_email != null && _email!.isNotEmpty)
          ? _email!.split('@').first
          : 'Passenger';

  void setSession({
    required String email,
    String? id,
    String? fullName,
    String? phone,
    String? token,
  }) {
    _email = email.trim();
    _id = id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
    _fullName = fullName?.trim();
    _phone = phone?.trim();
    _token = token;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearSession() {
    _id = null;
    _email = null;
    _fullName = null;
    _phone = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
