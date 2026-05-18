import 'package:location_service/location_service.dart';

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
  final LocationPoint? location;
  
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
    this.location,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'city': city,
      'state': state,
      'pincode': pincode,
      'role': role,
      if (location != null) 'location': location!.toJson(),
    };
  }
  
  factory RegistrationRequest.admin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String state,
    required String pincode,
    LocationPoint? location,
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
}