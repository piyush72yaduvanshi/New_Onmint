import '../api_client_base.dart';
import '../models/models.dart';

class AmbulanceApiService {
  final ApiClient _client;

  AmbulanceApiService(this._client);

  // Profile Management
  Future<User> getProfile() async {
    final response = await _client.get('/auth/me');
    return User.fromJson(response.data['data']);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/ambulance/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Location & Availability
  Future<void> updateLocation(double latitude, double longitude) async {
    await _client.put('/ambulance/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<void> setAvailability(bool isAvailable) async {
    await _client.put('/ambulance/availability', data: {
      'isAvailable': isAvailable,
    });
  }

  // Ride Request Management
  Future<Map<String, dynamic>> getRideRequests({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/ambulance/requests', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return {
      'data': response.data['data'] ?? [],
      'pagination': response.data['pagination'] ?? {},
    };
  }

  Future<Map<String, dynamic>> getPendingRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return getRideRequests(page: page, limit: limit, status: 'pending');
  }

  Future<Map<String, dynamic>> getConfirmedRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return getRideRequests(page: page, limit: limit, status: 'confirmed');
  }

  Future<Map<String, dynamic>> getOnTheWayRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return getRideRequests(page: page, limit: limit, status: 'on-the-way');
  }

  Future<Map<String, dynamic>> getInProgressRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return getRideRequests(page: page, limit: limit, status: 'in-progress');
  }

  Future<Map<String, dynamic>> getCompletedRequests({
    int page = 1,
    int limit = 20,
  }) async {
    return getRideRequests(page: page, limit: limit, status: 'completed');
  }

  Future<void> acceptRideRequest(String requestId) async {
    await _client.post('/ambulance/requests/$requestId/accept');
  }

  Future<void> startRide(String requestId) async {
    await _client.post('/ambulance/requests/$requestId/start');
  }

  Future<void> arriveAtPickup(String requestId) async {
    await _client.post('/ambulance/requests/$requestId/arrive');
  }

  Future<void> completeRide(String requestId) async {
    await _client.post('/ambulance/requests/$requestId/complete');
  }

  // Get single ride request details
  Future<Map<String, dynamic>> getRideDetails(String requestId) async {
    final response = await _client.get('/ambulance/requests/$requestId');
    return response.data['data'];
  }

  // Dashboard
  Future<DashboardStats> getDashboard() async {
    final response = await _client.get('/ambulance/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }

  // Live Location Updates (NEW)
  Future<void> updateLiveLocation({
    required double latitude,
    required double longitude,
    String? bookingId,
  }) async {
    await _client.post('/ambulance/location/live', data: {
      'latitude': latitude,
      'longitude': longitude,
      if (bookingId != null) 'bookingId': bookingId,
    });
  }

  // Patient Loaded Status (NEW)
  Future<void> markPatientLoaded(String requestId) async {
    await _client.post('/ambulance/requests/$requestId/patient-loaded');
  }

  // Hospital Reached Status (NEW)
  Future<void> markHospitalReached(
    String requestId, {
    String? hospitalName,
    String? hospitalAddress,
  }) async {
    await _client.post('/ambulance/requests/$requestId/hospital-reached', data: {
      if (hospitalName != null) 'hospitalName': hospitalName,
      if (hospitalAddress != null) 'hospitalAddress': hospitalAddress,
    });
  }

  // Earnings & Financial
  Future<Map<String, dynamic>> getEarnings({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/ambulance/earnings', queryParameters: {
      'page': page,
      'limit': limit,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return {
      'data': response.data['data'] ?? [],
      'pagination': response.data['pagination'] ?? {},
      'totalEarnings': response.data['totalEarnings'] ?? 0,
    };
  }

  // Ratings & Reviews
  Future<Map<String, dynamic>> getRatings({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/ambulance/ratings', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return {
      'data': response.data['data'] ?? [],
      'pagination': response.data['pagination'] ?? {},
      'averageRating': response.data['averageRating'] ?? 0.0,
      'totalRatings': response.data['totalRatings'] ?? 0,
    };
  }

  // Auth Methods
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.post('/auth/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<void> logoutAll() async {
    await _client.post('/auth/logout-all');
  }

  // Token refresh
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post('/auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });
    return response.data['data'];
  }
}
