import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_client/api_client.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final OnMintApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthProvider(this._apiClient);

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isLoading => _status == AuthStatus.loading;
  String? get userRole => _user?.role;
  bool get isAdmin => _user?.role == 'admin';
  bool get isPatient => _user?.role == 'patient';
  bool get isDoctor => _user?.role == 'doctor';
  bool get isNurse => _user?.role == 'nurse';
  bool get isPharmacist => _user?.role == 'pharmacist';
  bool get isAmbulance => _user?.role == 'ambulance';
  bool get isBloodBank => _user?.role == 'bloodbank';
  bool get isPathology => _user?.role == 'pathology';
  User? get currentUser => _user;
  String? get currentToken => _apiClient.token;

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _apiClient.initialize();
      
      if (_apiClient.isAuthenticated) {
        await loadUser();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }
    
    notifyListeners();
  }

  Future<void> loadUser() async {
    try {
      _user = await _apiClient.auth.getProfile();
      _status = AuthStatus.authenticated;
      _error = null;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _error = e.toString();
    }
    notifyListeners();
  }
  
  Future<void> refreshUser() async {
    await loadUser();
  }

  Future<bool> login({
    required String phone,
    required String password,
    String? email,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final credentials = {
        'phone': phone,
        'password': password,
        if (email != null) 'email': email,
      };

      final response = await _apiClient.auth.login(credentials);
      
      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.auth.register(data);
      
      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithFiles(Map<String, dynamic> data, Map<String, String> files) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.auth.registerWithFiles(data, files);
      
      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.auth.logout();
    } catch (e) {
      // Ignore errors during logout
    }
    
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  Future<void> forceLogout() async {
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    await _apiClient.clearToken();
    notifyListeners();
  }

  Future<bool> updateDeviceToken(String deviceToken) async {
    try {
      await _apiClient.auth.updateDeviceToken(deviceToken);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.auth.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
