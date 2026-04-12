import 'dart:math' as math;

/// Location Point model for GeoJSON format
class LocationPoint {
  final String type;
  final List<double> coordinates; // [longitude, latitude]
  
  const LocationPoint({
    this.type = "Point",
    required this.coordinates,
  });
  
  /// Create LocationPoint from JSON
  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      type: json['type'] ?? "Point",
      coordinates: json['coordinates'] != null 
          ? List<double>.from(json['coordinates'])
          : [0.0, 0.0],
    );
  }
  
  /// Convert LocationPoint to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
  
  /// Get longitude
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  
  /// Get latitude
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;

  /// Create from latitude and longitude
  factory LocationPoint.fromLatLng(double latitude, double longitude) {
    return LocationPoint(coordinates: [longitude, latitude]);
  }

  /// Check if coordinates are valid
  bool get isValid {
    return coordinates.length == 2 &&
           longitude >= -180 && longitude <= 180 &&
           latitude >= -90 && latitude <= 90;
  }

  /// Calculate distance to another point (in kilometers)
  double distanceTo(LocationPoint other) {
    if (!isValid || !other.isValid) return 0.0;
    
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final lat1Rad = latitude * (math.pi / 180);
    final lat2Rad = other.latitude * (math.pi / 180);
    final deltaLatRad = (other.latitude - latitude) * (math.pi / 180);
    final deltaLngRad = (other.longitude - longitude) * (math.pi / 180);
    
    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
              math.cos(lat1Rad) * math.cos(lat2Rad) *
              math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Copy with new coordinates
  LocationPoint copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return LocationPoint(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPoint &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          coordinates.length == other.coordinates.length &&
          coordinates[0] == other.coordinates[0] &&
          coordinates[1] == other.coordinates[1];

  @override
  int get hashCode => type.hashCode ^ coordinates.hashCode;

  @override
  String toString() => 'LocationPoint(lng: $longitude, lat: $latitude)';
}