import '../api_client_base.dart';
import '../models/models.dart';

class DoctorApiService {
  final ApiClient _client;

  DoctorApiService(this._client);

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/doctor/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Availability Management
  Future<void> setAvailability(List<Map<String, dynamic>> availability) async {
    await _client.put('/doctor/availability', data: {
      'availability': availability,
    });
  }

  // Appointment Management
  Future<Map<String, dynamic>> getAppointments({
    int page = 1,
    int limit = 10,
    String? status,
    String? serviceType,
  }) async {
    final response = await _client.get('/doctor/appointments', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
      if (serviceType != null) 'serviceType': serviceType,
    });
    // Backend returns: { success, message, data: [...], pagination: {...} }
    return {
      'data': response.data['data'] ?? [],
      'pagination': response.data['pagination'] ?? {},
    };
  }

  Future<void> acceptAppointment(String appointmentId) async {
    await _client.post('/doctor/appointments/$appointmentId/accept');
  }

  // Prescription Management
  Future<Prescription> createPrescription(Map<String, dynamic> data) async {
    final response = await _client.post('/doctor/prescriptions', data: data);
    return Prescription.fromJson(response.data['data']);
  }

  // Dashboard
  Future<DashboardStats> getDashboard() async {
    final response = await _client.get('/doctor/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }

  // Location Update (NEW - Added April 19, 2026)
  /// Update doctor's current location for distance-based search
  /// Should be called when doctor opens app or location changes significantly
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.put('/doctor/location', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data['data'];
  }

  // Appointment Details
  Future<Map<String, dynamic>> getAppointmentDetails(String appointmentId) async {
    final response = await _client.get('/doctor/appointments/$appointmentId');
    return response.data['data'];
  }

  // Reject Appointment
  Future<void> rejectAppointment(String appointmentId, {String? reason}) async {
    await _client.post('/doctor/appointments/$appointmentId/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  // Complete Appointment
  Future<void> completeAppointment(String appointmentId) async {
    await _client.post('/doctor/appointments/$appointmentId/complete');
  }

  // Video Call APIs
  /// Create video room for consultation (Zoom)
  Future<Map<String, dynamic>> createVideoRoom(String bookingId) async {
    final response = await _client.post('/video/room', data: {
      'bookingId': bookingId,
    });
    return response.data['data'];
  }

  /// Get/refresh video token for Zoom meeting
  Future<Map<String, dynamic>> getVideoToken(String bookingId) async {
    final response = await _client.get('/video/token/$bookingId');
    return response.data['data'];
  }

  /// End video consultation
  Future<void> endVideoCall(String bookingId) async {
    await _client.post('/video/end/$bookingId');
  }

  /// Get video room status
  Future<Map<String, dynamic>> getVideoRoomStatus(String bookingId) async {
    final response = await _client.get('/video/status/$bookingId');
    return response.data['data'];
  }

  /// Get video service status (Zoom)
  Future<Map<String, dynamic>> getVideoServiceStatus() async {
    final response = await _client.get('/video/service-status');
    return response.data['data'];
  }
}
