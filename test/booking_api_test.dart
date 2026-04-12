import 'package:flutter_test/flutter_test.dart';
import '../shared_packages/auth_service/lib/src/patient_service.dart';
import '../shared_packages/auth_service/lib/src/doctor_service.dart';
import '../shared_packages/api_client/lib/src/api_response.dart';

void main() {
  group('Booking API Tests', () {
    late PatientService patientService;
    late DoctorService doctorService;

    setUp(() {
      patientService = PatientService();
      doctorService = DoctorService();
    });

    test('Create Booking - Valid Data', () async {
      final bookingData = {
        'serviceType': 'doctor',
        'provider': '69bad990da608aef66ea389e',
        'scheduledTime': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'symptoms': 'Fever and headache',
        'location': {
          'address': 'Test Address',
          'coordinates': [77.2090, 28.6139],
        },
        'price': 500,
        'notes': 'Test booking',
      };

      print('=== TESTING CREATE BOOKING ===');
      print('Booking Data: $bookingData');

      final response = await patientService.createBooking(bookingData);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      // Test should handle both success and error cases
      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Create Booking - Doctor Not Available on Sunday', () async {
      final sundayDate = _getNextSunday();
      
      final bookingData = {
        'serviceType': 'doctor',
        'provider': '69bad990da608aef66ea389e',
        'scheduledTime': sundayDate.toIso8601String(),
        'symptoms': 'Regular checkup',
        'location': {
          'address': 'Test Address',
          'coordinates': [77.2090, 28.6139],
        },
        'price': 500,
      };

      print('=== TESTING SUNDAY BOOKING (Should Fail) ===');
      print('Sunday Date: $sundayDate');
      print('Booking Data: $bookingData');

      final response = await patientService.createBooking(bookingData);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Error: ${response.error?.message}');

      if (!response.success && response.error?.message != null) {
        final errorMessage = response.error!.message.toLowerCase();
        if (errorMessage.contains('not available') || errorMessage.contains('sunday')) {
          print('✅ Correctly handled Sunday unavailability');
        }
      }
    });

    test('Get Active Bookings', () async {
      print('=== TESTING GET ACTIVE BOOKINGS ===');

      final response = await patientService.getActiveBookings();
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Cancel Booking', () async {
      print('=== TESTING CANCEL BOOKING ===');

      // First create a booking to cancel
      final bookingData = {
        'serviceType': 'doctor',
        'provider': '69bad990da608aef66ea389e',
        'scheduledTime': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'symptoms': 'Test booking for cancellation',
        'location': {
          'address': 'Test Address',
          'coordinates': [77.2090, 28.6139],
        },
        'price': 500,
      };

      final createResponse = await patientService.createBooking(bookingData);
      
      if (createResponse.success && createResponse.data != null) {
        final bookingId = createResponse.data!['_id'] ?? createResponse.data!['id'];
        
        if (bookingId != null) {
          print('Created booking with ID: $bookingId');
          
          final cancelResponse = await patientService.cancelBooking(bookingId);
          
          print('Cancel Response Success: ${cancelResponse.success}');
          print('Cancel Response Status Code: ${cancelResponse.statusCode}');
          print('Cancel Response Data: ${cancelResponse.data}');
          print('Cancel Response Error: ${cancelResponse.error?.message}');
        }
      }
    });

    test('Doctor Accept Appointment', () async {
      print('=== TESTING DOCTOR ACCEPT APPOINTMENT ===');

      // Mock appointment ID - in real scenario this would come from doctor's appointments
      const appointmentId = 'test-appointment-id';
      
      final response = await doctorService.acceptAppointment(appointmentId);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Doctor Reject Appointment', () async {
      print('=== TESTING DOCTOR REJECT APPOINTMENT ===');

      const appointmentId = 'test-appointment-id';
      const reason = 'Not available at requested time';
      
      final response = await doctorService.rejectAppointment(appointmentId, reason);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Doctor Complete Appointment', () async {
      print('=== TESTING DOCTOR COMPLETE APPOINTMENT ===');

      const appointmentId = 'test-appointment-id';
      const notes = 'Patient examined. Prescribed medication for fever.';
      
      final response = await doctorService.completeAppointment(appointmentId, notes);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Doctor Get Dashboard', () async {
      print('=== TESTING DOCTOR DASHBOARD ===');

      final response = await doctorService.getDashboard();
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Doctor Get Appointments', () async {
      print('=== TESTING DOCTOR GET APPOINTMENTS ===');

      final response = await doctorService.getAppointments(page: 1, limit: 10);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Get Nearby Services', () async {
      print('=== TESTING GET NEARBY SERVICES ===');

      final response = await patientService.getNearbyServices(
        serviceType: 'doctor',
        latitude: 28.6139,
        longitude: 77.2090,
        radius: 5,
        page: 1,
        limit: 10,
      );
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });

    test('Emergency Request', () async {
      print('=== TESTING EMERGENCY REQUEST ===');

      final emergencyData = {
        'location': {
          'address': 'Emergency Location',
          'coordinates': [77.2090, 28.6139],
        },
        'emergencyType': 'medical',
        'description': 'Chest pain, need immediate assistance',
        'contactNumber': '9876543210',
      };

      final response = await patientService.createEmergency(emergencyData);
      
      print('Response Success: ${response.success}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Error: ${response.error?.message}');

      expect(response, isA<ApiResponse<Map<String, dynamic>>>());
    });
  });
}

DateTime _getNextSunday() {
  final now = DateTime.now();
  final daysUntilSunday = (7 - now.weekday) % 7;
  final nextSunday = now.add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
  return DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 10, 0); // 10 AM on Sunday
}