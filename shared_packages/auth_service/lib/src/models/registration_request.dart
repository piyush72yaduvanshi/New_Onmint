import 'package:location_service/location_service.dart';

/// Registration request model that handles all user types
class RegistrationRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final String city;
  final String state;
  final String pincode;
  final String role;
  final LocationPoint location;
  
  // Additional fields for different roles
  final Map<String, dynamic>? additionalFields;
  
  RegistrationRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.state,
    required this.pincode,
    required this.role,
    required this.location,
    this.additionalFields,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'city': city,
      'state': state,
      'pincode': pincode,
      'role': role,
      'location': location.toJson(),
    };

    // Add role-specific fields
    if (additionalFields != null) {
      json.addAll(Map<String, dynamic>.from(additionalFields!));
    }

    return json;
  }

  /// Create patient registration request
  factory RegistrationRequest.patient({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'patient',
      location: location,
    );
  }

  /// Create doctor registration request
  factory RegistrationRequest.doctor({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
    required String specialization,
    required List<String> qualifications,
    required int experience,
    required double consultationFee,
    required String licenseNumber,
    required List<String> languages,
    String? about,
    List<Map<String, dynamic>>? availability,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'doctor',
      location: location,
      additionalFields: {
        'specialization': specialization,
        'qualifications': qualifications,
        'experience': experience,
        'consultationFee': consultationFee,
        'licenseNumber': licenseNumber,
        'languages': languages,
        if (about != null) 'about': about,
        if (availability != null) 'availability': availability,
      },
    );
  }

  /// Create pharmacist registration request
  factory RegistrationRequest.pharmacist({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
    required String pharmacyName,
    required String licenseNumber,
    List<String>? deliveryTimes,
    double? minimumOrderAmount,
    double? deliveryFee,
    Map<String, String>? operatingHours,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'pharmacist',
      location: location,
      additionalFields: {
        'pharmacyName': pharmacyName,
        'licenseNumber': licenseNumber,
        if (deliveryTimes != null) 'deliveryTimes': deliveryTimes,
        if (minimumOrderAmount != null) 'minimumOrderAmount': minimumOrderAmount,
        if (deliveryFee != null) 'deliveryFee': deliveryFee,
        if (operatingHours != null) 'operatingHours': operatingHours,
      },
    );
  }

  /// Create bloodbank registration request
  factory RegistrationRequest.bloodbank({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
    required String bankName,
    required String licenseNumber,
    List<Map<String, dynamic>>? bloodStock,
    String? emergencyContact,
    Map<String, String>? operatingHours,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'bloodbank',
      location: location,
      additionalFields: {
        'bankName': bankName,
        'licenseNumber': licenseNumber,
        if (bloodStock != null) 'bloodStock': bloodStock,
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
        if (operatingHours != null) 'operatingHours': operatingHours,
      },
    );
  }

  /// Create ambulance registration request
  factory RegistrationRequest.ambulance({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
    required String driverName,
    required String driverLicense,
    required String vehicleNumber,
    required String vehicleType,
    List<String>? equipmentAvailable,
    bool? isAvailable,
    LocationPoint? currentLocation,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'ambulance',
      location: location,
      additionalFields: {
        'driverName': driverName,
        'driverLicense': driverLicense,
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        if (equipmentAvailable != null) 'equipmentAvailable': equipmentAvailable,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (currentLocation != null) 'currentLocation': currentLocation.toJson(),
      },
    );
  }

  /// Create admin registration request
  factory RegistrationRequest.admin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    required LocationPoint location,
  }) {
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      state: state,
      pincode: pincode,
      role: 'admin',
      location: location,
    );
  }

  /// Validate registration request
  List<String> validate() {
    final errors = <String>[];

    if (email.isEmpty || !_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    if (password.isEmpty || !_isValidPassword(password)) {
      errors.add('Password must be at least 8 characters with uppercase, lowercase, number, and special character');
    }

    if (firstName.isEmpty) errors.add('First name is required');
    if (lastName.isEmpty) errors.add('Last name is required');
    if (phone.isEmpty || !_isValidPhone(phone)) {
      errors.add('Please enter a valid 10-digit phone number');
    }

    if (city.isEmpty) errors.add('City is required');
    if (state.isEmpty) errors.add('State is required');
    if (pincode.isEmpty || !_isValidPincode(pincode)) {
      errors.add('Please enter a valid 6-digit pincode');
    }

    // Validate role-specific fields
    if (additionalFields != null) {
      switch (role) {
        case 'doctor':
          if (!(additionalFields!.containsKey('specialization') && additionalFields!['specialization']?.toString().isNotEmpty == true)) {
            errors.add('Specialization is required for doctors');
          }
          if (!(additionalFields!.containsKey('qualifications') && additionalFields!['qualifications'] is List && (additionalFields!['qualifications'] as List).isNotEmpty)) {
            errors.add('Qualifications are required for doctors');
          }
          if (!(additionalFields!.containsKey('licenseNumber') && additionalFields!['licenseNumber']?.toString().isNotEmpty == true)) {
            errors.add('License number is required for doctors');
          }
          break;
        case 'pharmacist':
          if (!(additionalFields!.containsKey('pharmacyName') && additionalFields!['pharmacyName']?.toString().isNotEmpty == true)) {
            errors.add('Pharmacy name is required for pharmacists');
          }
          if (!(additionalFields!.containsKey('licenseNumber') && additionalFields!['licenseNumber']?.toString().isNotEmpty == true)) {
            errors.add('License number is required for pharmacists');
          }
          break;
        case 'bloodbank':
          if (!(additionalFields!.containsKey('bankName') && additionalFields!['bankName']?.toString().isNotEmpty == true)) {
            errors.add('Bank name is required for blood banks');
          }
          if (!(additionalFields!.containsKey('licenseNumber') && additionalFields!['licenseNumber']?.toString().isNotEmpty == true)) {
            errors.add('License number is required for blood banks');
          }
          break;
        case 'ambulance':
          if (!(additionalFields!.containsKey('driverName') && additionalFields!['driverName']?.toString().isNotEmpty == true)) {
            errors.add('Driver name is required for ambulance services');
          }
          if (!(additionalFields!.containsKey('vehicleNumber') && additionalFields!['vehicleNumber']?.toString().isNotEmpty == true)) {
            errors.add('Vehicle number is required for ambulance services');
          }
          break;
      }
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password) &&
           RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  bool _isValidPincode(String pincode) {
    return RegExp(r'^\d{6}$').hasMatch(pincode);
  }

  bool _isVendorRole(String role) {
    return ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);
  }

  @override
  String toString() => 'RegistrationRequest(email: $email, role: $role)';
}