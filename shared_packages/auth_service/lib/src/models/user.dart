import 'package:location_service/location_service.dart';

/// User model for OnMint healthcare platform
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String city;
  final String state;
  final String pincode;
  final String role;
  final LocationPoint location;
  final DateTime createdAt;
  final bool isActive;
  final String? status;
  final String? profilePicture;
  final String? profilePictureUrl;
  
  // Vendor-specific fields
  final String? specialization;
  final List<String>? qualifications;
  final int? experience;
  final double? consultationFee;
  final String? licenseNumber;
  final List<String>? languages;
  final String? about;
  final bool? isVerified;
  
  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.state,
    required this.pincode,
    required this.role,
    required this.location,
    required this.createdAt,
    required this.isActive,
    this.status,
    this.profilePicture,
    this.profilePictureUrl,
    this.specialization,
    this.qualifications,
    this.experience,
    this.consultationFee,
    this.licenseNumber,
    this.languages,
    this.about,
    this.isVerified,
  });
  
  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('User.fromJson called with keys: ${json.keys.toList()}');
      
      final locationData = json['location'];
      LocationPoint location;
      
      if (locationData is Map<String, dynamic>) {
        location = LocationPoint.fromJson(locationData);
      } else {
        location = LocationPoint.fromLatLng(0.0, 0.0);
      }
      
      final roleFromJson = json['role']?.toString() ?? 'patient';
      final emailFromJson = json['email']?.toString() ?? '';
      final idFromJson = json['id']?.toString() ?? json['_id']?.toString() ?? '';
      final firstNameFromJson = json['firstName']?.toString() ?? '';
      
      print('Parsed - ID: "$idFromJson", Email: "$emailFromJson", Role: "$roleFromJson"');
      
      final user = User(
        id: idFromJson,
        email: emailFromJson,
        firstName: firstNameFromJson,
        lastName: json['lastName']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        pincode: json['pincode']?.toString() ?? '',
        role: roleFromJson,
        location: location,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        isActive: json['isActive'] ?? true,
        status: json['status']?.toString(),
        profilePicture: json['profilePicture']?.toString(),
        profilePictureUrl: json['profilePictureUrl']?.toString(),
        specialization: json['specialization']?.toString(),
        qualifications: json['qualifications'] is List ? (json['qualifications'] as List).map((e) => e.toString()).toList() : null,
        experience: json['experience'] is int ? json['experience'] : int.tryParse(json['experience']?.toString() ?? ''),
        consultationFee: json['consultationFee'] is double ? json['consultationFee'] : double.tryParse(json['consultationFee']?.toString() ?? ''),
        licenseNumber: json['licenseNumber']?.toString(),
        languages: json['languages'] is List ? (json['languages'] as List).map((e) => e.toString()).toList() : null,
        about: json['about']?.toString(),
        isVerified: json['isVerified'],
      );
      
      print('User created - Email: ${user.email}, Role: ${user.role}, IsAdmin: ${user.isAdmin}');
      return user;
    } catch (e) {
      print('Error creating User from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'city': city,
      'state': state,
      'pincode': pincode,
      'role': role,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      if (status != null) 'status': status,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (specialization != null) 'specialization': specialization,
      if (qualifications != null) 'qualifications': qualifications,
      if (experience != null) 'experience': experience,
      if (consultationFee != null) 'consultationFee': consultationFee,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (languages != null) 'languages': languages,
      if (about != null) 'about': about,
      if (isVerified != null) 'isVerified': isVerified,
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName'.trim();

  /// Check if user is a vendor
  bool get isVendor => ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);

  /// Check if user is a patient
  bool get isPatient => role == 'patient';

  /// Check if user is an admin
  bool get isAdmin => role == 'admin';

  /// Copy with method for immutable updates
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? state,
    String? pincode,
    String? role,
    LocationPoint? location,
    DateTime? createdAt,
    bool? isActive,
    String? status,
    String? profilePicture,
    String? profilePictureUrl,
    String? specialization,
    List<String>? qualifications,
    int? experience,
    double? consultationFee,
    String? licenseNumber,
    List<String>? languages,
    String? about,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      profilePicture: profilePicture ?? this.profilePicture,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      specialization: specialization ?? this.specialization,
      qualifications: qualifications ?? this.qualifications,
      experience: experience ?? this.experience,
      consultationFee: consultationFee ?? this.consultationFee,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      languages: languages ?? this.languages,
      about: about ?? this.about,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, role: $role, name: $fullName)';
}