import '../api_client_base.dart';
import '../models/models.dart';

class PharmacistApiService {
  final ApiClient _client;

  PharmacistApiService(this._client);

  // Profile Management
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/pharmacist/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  // Medicine Inventory
  Future<Map<String, dynamic>> getInventory({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final response = await _client.get('/pharmacist/medicines', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    });
    return response.data['data'];
  }

  Future<Medicine> addMedicine(Map<String, dynamic> data) async {
    final response = await _client.post('/pharmacist/medicines', data: data);
    return Medicine.fromJson(response.data['data']);
  }

  Future<Medicine> updateMedicine(String medicineId, Map<String, dynamic> data) async {
    final response = await _client.put('/pharmacist/medicines/$medicineId', data: data);
    return Medicine.fromJson(response.data['data']);
  }

  Future<void> updateStock(String medicineId, int stock) async {
    await _client.put('/pharmacist/medicines/$medicineId/stock', data: {
      'stock': stock,
    });
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _client.delete('/pharmacist/medicines/$medicineId');
  }

  // Order Management
  
  /// Get pending orders (not yet accepted by any pharmacist)
  /// NEW: Medicine orders that are available for all pharmacists
  Future<Map<String, dynamic>> getPendingOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/pharmacist/orders/pending', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data['data'];
  }

  /// Get orders assigned to this pharmacist
  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.get('/pharmacist/orders', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    
    // Return the full response data including pagination
    return {
      'data': response.data['data'] ?? [],
      'pagination': response.data['pagination'] ?? {},
    };
  }

  /// Accept a pending order (first-come-first-serve)
  /// May throw error if already accepted by another pharmacist
  Future<void> acceptOrder(String orderId) async {
    await _client.post('/pharmacist/orders/$orderId/accept');
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.put('/pharmacist/orders/$orderId/status', data: {
      'status': status,
    });
  }

  // Dashboard
  Future<DashboardStats> getDashboard() async {
    final response = await _client.get('/pharmacist/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }
}
