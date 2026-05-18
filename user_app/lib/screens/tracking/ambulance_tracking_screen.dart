import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:api_client/api_client.dart';
import '../../config/app_colors.dart';

class AmbulanceTrackingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const AmbulanceTrackingScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<AmbulanceTrackingScreen> createState() => _AmbulanceTrackingScreenState();
}

class _AmbulanceTrackingScreenState extends State<AmbulanceTrackingScreen> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  LatLng? _ambulancePosition;
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  
  final _socketService = SocketService();
  StreamSubscription? _locationSubscription;
  StreamSubscription? _statusSubscription;
  
  String _status = 'Ambulance on the way';
  String _eta = 'Calculating...';
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    _socketService.leaveBooking(widget.bookingId);
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeTracking() async {
    // Get user's current location
    await _getUserLocation();
    
    // Connect to Socket.IO and start real-time tracking
    _startRealTimeTracking();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _userPosition = position;
        _updateMarkers();
      });
      
      // Animate camera to user location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startRealTimeTracking() {
    // TODO: Get actual token from auth service
    const token = 'your_access_token';
    
    // Connect to Socket.IO
    _socketService.connect(token);
    
    // Join booking room
    _socketService.joinBooking(widget.bookingId);
    
    // Listen for real-time location updates from ambulance
    _locationSubscription = _socketService.locationUpdates.listen((data) {
      if (data['bookingId'] == widget.bookingId) {
        setState(() {
          _ambulancePosition = LatLng(
            data['latitude'] as double,
            data['longitude'] as double,
          );
          _updateMarkers();
          _updateRoute();
          _calculateETA();
          
          // Check if ambulance has arrived
          if (_distance < 0.1) {
            setState(() {
              _status = 'Ambulance has arrived!';
              _eta = 'Arrived';
            });
          }
        });
      }
    });
    
    // Listen for status updates
    _statusSubscription = _socketService.statusUpdates.listen((data) {
      if (data['bookingId'] == widget.bookingId) {
        setState(() {
          _status = data['message'] ?? _status;
        });
      }
    });
  }

  void _updateMarkers() {
    _markers.clear();
    
    // User marker
    if (_userPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Pickup point',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    // Ambulance marker
    if (_ambulancePosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('ambulance'),
          position: _ambulancePosition!,
          infoWindow: InfoWindow(
            title: 'Ambulance',
            snippet: widget.bookingData['ambulanceNumber'] ?? 'On the way',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: _calculateBearing(),
        ),
      );
    }
  }

  void _updateRoute() {
    if (_ambulancePosition == null || _userPosition == null) return;
    
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          _ambulancePosition!,
          LatLng(_userPosition!.latitude, _userPosition!.longitude),
        ],
        color: Colors.red,
        width: 5,
        geodesic: true,
      ),
    );
  }

  void _calculateETA() {
    if (_ambulancePosition == null || _userPosition == null) return;
    
    _distance = Geolocator.distanceBetween(
      _ambulancePosition!.latitude,
      _ambulancePosition!.longitude,
      _userPosition!.latitude,
      _userPosition!.longitude,
    ) / 1000; // Convert to km
    
    // Calculate ETA (assuming 40 km/h average speed)
    final timeInHours = _distance / 40;
    final timeInMinutes = (timeInHours * 60).round();
    
    setState(() {
      _eta = timeInMinutes < 1 ? 'Less than 1 min' : '$timeInMinutes min';
    });
  }

  double _calculateBearing() {
    if (_ambulancePosition == null || _userPosition == null) return 0;
    
    return Geolocator.bearingBetween(
      _ambulancePosition!.latitude,
      _ambulancePosition!.longitude,
      _userPosition!.latitude,
      _userPosition!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Ambulance'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userPosition != null
                  ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                  : const LatLng(20.5937, 78.9629),
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          
          // Status Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _status,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.bookingData['ambulanceNumber'] ?? 'Ambulance',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          'ETA',
                          _eta,
                          Icons.access_time,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        _buildInfoItem(
                          'Distance',
                          '${_distance.toStringAsFixed(1)} km',
                          Icons.location_on,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Action Card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Call ambulance driver
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Call Driver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Share location
                            },
                            icon: const Icon(Icons.share_location),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.red, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
