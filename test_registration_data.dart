// Test file to verify registration data format
import 'shared_packages/auth_service/lib/src/models/registration_request.dart';
import 'shared_packages/location_service/lib/location_service.dart';

void main() {
  final location = LocationPoint.fromLatLng(77.2090, 28.6139);
  
  print('=== DOCTOR REGISTRATION ===');
  final doctorRequest = RegistrationRequest.doctor(
    email: "dr.anil1@healthcare.com",
    password: "Secure@Pass123",
    firstName: "Anil",
    lastName: "Verma",
    phone: "9856512345",
    city: "Jaipur",
    state: "Rajasthan",
    pincode: "302001",
    location: location,
    specialization: "Cardiologist",
    qualifications: ["MBBS", "MD (Cardiology)", "DNB (Cardiology)"],
    experience: 10,
    consultationFee: 800,
    licenseNumber: "DOC-RJ-2024-12345",
    languages: ["Hindi", "English", "Marathi"],
    about: "Experienced cardiologist specializing in interventional cardiology and heart failure management. Board certified with 10+ years of experience.",
    availability: [
      {
        "day": "MONDAY",
        "slots": [
          {"startTime": "09:00", "endTime": "12:00", "isAvailable": true},
          {"startTime": "17:00", "endTime": "20:00", "isAvailable": true}
        ]
      },
      {
        "day": "WEDNESDAY",
        "slots": [
          {"startTime": "09:00", "endTime": "12:00", "isAvailable": true}
        ]
      },
      {
        "day": "FRIDAY",
        "slots": [
          {"startTime": "17:00", "endTime": "20:00", "isAvailable": true}
        ]
      }
    ],
  );
  print(doctorRequest.toJson());
  
  print('\n=== PHARMACIST REGISTRATION ===');
  final pharmacistRequest = RegistrationRequest.pharmacist(
    email: "apollo1@pharmacy.com",
    password: "Secure@Pass123",
    firstName: "Apollo",
    lastName: "Pharmacy",
    phone: "9123476780",
    city: "Hyderabad",
    state: "Telangana",
    pincode: "500001",
    location: location,
    pharmacyName: "Apollo Pharmacy - Banjara Hills",
    licenseNumber: "PHARM-TS-2024-5678",
    deliveryTimes: ["30min", "1hr", "same_day"],
    minimumOrderAmount: 99,
    deliveryFee: 50,
    operatingHours: {"open": "08:00", "close": "22:00"},
  );
  print(pharmacistRequest.toJson());
  
  print('\n=== ADMIN REGISTRATION ===');
  final adminRequest = RegistrationRequest.admin(
    email: "admin12@ourdeals.com",
    password: "Admin@123456",
    firstName: "Super",
    lastName: "Admin",
    phone: "9999999998",
    city: "Delhi",
    state: "Delhi",
    pincode: "110001",
    location: location,
  );
  print(adminRequest.toJson());
}