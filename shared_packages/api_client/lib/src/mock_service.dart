import 'dart:convert';
import 'dart:math';
import 'api_response.dart';

/// Mock service for development when backend is not available
class MockService {
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;
  MockService._internal();

  /// Mock registration endpoint
  Future<ApiResponse<Map<String, dynamic>>> mockRegister(Map<String, dynamic> registrationData) async {
    print('🎭 Mock Service: Handling registration request');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Validate required fields
    final requiredFields = ['email', 'password', 'firstName', 'lastName', 'phone', 'role'];
    for (final field in requiredFields) {
      if (!registrationData.containsKey(field) || registrationData[field] == null || registrationData[field].toString().isEmpty) {
        return ApiResponse.error(
          error: ApiError(
            code: 'VALIDATION_ERROR',
            message: '$field is required',
            field: field,
          ),
          statusCode: 400,
        );
      }
    }
    
    // Simulate email already exists error (for testing)
    if (registrationData['email'] == 'test@example.com') {
      return ApiResponse.error(
        error: ApiError(
          code: 'EMAIL_EXISTS',
          message: 'Email already exists',
          field: 'email',
        ),
        statusCode: 409,
      );
    }
    
    // Generate mock user data
    final userId = _generateId();
    final mockUser = {
      'id': userId,
      'email': registrationData['email'],
      'firstName': registrationData['firstName'],
      'lastName': registrationData['lastName'],
      'phone': registrationData['phone'],
      'role': registrationData['role'],
      'city': registrationData['city'],
      'state': registrationData['state'],
      'pincode': registrationData['pincode'],
      'location': registrationData['location'],
      'isActive': true,
      'isVerified': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    // Generate mock token
    final mockToken = _generateToken(userId, registrationData['role']);
    
    print('✅ Mock Service: Registration successful');
    
    return ApiResponse.success(
      data: {
        'user': mockUser,
        'token': mockToken,
        'message': 'Registration successful',
      },
      message: 'User registered successfully',
      statusCode: 201,
    );
  }
  
  /// Mock login endpoint
  Future<ApiResponse<Map<String, dynamic>>> mockLogin(String email, String password) async {
    print('🎭 Mock Service: Handling login request');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Validate credentials
    if (email.isEmpty || password.isEmpty) {
      return ApiResponse.error(
        error: ApiError(
          code: 'VALIDATION_ERROR',
          message: 'Email and password are required',
        ),
        statusCode: 400,
      );
    }
    
    // Simulate invalid credentials (for testing)
    if (email == 'invalid@example.com') {
      return ApiResponse.error(
        error: ApiError(
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        ),
        statusCode: 401,
      );
    }
    
    // Generate mock user data
    final userId = _generateId();
    final mockUser = {
      'id': userId,
      'email': email,
      'firstName': 'Mock',
      'lastName': 'User',
      'phone': '9876543210',
      'role': 'patient',
      'city': 'Mumbai',
      'state': 'Maharashtra',
      'pincode': '400001',
      'location': {
        'type': 'Point',
        'coordinates': [72.8777, 19.0760]
      },
      'isActive': true,
      'isVerified': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    // Generate mock token
    final mockToken = _generateToken(userId, 'patient');
    
    print('✅ Mock Service: Login successful');
    
    return ApiResponse.success(
      data: {
        'user': mockUser,
        'token': mockToken,
        'message': 'Login successful',
      },
      message: 'Login successful',
      statusCode: 200,
    );
  }
  
  /// Mock logout endpoint
  Future<ApiResponse<void>> mockLogout() async {
    print('🎭 Mock Service: Handling logout request');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    print('✅ Mock Service: Logout successful');
    
    return ApiResponse.success(
      message: 'Logout successful',
      statusCode: 200,
    );
  }
  
  /// Generate mock ID
  String _generateId() {
    final random = Random();
    return 'mock_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }
  
  /// Generate mock JWT token
  String _generateToken(String userId, String role) {
    final header = base64Encode(utf8.encode(jsonEncode({
      'typ': 'JWT',
      'alg': 'HS256'
    })));
    
    final payload = base64Encode(utf8.encode(jsonEncode({
      'sub': userId,
      'role': role,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    })));
    
    final signature = base64Encode(utf8.encode('mock_signature'));
    
    return '$header.$payload.$signature';
  }
}