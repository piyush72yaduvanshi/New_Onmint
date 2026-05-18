import '../api_client_base.dart';
import '../models/models.dart';
import 'package:image_picker/image_picker.dart';

class AdminApiService {
  final ApiClient _client;

  AdminApiService(this._client);

  // Dashboard
  Future<DashboardStats> getDashboard() async {
    final response = await _client.get('/admin/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getServiceStatistics() async {
    final response = await _client.get('/admin/stats/services');
    return response.data['data'];
  }

  // Provider Approvals
  Future<List<User>> getPendingApprovals() async {
    final response = await _client.get('/admin/approvals/pending');
    return (response.data['data'] as List).map((e) => User.fromJson(e)).toList();
  }

  Future<void> approveProvider(String providerId, {String? notes}) async {
    await _client.post('/admin/providers/$providerId/approve', data: {
      if (notes != null) 'notes': notes,
    });
  }

  Future<void> rejectProvider(String providerId, {required String reason}) async {
    await _client.post('/admin/providers/$providerId/reject', data: {
      'reason': reason,
    });
  }

  // User Management
  Future<Map<String, dynamic>> getAllUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? status,
  }) async {
    final response = await _client.get('/admin/users', queryParameters: {
      'page': page,
      'limit': limit,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
    });
    return response.data['data'];
  }

  Future<void> blockUser(String userId, {required String reason}) async {
    await _client.post('/admin/users/$userId/block', data: {
      'reason': reason,
    });
  }

  Future<void> unblockUser(String userId, {String? notes}) async {
    await _client.post('/admin/users/$userId/unblock', data: {
      if (notes != null) 'notes': notes,
    });
  }

  // Medicine Management
  Future<Map<String, dynamic>> getAllMedicines({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final response = await _client.get('/admin/medicines', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null) 'search': search,
      if (category != null) 'category': category,
    });
    return response.data['data'];
  }

  Future<Medicine> createMedicine(Map<String, dynamic> data, {List<String>? imagePaths, List<XFile>? imageFiles}) async {
    final response = imageFiles != null && imageFiles.isNotEmpty
        ? await _client.uploadMultipartData('/admin/medicines', data, xFiles: imageFiles, fileFieldName: 'images')
        : imagePaths != null && imagePaths.isNotEmpty
            ? await _client.uploadMultipartData('/admin/medicines', data, filePaths: imagePaths, fileFieldName: 'images')
            : await _client.post('/admin/medicines', data: data);
    return Medicine.fromJson(response.data['data']);
  }

  Future<Medicine> updateMedicine(String medicineId, Map<String, dynamic> data, {List<String>? imagePaths, List<XFile>? imageFiles}) async {
    final response = imageFiles != null && imageFiles.isNotEmpty
        ? await _client.uploadMultipartData('/admin/medicines/$medicineId', data, xFiles: imageFiles, fileFieldName: 'images')
        : imagePaths != null && imagePaths.isNotEmpty
            ? await _client.updateMultipartData('/admin/medicines/$medicineId', data, filePaths: imagePaths, fileFieldName: 'images')
            : await _client.put('/admin/medicines/$medicineId', data: data);
    return Medicine.fromJson(response.data['data']);
  }

  Future<void> deleteMedicine(String medicineId) async {
    await _client.delete('/admin/medicines/$medicineId');
  }

  // Ambulance Management
  Future<Map<String, dynamic>> getAllAmbulances({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/admin/ambulances', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data['data'];
  }

  Future<User> createAmbulance(Map<String, dynamic> data) async {
    final response = await _client.post('/admin/ambulances', data: data);
    return User.fromJson(response.data['data']);
  }

  Future<User> updateAmbulance(String ambulanceId, Map<String, dynamic> data) async {
    final response = await _client.put('/admin/ambulances/$ambulanceId', data: data);
    return User.fromJson(response.data['data']);
  }

  Future<void> deleteAmbulance(String ambulanceId) async {
    await _client.delete('/admin/ambulances/$ambulanceId');
  }

  // Blood Bank Management
  Future<Map<String, dynamic>> getAllBloodBanks({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/admin/bloodbanks', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data['data'];
  }

  // Alias for getAllBloodBanks
  Future<Map<String, dynamic>> getBloodBanks(String token) async {
    return getAllBloodBanks();
  }

  Future<void> updateBloodStock(String bloodBankId, List<Map<String, dynamic>> bloodStock) async {
    await _client.put('/admin/bloodbanks/$bloodBankId/stock', data: {
      'bloodStock': bloodStock,
    });
  }

  // Alias for updateBloodStock
  Future<void> updateBloodBankStock(String token, String bloodBankId, List<Map<String, dynamic>> bloodStock) async {
    return updateBloodStock(bloodBankId, bloodStock);
  }

  // Pathology Lab Management
  Future<Map<String, dynamic>> getAllPathologyLabs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get('/admin/pathology', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return response.data['data'];
  }

  // Alias for getAllPathologyLabs
  Future<Map<String, dynamic>> getPathologyLabs(String token) async {
    return getAllPathologyLabs();
  }

  Future<void> updatePathologyTests(String pathologyId, List<Map<String, dynamic>> tests) async {
    await _client.put('/admin/pathology/$pathologyId/tests', data: {
      'testsOffered': tests,
    });
  }
}
