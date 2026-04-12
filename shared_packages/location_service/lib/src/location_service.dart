import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/location_point.dart';

/// Location service for OnMint healthcare platform
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Get current location
  Future<LocationPoint?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationPoint.fromLatLng(position.latitude, position.longitude);
    } catch (e) {
      throw LocationException('Failed to get current location: $e');
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  /// Validate coordinates
  LocationPoint? validateCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      throw LocationException('Invalid latitude: $latitude. Must be between -90 and 90');
    }
    
    if (longitude < -180 || longitude > 180) {
      throw LocationException('Invalid longitude: $longitude. Must be between -180 and 180');
    }

    return LocationPoint.fromLatLng(latitude, longitude);
  }
  /// Get location from address (geocoding)
  Future<LocationPoint?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationPoint.fromLatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      throw LocationException('Failed to get location from address: $e');
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromLocation(LocationPoint location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }
      return null;
    } catch (e) {
      throw LocationException('Failed to get address from location: $e');
    }
  }

  /// Calculate distance between two points
  double calculateDistance(LocationPoint point1, LocationPoint point2) {
    return point1.distanceTo(point2);
  }

  /// Check if location is within radius of center point
  bool isWithinRadius(LocationPoint center, LocationPoint target, double radiusKm) {
    return calculateDistance(center, target) <= radiusKm;
  }

  /// Get location settings
  Future<LocationSettings> getLocationSettings() async {
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance (in meters) to trigger location update
    );
  }

  /// Listen to location changes
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

/// Location exception class
class LocationException implements Exception {
  final String message;
  
  const LocationException(this.message);
  
  @override
  String toString() => 'LocationException: $message';
}

/// Import required for geocoding (add to pubspec.yaml if needed)
// Note: Add geocoding: ^2.1.1 to pubspec.yaml for address conversion
class Location {
  final double latitude;
  final double longitude;
  
  Location({required this.latitude, required this.longitude});
}

class Placemark {
  final String? street;
  final String? locality;
  final String? administrativeArea;
  final String? country;
  
  Placemark({this.street, this.locality, this.administrativeArea, this.country});
}

// Placeholder functions for geocoding (implement when geocoding package is added)
Future<List<Location>> locationFromAddress(String address) async {
  // This would use the geocoding package
  throw UnimplementedError('Add geocoding package to implement this feature');
}

Future<List<Placemark>> placemarkFromCoordinates(double latitude, double longitude) async {
  // This would use the geocoding package
  throw UnimplementedError('Add geocoding package to implement this feature');
}