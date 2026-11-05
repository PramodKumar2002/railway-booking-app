class AppValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final normalized = value!.trim();
    final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegExp.hasMatch(normalized)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value, {int minLength = 6}) {
    final requiredError = validateRequired(value, 'Password');
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    final requiredError = validateRequired(value, 'Full name');
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return 'Full name must contain at least 2 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    final requiredError = validateRequired(value, 'Phone number');
    if (requiredError != null) {
      return requiredError;
    }

    final digitsOnly = value!.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    final requiredError = validateRequired(value, 'Confirm password');
    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateOtp(String? value) {
    final requiredError = validateRequired(value, 'OTP');
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length != 6 || int.tryParse(value.trim()) == null) {
      return 'Enter a valid 6-digit OTP';
    }

    return null;
  }
}
