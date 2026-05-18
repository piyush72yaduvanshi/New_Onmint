import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class RealtimeTrackingService {
  static final RealtimeTrackingService _instance = RealtimeTrackingService._internal();
  factory RealtimeTrackingService() => _instance;
  RealtimeTrackingService._internal();

  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionStreamSubscription;
  
  final _locationController = StreamController<Position>.broadcast();
  Stream<Position> get locationStream => _locationController.stream;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Start tracking
  Future<void> startTracking({
    required Function(Position) onLocationUpdate,
    Function(String)? onError,
  }) async {
    try {
      // Get initial position
      final initialPosition = await _locationService.getCurrentLocation();
      if (initialPosition != null) {
        _currentPosition = initialPosition;
        onLocationUpdate(initialPosition);
        _locationController.add(initialPosition);
      }

      // Start listening to location updates
      _positionStreamSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          _currentPosition = position;
          onLocationUpdate(position);
          _locationController.add(position);
        },
        onError: (error) {
          onError?.call(error.toString());
        },
      );
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  // Stop tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Update location to backend (for ambulance/provider tracking)
  Future<void> updateLocationToBackend({
    required String token,
    required double latitude,
    required double longitude,
    String? bookingId,
  }) async {
    // This should call your backend API to update location
    // Backend can then broadcast this to connected clients via Socket.IO
    
    // Example implementation:
    // await http.post(
    //   Uri.parse('YOUR_BACKEND_URL/api/v1/location/update'),
    //   headers: {
    //     'Authorization': 'Bearer $token',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'latitude': latitude,
    //     'longitude': longitude,
    //     'bookingId': bookingId,
    //     'timestamp': DateTime.now().toIso8601String(),
    //   }),
    // );
  }

  // Calculate ETA (Estimated Time of Arrival)
  String calculateETA({
    required double distanceInKm,
    double averageSpeedKmh = 40, // Average speed in city
  }) {
    final timeInHours = distanceInKm / averageSpeedKmh;
    final timeInMinutes = (timeInHours * 60).round();
    
    if (timeInMinutes < 60) {
      return '$timeInMinutes min';
    } else {
      final hours = timeInMinutes ~/ 60;
      final minutes = timeInMinutes % 60;
      return '${hours}h ${minutes}min';
    }
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
