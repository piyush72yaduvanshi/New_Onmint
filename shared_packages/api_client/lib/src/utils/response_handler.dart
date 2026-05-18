import 'package:dio/dio.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final Map<String, dynamic>? pagination;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.pagination,
  });

  factory ApiResponse.fromResponse(Response response) {
    final responseData = response.data;
    
    if (responseData is Map<String, dynamic>) {
      return ApiResponse<T>(
        success: responseData['success'] ?? false,
        data: responseData['data'],
        message: responseData['message'],
        error: responseData['error'],
        pagination: responseData['pagination'],
      );
    }
    
    // Fallback for non-standard responses
    return ApiResponse<T>(
      success: response.statusCode == 200,
      data: responseData,
      message: 'Success',
    );
  }

  factory ApiResponse.error(String errorMessage) {
    return ApiResponse<T>(
      success: false,
      error: errorMessage,
    );
  }
}

class ResponseHandler {
  /// Handles standard API responses with format: {success: bool, data: any, message?: string}
  static ApiResponse<T> handleResponse<T>(Response response) {
    try {
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.error('Failed to parse response: $e');
    }
  }

  /// Extracts data from API response, throwing exception if not successful
  static T extractData<T>(Response response) {
    final apiResponse = handleResponse<T>(response);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error ?? apiResponse.message ?? 'API request failed');
    }
    
    return apiResponse.data as T;
  }

  /// Extracts list data from paginated API responses
  static List<T> extractListData<T>(Response response) {
    final apiResponse = handleResponse<List<dynamic>>(response);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error ?? apiResponse.message ?? 'API request failed');
    }
    
    final data = apiResponse.data;
    if (data is List) {
      return data.cast<T>();
    }
    
    throw Exception('Expected list data but got ${data.runtimeType}');
  }

  /// Extracts paginated response with metadata
  static Map<String, dynamic> extractPaginatedData(Response response) {
    final apiResponse = handleResponse<dynamic>(response);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error ?? apiResponse.message ?? 'API request failed');
    }
    
    return {
      'data': apiResponse.data,
      'pagination': apiResponse.pagination,
      'success': apiResponse.success,
      'message': apiResponse.message,
    };
  }

  /// Handles Dio errors and converts them to user-friendly messages
  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (statusCode == 401) {
          return 'Authentication failed. Please login again.';
        } else if (statusCode == 403) {
          return 'Access denied. You don\'t have permission for this action.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 422) {
          // Validation errors
          if (responseData is Map<String, dynamic> && responseData['message'] != null) {
            return responseData['message'];
          }
          return 'Invalid data provided.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        
        // Try to extract error message from response
        if (responseData is Map<String, dynamic>) {
          return responseData['message'] ?? responseData['error'] ?? 'Request failed';
        }
        
        return 'Request failed with status $statusCode';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}