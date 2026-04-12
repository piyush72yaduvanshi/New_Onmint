/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    required this.statusCode,
  });

  /// Create successful response
  factory ApiResponse.success({
    T? data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required ApiError error,
    int statusCode = 400,
  }) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  /// Create response from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    if (json['success'] == true) {
      return ApiResponse.success(
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        message: json['message'],
      );
    } else {
      return ApiResponse.error(
        error: ApiError.fromJson(json),
      );
    }
  }
}

/// API Error class
class ApiError {
  final String code;
  final String message;
  final String? field;

  const ApiError({
    required this.code,
    required this.message,
    this.field,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errorData = json['error'] ?? json;
    return ApiError(
      code: errorData['code'] ?? 'UNKNOWN_ERROR',
      message: errorData['message'] ?? 'An unknown error occurred',
      field: errorData['field'],
    );
  }

  @override
  String toString() => 'ApiError(code: $code, message: $message, field: $field)';
}