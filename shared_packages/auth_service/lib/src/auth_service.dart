import 'package:api_client/api_client.dart';
import 'models/registration_request.dart';
import 'models/login_request.dart';

/// Authentication service for OnMint healthcare platform
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> registrationData) async {
    try {
      print('🌐 Making real API call to: ${ApiConfig.getUrl(ApiConfig.authRegister)}');
      print('📤 Registration payload: $registrationData');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.authRegister,
        body: registrationData,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('📥 Registration response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Registration API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REGISTRATION_ERROR',
          message: 'Registration failed: $e',
        ),
      );
    }
  }

  /// Login user
  Future<ApiResponse<Map<String, dynamic>>> login(String phone, String password) async {
    try {
      print('Making real API call to: ${ApiConfig.getUrl(ApiConfig.authLogin)}');
      
      final loginData = {'phone': phone, 'password': password};
      print('Login payload: $loginData');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.authLogin,
        body: loginData,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('Login response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Login API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'LOGIN_ERROR',
          message: 'Login failed: $e',
        ),
      );
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      print('🌐 Making real API call to: ${ApiConfig.getUrl(ApiConfig.authLogout)}');
      
      final response = await _apiClient.post<void>(
        ApiConfig.authLogout,
        fromJson: (_) => null,
      );
      
      print('📥 Logout response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Logout API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'LOGOUT_ERROR',
          message: 'Logout failed: $e',
        ),
      );
    }
  }

  /// Refresh authentication token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken(String token) async {
    try {
      print('🌐 Making real API call to: ${ApiConfig.getUrl(ApiConfig.authRefresh)}');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.authRefresh,
        body: {'token': token},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('📥 Refresh token response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Refresh token API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REFRESH_ERROR',
          message: 'Token refresh failed: $e',
        ),
      );
    }
  }

  /// Get user profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      print('🌐 Making real API call to: ${ApiConfig.getUrl(ApiConfig.authProfile)}');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.authProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('📥 Get profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Get profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'PROFILE_ERROR',
          message: 'Failed to get profile: $e',
        ),
      );
    }
  }

  /// Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('🌐 Making real API call to: ${ApiConfig.getUrl(ApiConfig.authProfile)}');
      print('📤 Update profile payload: $profileData');
      
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConfig.authProfile,
        body: profileData,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('📥 Update profile response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Update profile API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UPDATE_PROFILE_ERROR',
          message: 'Profile update failed: $e',
        ),
      );
    }
  }
}