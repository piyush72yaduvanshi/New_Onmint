import 'dart:math' as math;
import '../models/location_point.dart';

/// Utility functions for location operations
class LocationUtils {
  /// Convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Convert radians to degrees
  static double radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  /// Calculate bearing between two points
  static double calculateBearing(LocationPoint from, LocationPoint to) {
    final lat1 = degreesToRadians(from.latitude);
    final lat2 = degreesToRadians(to.latitude);
    final deltaLng = degreesToRadians(to.longitude - from.longitude);

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = radiansToDegrees(math.atan2(y, x));
    return (bearing + 360) % 360; // Normalize to 0-360 degrees
  }

  /// Get compass direction from bearing
  static String getCompassDirection(double bearing) {
    const directions = [                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Format coordinates for display
  static String formatCoordinates(LocationPoint location) {
    return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  /// Check if coordinates are in India (approximate bounds)
  static bool isInIndia(LocationPoint location) {
    const double minLat = 6.0;
    const double maxLat = 37.0;
    const double minLng = 68.0;
    const double maxLng = 98.0;

    return location.latitude >= minLat &&
           location.latitude <= maxLat &&
           location.longitude >= minLng &&
           location.longitude <= maxLng;
  }

  /// Get center point of multiple locations
  static LocationPoint? getCenterPoint(List<LocationPoint> locations) {
    if (locations.isEmpty) return null;
    if (locations.length == 1) return locations.first;

    double totalLat = 0;
    double totalLng = 0;

    for (final location in locations) {
      totalLat += location.latitude;
      totalLng += location.longitude;
    }

    return LocationPoint.fromLatLng(
      totalLat / locations.length,
      totalLng / locations.length,
    );
  }

  /// Find nearest location from a list
  static LocationPoint? findNearest(LocationPoint target, List<LocationPoint> locations) {
    if (locations.isEmpty) return null;

    LocationPoint? nearest;
    double minDistance = double.infinity;

    for (final location in locations) {
      final distance = target.distanceTo(location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = location;
      }
    }

    return nearest;
  }

  /// Filter locations within radius
  static List<LocationPoint> filterWithinRadius(
    LocationPoint center,
    List<LocationPoint> locations,
    double radiusKm,
  ) {
    return locations.where((location) {
      return center.distanceTo(location) <= radiusKm;
    }).toList();
  }

  /// Sort locations by distance from center
  static List<LocationPoint> sortByDistance(
    LocationPoint center,
    List<LocationPoint> locations,
  ) {
    final locationsWithDistance = locations.map((location) {
      return {
        'location': location,
        'distance': center.distanceTo(location),
      };
    }).toList();

    locationsWithDistance.sort((a, b) {
      return (a['distance'] as double).compareTo(b['distance'] as double);
    });

    return locationsWithDistance
        .map((item) => item['location'] as LocationPoint)
        .toList();
  }

  /// Validate Indian pincode format
  static bool isValidIndianPincode(String pincode) {
    return RegExp(r'^\d{6}$').hasMatch(pincode);
  }

  /// Validate Indian phone number format
  static bool isValidIndianPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }
}