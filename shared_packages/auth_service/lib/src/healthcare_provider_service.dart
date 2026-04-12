import 'package:api_client/api_client.dart';

/// Healthcare provider service for OnMint healthcare platform
/// Supports doctors, nurses, pharmacists, ambulance, bloodbank, pathology
class HealthcareProviderService {
  final ApiClient _apiClient = ApiClient();
  final String _providerType;

  HealthcareProviderService(this._providerType);

  /// Get provider dashboard data
  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      print('🏥 Getting $_providerType dashboard data');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/dashboard',
        fromJson: (json) {
          print('🏥 Dashboard response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Dashboard response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Dashboard API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'DASHBOARD_ERROR',
          message: 'Failed to fetch dashboard: $e',
        ),
      );
    }
  }

  /// Get provider appointments
  Future<ApiResponse<Map<String, dynamic>>> getAppointments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🏥 Getting $_providerType appointments - Page: $page, Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/appointments',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (json) {
          print('🏥 Appointments response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: [...], pagination: {...}}
            if (json.containsKey('success') && json['success'] == true) {
              return {
                'appointments': json['data'] ?? [],
                'pagination': json['pagination'] ?? {},
              };
            }
            // Handle direct structure with appointments array
            else if (json.containsKey('data') && json['data'] is List) {
              return {
                'appointments': json['data'],
                'pagination': json['pagination'] ?? {},
              };
            }
            // Handle direct structure
            return json;
          }
          // Handle direct array response
          else if (json is List) {
            return {
              'appointments': json,
              'pagination': {},
            };
          }
          
          return {
            'appointments': [],
            'pagination': {},
          };
        },
      );
      
      print('🏥 Appointments response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Appointments API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'APPOINTMENTS_ERROR',
          message: 'Failed to fetch appointments: $e',
        ),
      );
    }
  }

  /// Get provider profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      print('🏥 Getting $_providerType profile');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/profile',
        fromJson: (json) {
          print('🏥 Profile response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'PROFILE_ERROR',
          message: 'Failed to fetch profile: $e',
        ),
      );
    }
  }

  /// Update provider profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('🏥 Updating $_providerType profile: $profileData');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/$_providerType/profile',
        body: profileData,
        fromJson: (json) {
          print('🏥 Update profile response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Update profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Update profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UPDATE_PROFILE_ERROR',
          message: 'Failed to update profile: $e',
        ),
      );
    }
  }

  /// Update tests offered (for pathology providers)
  Future<ApiResponse<Map<String, dynamic>>> updateTestsOffered(List<Map<String, dynamic>> testsOffered) async {
    try {
      print('🏥 Updating $_providerType tests offered: $testsOffered');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/$_providerType/tests',
        body: {'testsOffered': testsOffered},
        fromJson: (json) {
          print('🏥 Update tests response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Update tests response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Update tests API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UPDATE_TESTS_ERROR',
          message: 'Failed to update tests: $e',
        ),
      );
    }
  }

  /// Get provider bookings (for pathology and other services)
  Future<ApiResponse<Map<String, dynamic>>> getBookings({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🏥 Getting $_providerType bookings - Page: $page, Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/bookings',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (json) {
          print('🏥 Bookings response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: [...], pagination: {...}}
            if (json.containsKey('success') && json['success'] == true) {
              return {
                'bookings': json['data'] ?? [],
                'pagination': json['pagination'] ?? {},
              };
            }
            // Handle direct structure with bookings array
            else if (json.containsKey('data') && json['data'] is List) {
              return {
                'bookings': json['data'],
                'pagination': json['pagination'] ?? {},
              };
            }
            // Handle direct structure
            return json;
          }
          // Handle direct array response
          else if (json is List) {
            return {
              'bookings': json,
              'pagination': {},
            };
          }
          
          return {
            'bookings': [],
            'pagination': {},
          };
        },
      );
      
      print('🏥 Bookings response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Bookings API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'BOOKINGS_ERROR',
          message: 'Failed to fetch bookings: $e',
        ),
      );
    }
  }

  /// Schedule sample collection (for pathology)
  Future<ApiResponse<Map<String, dynamic>>> scheduleCollection(String bookingId, String scheduledTime) async {
    try {
      print('🏥 Scheduling collection for booking: $bookingId at $scheduledTime');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/bookings/$bookingId/schedule',
        body: {'scheduledTime': scheduledTime},
        fromJson: (json) {
          print('🏥 Schedule collection response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Schedule collection response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Schedule collection API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'SCHEDULE_COLLECTION_ERROR',
          message: 'Failed to schedule collection: $e',
        ),
      );
    }
  }

  /// Upload report (for pathology)
  Future<ApiResponse<Map<String, dynamic>>> uploadReport(String bookingId, Map<String, dynamic> reportData) async {
    try {
      print('🏥 Uploading report for booking: $bookingId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/bookings/$bookingId/report',
        body: reportData,
        fromJson: (json) {
          print('🏥 Upload report response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Upload report response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Upload report API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UPLOAD_REPORT_ERROR',
          message: 'Failed to upload report: $e',
        ),
      );
    }
  }

  /// Get provider availability (mainly for doctors and nurses)
  Future<ApiResponse<Map<String, dynamic>>> getAvailability() async {
    try {
      print('🏥 Getting $_providerType availability');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/availability',
        fromJson: (json) {
          print('🏥 Availability response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Availability response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Availability API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'AVAILABILITY_ERROR',
          message: 'Failed to fetch availability: $e',
        ),
      );
    }
  }

  /// Set provider availability (mainly for doctors and nurses)
  Future<ApiResponse<Map<String, dynamic>>> setAvailability(Map<String, dynamic> availabilityData) async {
    try {
      print('🏥 Setting $_providerType availability: $availabilityData');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/$_providerType/availability',
        body: availabilityData,
        fromJson: (json) {
          print('🏥 Set availability response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure - return the full user object with availability
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Set availability response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Set availability API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'SET_AVAILABILITY_ERROR',
          message: 'Failed to set availability: $e',
        ),
      );
    }
  }

  /// Accept appointment
  Future<ApiResponse<Map<String, dynamic>>> acceptAppointment(String bookingId) async {
    try {
      print('🏥 Accepting appointment: $bookingId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/appointments/$bookingId/accept',
        fromJson: (json) {
          print('🏥 Accept appointment response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Accept appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Accept appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ACCEPT_APPOINTMENT_ERROR',
          message: 'Failed to accept appointment: $e',
        ),
      );
    }
  }

  /// Accept booking (for pathology and other services)
  Future<ApiResponse<Map<String, dynamic>>> acceptBooking(String bookingId) async {
    try {
      print('🏥 Accepting booking: $bookingId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/bookings/$bookingId/accept',
        fromJson: (json) {
          print('🏥 Accept booking response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Accept booking response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Accept booking API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ACCEPT_BOOKING_ERROR',
          message: 'Failed to accept booking: $e',
        ),
      );
    }
  }

  /// Reject appointment
  Future<ApiResponse<Map<String, dynamic>>> rejectAppointment(String bookingId, {String? reason}) async {
    try {
      print('🏥 Rejecting appointment: $bookingId');
      
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/appointments/$bookingId/reject',
        body: body.isNotEmpty ? body : null,
        fromJson: (json) {
          print('🏥 Reject appointment response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Reject appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Reject appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REJECT_APPOINTMENT_ERROR',
          message: 'Failed to reject appointment: $e',
        ),
      );
    }
  }

  /// Reject booking (for pathology and other services)
  Future<ApiResponse<Map<String, dynamic>>> rejectBooking(String bookingId, {String? reason}) async {
    try {
      print('🏥 Rejecting booking: $bookingId');
      
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/bookings/$bookingId/reject',
        body: body.isNotEmpty ? body : null,
        fromJson: (json) {
          print('🏥 Reject booking response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Reject booking response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Reject booking API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REJECT_BOOKING_ERROR',
          message: 'Failed to reject booking: $e',
        ),
      );
    }
  }

  /// Complete appointment
  Future<ApiResponse<Map<String, dynamic>>> completeAppointment(String bookingId, {String? notes}) async {
    try {
      print('🏥 Completing appointment: $bookingId');
      
      final body = <String, dynamic>{};
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/$_providerType/appointments/$bookingId/complete',
        body: body.isNotEmpty ? body : null,
        fromJson: (json) {
          print('🏥 Complete appointment response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Complete appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Complete appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'COMPLETE_APPOINTMENT_ERROR',
          message: 'Failed to complete appointment: $e',
        ),
      );
    }
  }

  /// Get appointment details
  Future<ApiResponse<Map<String, dynamic>>> getAppointmentDetails(String bookingId) async {
    try {
      print('🏥 Getting appointment details: $bookingId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/$_providerType/appointments/$bookingId',
        fromJson: (json) {
          print('🏥 Appointment details response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Appointment details response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Appointment details API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'APPOINTMENT_DETAILS_ERROR',
          message: 'Failed to fetch appointment details: $e',
        ),
      );
    }
  }
}

// Convenience classes for specific provider types
class DoctorService extends HealthcareProviderService {
  DoctorService() : super('doctor');
}

class NurseService extends HealthcareProviderService {
  NurseService() : super('nurse');
}

class PharmacistService extends HealthcareProviderService {
  PharmacistService() : super('pharmacist');
}

class AmbulanceService extends HealthcareProviderService {
  AmbulanceService() : super('ambulance');
}

class BloodBankService extends HealthcareProviderService {
  BloodBankService() : super('bloodbank');
}

class PathologyService extends HealthcareProviderService {
  PathologyService() : super('pathology');
}