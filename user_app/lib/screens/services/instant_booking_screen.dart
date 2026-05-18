import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:api_client/api_client.dart';

/// Instant Booking Screen - Quick emergency service booking
/// Only requires: location (auto-detected) and type (doctor/ambulance)
class InstantBookingScreen extends StatefulWidget {
  final String serviceType; // 'doctor' or 'ambulance'
  
  const InstantBookingScreen({
    super.key,
    required this.serviceType,
  });

  @override
  State<InstantBookingScreen> createState() => _InstantBookingScreenState();
}

class _InstantBookingScreenState extends State<InstantBookingScreen> {
  final _apiClient = OnMintApiClient();
  late final PatientService _patientService;
  
  bool _isGettingLocation = false;
  bool _isBooking = false;
  Position? _currentPosition;
  String _locationStatus = 'Detecting your location...';

  @override
  void initState() {
    super.initState();
    _patientService = PatientService(); // Create without passing apiClient
    _initializeAndGetLocation();
  }

  Future<void> _initializeAndGetLocation() async {
    // Initialize API client first to load auth token
    await _apiClient.initialize();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Detecting your location...';
    });

    try {
      // Request location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        setState(() {
          _locationStatus = 'Location permission denied';
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationStatus = 'Location detected: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: ${e.toString()}';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _bookInstantService() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for location detection'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      // Create emergency booking with only required fields
      await _patientService.triggerEmergency(
        location: {
          'type': 'Point',
          'coordinates': [
            _currentPosition!.longitude,
            _currentPosition!.latitude,
          ],
        },
        type: widget.serviceType,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.serviceType == 'doctor'
                  ? 'Emergency doctor request sent! You will receive a video call shortly.'
                  : 'Emergency ambulance dispatched! Help is on the way.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.serviceType == 'doctor';
    final color = isDoctor ? Colors.blue : Colors.red;
    final icon = isDoctor ? Icons.video_call : Icons.local_shipping;
    final title = isDoctor ? 'Instant Doctor Consultation' : 'Emergency Ambulance';
    final description = isDoctor
        ? 'Get instant video consultation with an available doctor'
        : 'Request emergency ambulance service to your location';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Service Icon
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: color,
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Location Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentPosition != null
                        ? Icons.location_on
                        : Icons.location_searching,
                    color: _currentPosition != null ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationStatus,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isGettingLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDoctor
                          ? 'A doctor will connect with you via video call within 5 minutes'
                          : 'An ambulance will be dispatched to your location immediately',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Request Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isBooking || _isGettingLocation || _currentPosition == null)
                    ? null
                    : _bookInstantService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isDoctor ? 'Request Doctor Now' : 'Request Ambulance Now',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Retry Location Button
            if (_currentPosition == null && !_isGettingLocation)
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Location Detection'),
              ),
          ],
        ),
      ),
    );
  }
}
