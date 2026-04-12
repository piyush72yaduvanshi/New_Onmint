import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'api_config.dart';
import 'api_response.dart';
import 'api_error.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';

/// Main API client for OnMint healthcare platform
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();
  final AuthInterceptor _authInterceptor = AuthInterceptor();
  final ConnectivityInterceptor _connectivityInterceptor = ConnectivityInterceptor();

  /// Set authentication token
  void setAuthToken(String token) {
    _authInterceptor.setToken(token);
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authInterceptor.clearToken();
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      queryParams: queryParams,
      fromJson: fromJson,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'PATCH',
      endpoint,
      body: body,
      fromJson: fromJson,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      fromJson: fromJson,
    );
  }

  /// Make HTTP request with error handling
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      // Check connectivity
      await _connectivityInterceptor.checkConnectivity();

      // Build URL
      final url = _buildUrl(endpoint, queryParams);
      
      // Log request details
      print('🌐 API Request: $method ${url.toString()}');
      if (body != null) {
        print('📤 Request Body: $body');
      }
      
      // Prepare headers
      final headers = await _prepareHeaders();
      print('📋 Request Headers: $headers');

      // Make request
      final response = await _executeRequest(method, url, headers, body);
      
      // Log response details
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      // Handle response
      return _handleResponse<T>(response, fromJson);
    } on ApiException catch (e) {
      print('❌ API Exception: ${e.message}');
      return ApiResponse.error(
        error: ApiError(
          code: e.type.toString(),
          message: e.message,
          field: e.field,
        ),
        statusCode: e.statusCode ?? 0,
      );
    } catch (e) {
      print('❌ Unexpected Error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  /// Build URL with query parameters
  Uri _buildUrl(String endpoint, Map<String, String>? queryParams) {
    final url = ApiConfig.getUrl(endpoint);
    final uri = Uri.parse(url);
    
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    
    return uri;
  }

  /// Prepare request headers
  Future<Map<String, String>> _prepareHeaders() async {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    
    // Add CORS headers for web
    headers['Access-Control-Allow-Origin'] = '*';
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization';
    
    // Add auth token if available
    final authHeader = await _authInterceptor.getAuthHeader();
    if (authHeader != null) {
      headers.addAll(authHeader);
    }
    
    return headers;
  }
  /// Execute HTTP request
  Future<http.Response> _executeRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await _httpClient.get(url, headers: headers)
              .timeout(ApiConfig.timeout);
        case 'POST':
          return await _httpClient.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
        case 'PUT':
          return await _httpClient.put(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
        case 'PATCH':
          return await _httpClient.patch(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
        case 'DELETE':
          return await _httpClient.delete(url, headers: headers)
              .timeout(ApiConfig.timeout);
        default:
          throw ApiException(
            type: ApiErrorType.unknown,
            message: 'Unsupported HTTP method: $method',
          );
      }
    } on SocketException {
      throw ApiException.network('No internet connection');
    } on HttpException catch (e) {
      throw ApiException.network('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException.validation('Invalid request format: ${e.message}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw ApiException.timeout();
      }
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Request failed: $e',
        originalError: e,
      );
    }
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle different status codes
      switch (response.statusCode) {
        case 200:
        case 201:
          if (fromJson != null && jsonData['data'] != null) {
            final data = fromJson(jsonData['data']);
            return ApiResponse.success(
              data: data,
              message: jsonData['message'],
              statusCode: response.statusCode,
            );
          } else {
            return ApiResponse.success(
              data: jsonData['data'],
              message: jsonData['message'],
              statusCode: response.statusCode,
            );
          }
        case 400:
          throw ApiException.validation(
            jsonData['error']?['message'] ?? 'Validation error',
            field: jsonData['error']?['field'],
          );
        case 401:
          throw ApiException.unauthorized();
        case 403:
          throw ApiException(
            type: ApiErrorType.forbidden,
            message: 'Access forbidden',
            statusCode: 403,
          );
        case 404:
          throw ApiException(
            type: ApiErrorType.notFound,
            message: 'Resource not found',
            statusCode: 404,
          );
        case 500:
        default:
          throw ApiException.server(
            jsonData['error']?['message'] ?? 'Server error',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      
      throw ApiException(
        type: ApiErrorType.unknown,
        message: 'Failed to parse response: $e',
        statusCode: response.statusCode,
        originalError: e,
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}