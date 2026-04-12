/// API Error types and handling
enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? field;
  final dynamic originalError;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.field,
    this.originalError,
  });

  /// Create network error
  factory ApiException.network(String message) {
    return ApiException(
      type: ApiErrorType.network,
      message: message,
    );
  }

  /// Create timeout error
  factory ApiException.timeout() {
    return const ApiException(
      type: ApiErrorType.timeout,
      message: 'Request timeout. Please check your connection and try again.',
    );
  }

  /// Create unauthorized error
  factory ApiException.unauthorized() {
    return const ApiException(
      type: ApiErrorType.unauthorized,
      message: 'Unauthorized access. Please login again.',
      statusCode: 401,
    );
  }

  /// Create validation error
  factory ApiException.validation(String message, {String? field}) {
    return ApiException(
      type: ApiErrorType.validation,
      message: message,
      field: field,
      statusCode: 400,
    );
  }

  /// Create server error
  factory ApiException.server(String message, {int? statusCode}) {
    return ApiException(
      type: ApiErrorType.server,
      message: message,
      statusCode: statusCode ?? 500,
    );
  }

  @override
  String toString() => 'ApiException: $message (Type: $type, Status: $statusCode)';
}