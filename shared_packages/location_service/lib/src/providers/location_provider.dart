import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../location_service.dart';
import '../models/location_point.dart';

/// Location state provider
class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  LocationPoint? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;
  bool _serviceEnabled = false;

  /// Current location
  LocationPoint? get currentLocation => _currentLocation;
  
  /// Loading state
  bool get isLoading => _isLoading;
  
  /// Error message
  String? get error => _error;
  
  /// Permission status
  bool get hasPermission => _hasPermission;
  
  /// Service enabled status
  bool get serviceEnabled => _serviceEnabled;

  /// Initialize location service
  Future<void> initialize() async {
    _setLoading(true);
    await _checkPermissionStatus();
    await _checkServiceStatus();
    _setLoading(false);
  }

  /// Request location permission
  Future<bool> requestPermission() async {
    _setLoading(true);
    _clearError();
    
    try {
      final granted = await _locationService.requestLocationPermission();
      _hasPermission = granted;
      
      if (!granted) {
        _setError('Location permission is required to use this feature');
      }
      
      notifyListeners();
      return granted;
    } catch (e) {
      _setError('Failed to request location permission: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get current location
  Future<LocationPoint?> getCurrentLocation() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check permission first
      if (!_hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          return null;
        }
      }

      final location = await _locationService.getCurrentLocation();
      _currentLocation = location;
      notifyListeners();
      return location;
    } catch (e) {
      _setError('Failed to get current location: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Set manual location
  void setManualLocation(double latitude, double longitude) {
    try {
      final location = _locationService.validateCoordinates(latitude, longitude);
      _currentLocation = location;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Invalid coordinates: $e');
    }
  }

  /// Clear current location
  void clearLocation() {
    _currentLocation = null;
    _clearError();
    notifyListeners();
  }

  /// Check permission status
  Future<void> _checkPermissionStatus() async {
    try {
      _hasPermission = await _locationService.hasLocationPermission();
    } catch (e) {
      _hasPermission = false;
    }
  }

  /// Check service status
  Future<void> _checkServiceStatus() async {
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      _serviceEnabled = false;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
    await _checkServiceStatus();
    notifyListeners();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
    await _checkPermissionStatus();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }
}