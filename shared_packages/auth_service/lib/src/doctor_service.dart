import 'package:api_client/api_client.dart';

/// Doctor service for OnMint healthcare platform
class DoctorService {
  final ApiClient _apiClient = ApiClient();

  /// Get doctor dashboard data
  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      print('🩺 Getting doctor dashboard data');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/doctor/dashboard',
        fromJson: (json) {
          print('🩺 Dashboard response: $json');
          
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
      
      print('🩺 Dashboard response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Dashboard API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'DASHBOARD_ERROR',
          message: 'Failed to fetch dashboard: $e',
        ),
      );
    }
  }

  /// Get doctor appointments
  Future<ApiResponse<Map<String, dynamic>>> getAppointments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🩺 Getting doctor appointments - Page: $page, Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/doctor/appointments',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (json) {
          print('🩺 Appointments response: $json');
          
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
      
      print('🩺 Appointments response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Appointments API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'APPOINTMENTS_ERROR',
          message: 'Failed to fetch appointments: $e',
        ),
      );
    }
  }

  /// Accept an appointment
  Future<ApiResponse<Map<String, dynamic>>> acceptAppointment(String appointmentId) async {
    try {
      print('🩺 Accepting appointment: $appointmentId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/doctor/appointments/$appointmentId/accept',
        fromJson: (json) {
          print('🩺 Accept appointment response: $json');
          
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
      
      print('🩺 Accept appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Accept appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ACCEPT_APPOINTMENT_ERROR',
          message: 'Failed to accept appointment: $e',
        ),
      );
    }
  }

  /// Reject an appointment
  Future<ApiResponse<Map<String, dynamic>>> rejectAppointment(String appointmentId, String reason) async {
    try {
      print('🩺 Rejecting appointment: $appointmentId, Reason: $reason');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/doctor/appointments/$appointmentId/reject',
        body: {'reason': reason},
        fromJson: (json) {
          print('🩺 Reject appointment response: $json');
          
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
      
      print('🩺 Reject appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Reject appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REJECT_APPOINTMENT_ERROR',
          message: 'Failed to reject appointment: $e',
        ),
      );
    }
  }

  /// Complete an appointment
  Future<ApiResponse<Map<String, dynamic>>> completeAppointment(String appointmentId, String notes) async {
    try {
      print('🩺 Completing appointment: $appointmentId, Notes: $notes');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/doctor/appointments/$appointmentId/complete',
        body: {'notes': notes},
        fromJson: (json) {
          print('🩺 Complete appointment response: $json');
          
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
      
      print('🩺 Complete appointment response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Complete appointment API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'COMPLETE_APPOINTMENT_ERROR',
          message: 'Failed to complete appointment: $e',
        ),
      );
    }
  }

  /// Get doctor profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      print('🩺 Getting doctor profile');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/doctor/profile',
        fromJson: (json) {
          print('🩺 Profile response: $json');
          
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
      
      print('🩺 Profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'PROFILE_ERROR',
          message: 'Failed to fetch profile: $e',
        ),
      );
    }
  }

  /// Update doctor profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('🩺 Updating doctor profile: $profileData');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/doctor/profile',
        body: profileData,
        fromJson: (json) {
          print('🩺 Update profile response: $json');
          
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
      
      print('🩺 Update profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Update profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UPDATE_PROFILE_ERROR',
          message: 'Failed to update profile: $e',
        ),
      );
    }
  }

  /// Get doctor availability
  Future<ApiResponse<Map<String, dynamic>>> getAvailability() async {
    try {
      print('🩺 Getting doctor availability');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/doctor/availability',
        fromJson: (json) {
          print('🩺 Availability response: $json');
          
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
      
      print('🩺 Availability response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Availability API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'AVAILABILITY_ERROR',
          message: 'Failed to fetch availability: $e',
        ),
      );
    }
  }

  /// Set doctor availability
  Future<ApiResponse<Map<String, dynamic>>> setAvailability(Map<String, dynamic> availabilityData) async {
    try {
      print('🩺 Setting doctor availability: $availabilityData');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/doctor/availability',
        body: availabilityData,
        fromJson: (json) {
          print('🩺 Set availability response: $json');
          
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
      
      print('🩺 Set availability response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Set availability API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'SET_AVAILABILITY_ERROR',
          message: 'Failed to set availability: $e',
        ),
      );
    }
  }

  /// Get appointment details
  Future<ApiResponse<Map<String, dynamic>>> getAppointmentDetails(String bookingId) async {
    try {
      print('🩺 Getting appointment details: $bookingId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/doctor/appointments/$bookingId',
        fromJson: (json) {
          print('🩺 Appointment details response: $json');
          
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
      
      print('🩺 Appointment details response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🩺 Appointment details API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'APPOINTMENT_DETAILS_ERROR',
          message: 'Failed to fetch appointment details: $e',
        ),
      );
    }
  }
}