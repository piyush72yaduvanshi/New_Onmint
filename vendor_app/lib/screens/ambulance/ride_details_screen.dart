import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import '../../services/location_update_service.dart';

/// Ride details screen for ambulance drivers with location tracking
class RideDetailsScreen extends StatefulWidget {
  final String rideId;

  const RideDetailsScreen({
    super.key,
    required this.rideId,
  });

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final _apiClient = OnMintApiClient();
  final _locationService = LocationUpdateService();
  Map<String, dynamic>? _ride;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadRide();
  }

  @override
  void dispose() {
    // Stop location updates if running
    if (_locationService.isUpdating) {
      _locationService.stopLocationUpdates();
    }
    super.dispose();
  }

  Future<void> _loadRide() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiClient.ambulance.getRideDetails(widget.rideId);
      setState(() {
        _ride = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ride: $e')),
        );
      }
    }
  }

  Future<void> _acceptRide() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.ambulance.acceptRideRequest(widget.rideId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride accepted')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectRide() async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    setState(() => _isProcessing = true);
    try {
      // Note: Backend doesn't have reject endpoint yet, so we'll just show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reject functionality coming soon')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startRide() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.ambulance.startRide(widget.rideId);
      
      // Start location updates
      final token = _apiClient.token ?? '';
      await _locationService.startLocationUpdates(
        bookingId: widget.rideId,
        token: token,
        intervalSeconds: 5,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride started - Location tracking enabled')),
        );
        _loadRide();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markArrived() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.ambulance.arriveAtPickup(widget.rideId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as arrived')),
        );
        _loadRide();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completeRide() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.ambulance.completeRide(widget.rideId);
      
      // Stop location updates
      _locationService.stopLocationUpdates();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride completed')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Ride'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ride == null
              ? const Center(child: Text('Ride not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emergency Badge
                      if (_ride!['isEmergency'] == true)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emergency, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'EMERGENCY RIDE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      _buildSection('Patient Information', [
                        _buildInfoRow('Name', _ride!['patient']?['fullName'] ?? 'N/A'),
                        _buildInfoRow('Phone', _ride!['patient']?['phone'] ?? 'N/A'),
                        _buildInfoRow('Age', '${_ride!['patient']?['age'] ?? 'N/A'} years'),
                        _buildInfoRow('Gender', _ride!['patient']?['gender'] ?? 'N/A'),
                      ]),
                      
                      const SizedBox(height: 20),
                      
                      _buildSection('Ride Details', [
                        _buildInfoRow('Status', _ride!['status'] ?? 'N/A'),
                        _buildInfoRow('Pickup', _ride!['pickupLocation']?['address'] ?? 'N/A'),
                        if (_ride!['dropLocation'] != null)
                          _buildInfoRow('Drop', _ride!['dropLocation']['address']),
                        if (_ride!['estimatedFare'] != null)
                          _buildInfoRow('Fare', '₹${_ride!['estimatedFare']}'),
                        if (_ride!['distance'] != null)
                          _buildInfoRow('Distance', '${_ride!['distance']} km'),
                      ]),
                      
                      if (_ride!['notes'] != null) ...[
                        const SizedBox(height: 20),
                        _buildSection('Patient Notes', [
                          Text(_ride!['notes']),
                        ]),
                      ],
                      
                      // Location Tracking Status
                      if (_locationService.isUpdating) ...[
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.green.shade50,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.gps_fixed, color: Colors.green),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Location tracking active',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons - Only show for appropriate status
                      // Backend uses 'requested' status for pending bookings
                      if (_ride!['status'] == 'requested') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _acceptRide,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isProcessing
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Accept'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isProcessing ? null : _rejectRide,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      if (_ride!['status'] == 'accepted') ...[
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _startRide,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Ride'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      
                      if (_ride!['status'] == 'on_the_way') ...[
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _markArrived,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Arrive at Pickup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      
                      if (_ride!['status'] == 'in_progress') ...[
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _completeRide,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Complete Ride'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      
                      // Call Patient Button
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Call patient
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Patient'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
