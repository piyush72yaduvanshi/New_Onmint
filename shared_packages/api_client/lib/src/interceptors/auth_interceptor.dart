import 'package:shared_preferences/shared_preferences.dart';

/// Authentication interceptor for adding JWT tokens to requests
class AuthInterceptor {
  static const String _tokenKey = 'auth_token';
  String? _currentToken;

  /// Set authentication token
  void setToken(String token) {
    _currentToken = token;
    _saveTokenToStorage(token);
  }

  /// Clear authentication token
  void clearToken() {
    _currentToken = null;
    _removeTokenFromStorage();
  }

  /// Get authentication header if token is available
  Future<Map<String, String>?> getAuthHeader() async {
    final token = _currentToken ?? await _getTokenFromStorage();
    
    if (token != null && token.isNotEmpty) {
      return {
        'Authorization': 'Bearer $token',
      };
    }
    
    return null;
  }

  /// Save token to persistent storage
  Future<void> _saveTokenToStorage(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      // Handle storage error silently
      print('Failed to save token to storage: $e');
    }
  }

  /// Get token from persistent storage
  Future<String?> _getTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      _currentToken = token;
      return token;
    } catch (e) {
      // Handle storage error silently
      print('Failed to get token from storage: $e');
      return null;
    }
  }

  /// Remove token from persistent storage
  Future<void> _removeTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      // Handle storage error silently
      print('Failed to remove token from storage: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = _currentToken ?? await _getTokenFromStorage();
    return token != null && token.isNotEmpty;
  }
}