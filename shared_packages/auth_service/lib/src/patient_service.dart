import 'package:api_client/api_client.dart';

/// Patient service for OnMint healthcare platform
class PatientService {
  final ApiClient _apiClient = ApiClient();

  /// Get nearby services (all types or filtered by serviceType)
  Future<ApiResponse<Map<String, dynamic>>> getNearbyServices({
    String? serviceType,
    double? latitude,
    double? longitude,
    int? radius,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🏥 Getting nearby services - Type: $serviceType');
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (serviceType != null && serviceType.isNotEmpty) {
        queryParams['serviceType'] = serviceType;
      }
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }
      if (radius != null) {
        queryParams['radius'] = radius.toString();
      }
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/services/nearby',
        queryParams: queryParams,
        fromJson: (json) {
          print('🏥 Nearby services response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {doctors: [...], ...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Nearby services response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Nearby services API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'NEARBY_SERVICES_ERROR',
          message: 'Failed to fetch nearby services: $e',
        ),
      );
    }
  }

  /// Create a booking
  Future<ApiResponse<Map<String, dynamic>>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      print('🏥 Creating booking: $bookingData');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/patient/bookings',
        body: bookingData,
        fromJson: (json) {
          print('🏥 Create booking response: $json');
          
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
      
      print('🏥 Create booking response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Create booking API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'CREATE_BOOKING_ERROR',
          message: 'Failed to create booking: $e',
        ),
      );
    }
  }

  /// Get all bookings with pagination
  Future<ApiResponse<Map<String, dynamic>>> getBookings({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🏥 Getting bookings - Page: $page, Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/bookings',
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
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
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

  /// Get active bookings
  Future<ApiResponse<Map<String, dynamic>>> getActiveBookings() async {
    try {
      print('🏥 Getting active bookings');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/bookings/active',
        fromJson: (json) {
          print('🏥 Active bookings response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: [...]}
            if (json.containsKey('success') && json['success'] == true) {
              return {
                'bookings': json['data'] ?? [],
              };
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 Active bookings response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Active bookings API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ACTIVE_BOOKINGS_ERROR',
          message: 'Failed to fetch active bookings: $e',
        ),
      );
    }
  }

  /// Get booking details
  Future<ApiResponse<Map<String, dynamic>>> getBookingDetails(String bookingId) async {
    try {
      print('🏥 Getting booking details: $bookingId');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/bookings/$bookingId',
        fromJson: (json) {
          print('🏥 Booking details response: $json');
          
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
      
      print('🏥 Booking details response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Booking details API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'BOOKING_DETAILS_ERROR',
          message: 'Failed to fetch booking details: $e',
        ),
      );
    }
  }

  /// Cancel booking
  Future<ApiResponse<Map<String, dynamic>>> cancelBooking(String bookingId) async {
    try {
      print('🏥 Cancelling booking: $bookingId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/patient/bookings/$bookingId/cancel',
        fromJson: (json) {
          print('🏥 Cancel booking response: $json');
          
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
      
      print('🏥 Cancel booking response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Cancel booking API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'CANCEL_BOOKING_ERROR',
          message: 'Failed to cancel booking: $e',
        ),
      );
    }
  }

  /// Rate booking
  Future<ApiResponse<Map<String, dynamic>>> rateBooking(
    String bookingId, {
    required int rating,
    String? review,
  }) async {
    try {
      print('🏥 Rating booking: $bookingId - Rating: $rating');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/patient/bookings/$bookingId/rate',
        body: {
          'rating': rating,
          if (review != null && review.isNotEmpty) 'review': review,
        },
        fromJson: (json) {
          print('🏥 Rate booking response: $json');
          
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
      
      print('🏥 Rate booking response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Rate booking API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'RATE_BOOKING_ERROR',
          message: 'Failed to rate booking: $e',
        ),
      );
    }
  }

  /// Get all doctors (fallback method for home screen)
  Future<ApiResponse<Map<String, dynamic>>> getAllDoctors({int limit = 10}) async {
    try {
      print('🏥 Getting all doctors - Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/services/nearby',
        queryParams: {
          'serviceType': 'doctor',
          'limit': limit.toString(),
        },
        fromJson: (json) {
          print('🏥 All doctors response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {doctors: [...]}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      print('🏥 All doctors response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 All doctors API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ALL_DOCTORS_ERROR',
          message: 'Failed to fetch all doctors: $e',
        ),
      );
    }
  }

  /// Get unread notifications count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      print('🏥 Getting unread notifications count');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/notifications/unread-count',
        fromJson: (json) {
          print('🏥 Unread count response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {count: 5}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return json as Map<String, dynamic>;
        },
      );
      
      if (response.success && response.data != null) {
        final count = response.data!['count'] ?? 0;
        return ApiResponse.success(data: count is int ? count : int.tryParse(count.toString()) ?? 0);
      }
      
      return ApiResponse.success(data: 0);
    } catch (e) {
      print('🏥 Unread count API error: $e');
      return ApiResponse.success(data: 0); // Return 0 on error
    }
  }

  /// Get all notifications
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🏥 Getting notifications - Page: $page, Limit: $limit');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/patient/notifications',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (json) {
          print('🏥 Notifications response: $json');
          
          if (json is Map<String, dynamic>) {
            // Handle nested structure: {success: true, data: {notifications: [...], pagination: {...}}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              return json['data'] as Map<String, dynamic>;
            }
            // Handle direct structure
            return json;
          }
          return {'notifications': []};
        },
      );
      
      print('🏥 Notifications response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Notifications API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'NOTIFICATIONS_ERROR',
          message: 'Failed to fetch notifications: $e',
        ),
      );
    }
  }

  /// Mark notification as read
  Future<ApiResponse<Map<String, dynamic>>> markNotificationAsRead(String notificationId) async {
    try {
      print('🏥 Marking notification as read: $notificationId');
      
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/patient/notifications/$notificationId/read',
        fromJson: (json) {
          print('🏥 Mark as read response: $json');
          
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
      
      print('🏥 Mark as read response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Mark as read API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'MARK_READ_ERROR',
          message: 'Failed to mark notification as read: $e',
        ),
      );
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<Map<String, dynamic>>> markAllNotificationsAsRead() async {
    try {
      print('🏥 Marking all notifications as read');
      
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/patient/notifications/mark-all-read',
        fromJson: (json) {
          print('🏥 Mark all as read response: $json');
          
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
      
      print('🏥 Mark all as read response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Mark all as read API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'MARK_ALL_READ_ERROR',
          message: 'Failed to mark all notifications as read: $e',
        ),
      );
    }
  }

  /// Create emergency request
  Future<ApiResponse<Map<String, dynamic>>> createEmergency(Map<String, dynamic> emergencyData) async {
    try {
      print('🏥 Creating emergency request: $emergencyData');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/patient/emergency',
        body: emergencyData,
        fromJson: (json) {
          print('🏥 Create emergency response: $json');
          
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
      
      print('🏥 Create emergency response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('🏥 Create emergency API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'CREATE_EMERGENCY_ERROR',
          message: 'Failed to create emergency request: $e',
        ),
      );
    }
  }
}
