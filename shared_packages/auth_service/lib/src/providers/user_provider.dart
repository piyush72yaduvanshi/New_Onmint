import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// User-specific state provider
class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  /// Current user
  User? get user => _user;
  
  /// Loading state
  bool get isLoading => _isLoading;
  
  /// Error message
  String? get error => _error;

  /// Set user
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  /// Update user profile
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  /// Clear user data
  void clearUser() {
    _user = null;
    _clearError();
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Get user's full name
  String get fullName => _user?.fullName ?? '';

  /// Get user's role display name
  String get roleDisplayName {
    if (_user == null) return '';
    
    switch (_user!.role.toLowerCase()) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      case 'admin':
        return 'Administrator';
      default:
        return _user!.role.toUpperCase();
    }
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _user?.role.toLowerCase() == role.toLowerCase();
  }

  /// Check if user is vendor
  bool get isVendor => _user?.isVendor == true;

  /// Check if user is patient
  bool get isPatient => _user?.isPatient == true;

  /// Check if user is admin
  bool get isAdmin => _user?.isAdmin == true;
}