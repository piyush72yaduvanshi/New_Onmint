import 'package:location_service/location_service.dart';

/// Pending approval model for admin dashboard
class PendingApproval {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String city;
  final String state;
  final String pincode;
  final String role;
  final String status;
  final LocationPoint location;
  final DateTime createdAt;
  
  // Vendor-specific fields
  final String? specialization;
  final List<String>? qualifications;
  final int? experience;
  final double? consultationFee;
  final String? licenseNumber;
  final List<String>? languages;
  final String? about;

  const PendingApproval({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.state,
    required this.pincode,
    required this.role,
    required this.status,
    required this.location,
    required this.createdAt,
    this.specialization,
    this.qualifications,
    this.experience,
    this.consultationFee,
    this.licenseNumber,
    this.languages,
    this.about,
  });

  /// Create PendingApproval from JSON
  factory PendingApproval.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    LocationPoint location;
    
    if (locationData is Map<String, dynamic>) {
      location = LocationPoint.fromJson(locationData);
    } else {
      location = LocationPoint.fromLatLng(0.0, 0.0);
    }

    return PendingApproval(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      location: location,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      specialization: json['specialization']?.toString(),
      qualifications: json['qualifications'] is List 
          ? (json['qualifications'] as List).map((e) => e.toString()).toList()
          : null,
      experience: json['experience'] is int 
          ? json['experience'] 
          : int.tryParse(json['experience']?.toString() ?? ''),
      consultationFee: json['consultationFee'] is double 
          ? json['consultationFee'] 
          : double.tryParse(json['consultationFee']?.toString() ?? ''),
      licenseNumber: json['licenseNumber']?.toString(),
      languages: json['languages'] is List 
          ? (json['languages'] as List).map((e) => e.toString()).toList()
          : null,
      about: json['about']?.toString(),
    );
  }

  /// Convert to JSON
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
      'status': status,
      'location': location.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (specialization != null) 'specialization': specialization,
      if (qualifications != null) 'qualifications': qualifications,
      if (experience != null) 'experience': experience,
      if (consultationFee != null) 'consultationFee': consultationFee,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (languages != null) 'languages': languages,
      if (about != null) 'about': about,
    };
  }

  /// Get full name
  String get fullName => '$firstName $lastName'.trim();

  /// Get role display name
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      default:
        return role;
    }
  }

  /// Get qualifications as string
  String get qualificationsString {
    return qualifications?.join(', ') ?? '';
  }

  /// Get languages as string
  String get languagesString {
    return languages?.join(', ') ?? '';
  }

  @override
  String toString() => 'PendingApproval(id: $id, name: $fullName, role: $role)';
}