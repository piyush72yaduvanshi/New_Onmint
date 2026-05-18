import 'package:dio/dio.dart';
import '../api_client_base.dart';

/// Document API service for file upload/download
class DocumentApiService {
  final ApiClient _client;

  DocumentApiService(this._client);

  /// Upload a document
  Future<Map<String, dynamic>> uploadDocument({
    required String filePath,
    required String fileName,
    required String documentType,
    String? bookingId,
    String? description,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      'documentType': documentType,
      if (bookingId != null) 'bookingId': bookingId,
      if (description != null) 'description': description,
    });

    final response = await _client.post(
      '/documents/upload',
      data: formData,
    );

    return response.data['data'];
  }

  /// Get user's documents
  Future<Map<String, dynamic>> getDocuments({
    String? documentType,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/documents',
      queryParameters: {
        if (documentType != null) 'documentType': documentType,
        'page': page,
        'limit': limit,
      },
    );

    return response.data['data'];
  }

  /// Get document details
  Future<Map<String, dynamic>> getDocumentDetails(String documentId) async {
    final response = await _client.get('/documents/$documentId');
    return response.data['data'];
  }

  /// Download document
  Future<String> downloadDocument(String documentId, String savePath) async {
    // For now, just return the download URL
    // In a real implementation, you would download the file to savePath
    final url = await getDocumentUrl(documentId);
    return url;
  }

  /// Delete document
  Future<void> deleteDocument(String documentId) async {
    await _client.delete('/documents/$documentId');
  }

  /// Get document download URL
  Future<String> getDocumentUrl(String documentId) async {
    final response = await _client.get('/documents/$documentId/url');
    return response.data['data']['url'];
  }

  /// Upload prescription document
  Future<Map<String, dynamic>> uploadPrescription({
    required String filePath,
    required String fileName,
    String? bookingId,
  }) async {
    return uploadDocument(
      filePath: filePath,
      fileName: fileName,
      documentType: 'prescription',
      bookingId: bookingId,
    );
  }

  /// Upload medical report
  Future<Map<String, dynamic>> uploadMedicalReport({
    required String filePath,
    required String fileName,
    String? description,
  }) async {
    return uploadDocument(
      filePath: filePath,
      fileName: fileName,
      documentType: 'medical_report',
      description: description,
    );
  }

  /// Upload lab report
  Future<Map<String, dynamic>> uploadLabReport({
    required String filePath,
    required String fileName,
    String? bookingId,
  }) async {
    return uploadDocument(
      filePath: filePath,
      fileName: fileName,
      documentType: 'lab_report',
      bookingId: bookingId,
    );
  }

  /// Get prescriptions
  Future<Map<String, dynamic>> getPrescriptions({
    int page = 1,
    int limit = 20,
  }) async {
    return getDocuments(
      documentType: 'prescription',
      page: page,
      limit: limit,
    );
  }

  /// Get medical reports
  Future<Map<String, dynamic>> getMedicalReports({
    int page = 1,
    int limit = 20,
  }) async {
    return getDocuments(
      documentType: 'medical_report',
      page: page,
      limit: limit,
    );
  }

  /// Get lab reports
  Future<Map<String, dynamic>> getLabReports({
    int page = 1,
    int limit = 20,
  }) async {
    return getDocuments(
      documentType: 'lab_report',
      page: page,
      limit: limit,
    );
  }
}
