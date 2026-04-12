/// Form validation utilities for OnMint healthcare platform
class FormValidators {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    
    return null;
  }

  /// Phone number validation (Indian format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any spaces or special characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }
    
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanPhone)) {
      return 'Please enter a valid Indian phone number';
    }
    
    return null;
  }

  /// Pincode validation (Indian format)
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Pincode must be 6 digits';
    }
    
    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Number validation
  static String? validateNumber(String? value, {String fieldName = 'Number', double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must not exceed $max';
    }
    
    return null;
  }

  /// Experience validation
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Experience is required';
    }
    
    final experience = int.tryParse(value);
    if (experience == null) {
      return 'Please enter a valid number';
    }
    
    if (experience < 0) {
      return 'Experience cannot be negative';
    }
    
    if (experience > 50) {
      return 'Please enter a valid experience (max 50 years)';
    }
    
    return null;
  }

  /// Consultation fee validation
  static String? validateConsultationFee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Consultation fee is required';
    }
    
    final fee = double.tryParse(value);
    if (fee == null) {
      return 'Please enter a valid amount';
    }
    
    if (fee <= 0) {
      return 'Consultation fee must be greater than 0';
    }
    
    if (fee > 10000) {
      return 'Please enter a reasonable consultation fee';
    }
    
    return null;
  }

  /// License number validation
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    
    if (value.length < 5) {
      return 'License number must be at least 5 characters';
    }
    
    return null;
  }

  /// Specialization validation
  static String? validateSpecialization(String? value) {
    if (value == null || value.isEmpty) {
      return 'Specialization is required';
    }
    
    if (value.length < 3) {
      return 'Specialization must be at least 3 characters';
    }
    
    return null;
  }

  /// Qualifications validation
  static String? validateQualifications(String? value) {
    if (value == null || value.isEmpty) {
      return 'Qualifications are required';
    }
    
    if (value.length < 2) {
      return 'Qualifications must be at least 2 characters';
    }
    
    return null;
  }

  /// Languages validation
  static String? validateLanguages(List<String>? languages) {
    if (languages == null || languages.isEmpty) {
      return 'At least one language is required';
    }
    
    return null;
  }

  /// City validation
  static String? validateCity(String? value) {
    return validateName(value, fieldName: 'City');
  }

  /// State validation
  static String? validateState(String? value) {
    return validateName(value, fieldName: 'State');
  }

  /// Coordinates validation
  static String? validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude is required';
    }
    
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Please enter a valid latitude';
    }
    
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    
    return null;
  }

  static String? validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Longitude is required';
    }
    
    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Please enter a valid longitude';
    }
    
    if (lng < -180 || lng > 180) {
      return 'Longitude must be between -180 and 180';
    }
    
    return null;
  }

  /// Input sanitization
  static String sanitizeInput(String input) {
    // Remove potentially harmful characters
    return input
        .replaceAll(RegExp(r'[<>"\'']'), '')
        .replaceAll(RegExp(r'script', caseSensitive: false), '')
        .trim();
  }

  /// Clean phone number (remove formatting)
  static String cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    final clean = cleanPhoneNumber(phone);
    if (clean.length == 10) {
      return '${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return phone;
  }
}