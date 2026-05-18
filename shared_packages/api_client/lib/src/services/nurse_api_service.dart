import '../api_client_base.dart';
import '../models/models.dart';

class NurseApiService {
  final ApiClient _client;

  NurseApiService(this._client);

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/nurse/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Service Management
  Future<void> updateServices(List<Map<String, dynamic>> servicesOffered) async {
    await _client.put('/nurse/services', data: {
      'servicesOffered': servicesOffered,
    });
  }

  // Availability Management
  Future<void> setAvailability(List<Map<String, dynamic>> availability) async {
    await _client.put('/nurse/availability', data: {
      'availability': availability,
    });
  }

  // Booking Management
  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/nurse/bookings', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return response.data['data'];
  }

  Future<void> acceptBooking(String bookingId) async {
    await _client.post('/nurse/bookings/$bookingId/accept');
  }

  Future<void> startVisit(String bookingId) async {
    await _client.post('/nurse/bookings/$bookingId/start');
  }

  Future<void> completeVisit(String bookingId, {String? notes}) async {
    await _client.post('/nurse/bookings/$bookingId/complete', data: {
      if (notes != null) 'notes': notes,
    });
  }

  // Dashboard
  Future<DashboardStats> getDashboard() async {
    final response = await _client.get('/nurse/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }

  // Get booking details
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final response = await _client.get('/nurse/bookings/$bookingId');
    return response.data['data'];
  }

  // Reject booking
  Future<void> rejectBooking(String bookingId, {String? reason}) async {
    await _client.post('/nurse/bookings/$bookingId/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  // Start service (alias for startVisit)
  Future<void> startService(String bookingId) async {
    await startVisit(bookingId);
  }

  // Complete service (alias for completeVisit)
  Future<void> completeService(String bookingId, {String? notes}) async {
    await completeVisit(bookingId, notes: notes);
  }

  // Update availability (alias for setAvailability)
  Future<void> updateAvailability(List<Map<String, dynamic>> availability) async {
    await setAvailability(availability);
  }

  // Location Update (NEW - Added April 19, 2026)
  /// Update nurse's current location for distance-based search
  /// Should be called when nurse opens app or location changes significantly
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.put('/nurse/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data['data'];
  }
}
