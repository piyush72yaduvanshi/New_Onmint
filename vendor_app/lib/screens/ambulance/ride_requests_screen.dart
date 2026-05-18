import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'ride_details_screen.dart';

/// Ride requests list screen for ambulance drivers
class RideRequestsScreen extends StatefulWidget {
  const RideRequestsScreen({super.key});

  @override
  State<RideRequestsScreen> createState() => _RideRequestsScreenState();
}

class _RideRequestsScreenState extends State<RideRequestsScreen> {
  final _apiClient = OnMintApiClient();
  List<dynamic> _rides = [];
  bool _isLoading = true;
  String _selectedStatus = 'pending'; // Default to pending (requested) bookings

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.initialize();
      
      // Map frontend status to backend status
      // Backend uses: requested, accepted, on_the_way, in_progress, completed
      // Frontend uses: pending, confirmed, on-the-way, in-progress, completed
      String? backendStatus;
      switch (_selectedStatus) {
        case 'all':
          backendStatus = 'all'; // Pass 'all' to backend
          break;
        case 'pending':
          backendStatus = 'requested'; // Backend uses 'requested' for pending
          break;
        case 'confirmed':
          backendStatus = 'accepted'; // Backend uses 'accepted' for confirmed
          break;
        case 'on-the-way':
          backendStatus = 'on_the_way'; // Backend uses underscore
          break;
        case 'in-progress':
          backendStatus = 'in_progress'; // Backend uses underscore
          break;
        case 'completed':
          backendStatus = 'completed';
          break;
        case 'cancelled':
          backendStatus = 'cancelled';
          break;
        default:
          backendStatus = null;
      }
      
      final data = await _apiClient.ambulance.getRideRequests(
        status: backendStatus,
        page: 1,
        limit: 50,
      );
      
      setState(() {
        _rides = data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rides: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Requests'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedStatus,
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedStatus = value);
              _loadRides();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('🔵 All Rides')),
              const PopupMenuItem(value: 'pending', child: Text('🟠 Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('🟢 Confirmed')),
              const PopupMenuItem(value: 'on-the-way', child: Text('🟣 On The Way')),
              const PopupMenuItem(value: 'in-progress', child: Text('🔵 In Progress')),
              const PopupMenuItem(value: 'completed', child: Text('✅ Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('❌ Cancelled')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRides,
              child: _rides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No $_selectedStatus rides',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rides.length,
                      itemBuilder: (context, index) {
                        final ride = _rides[index];
                        return _buildRideCard(ride);
                      },
                    ),
            ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    final patient = ride['patient'] ?? {};
    final createdAt = DateTime.parse(ride['createdAt']);
    final status = ride['status'] ?? 'requested';
    final isEmergency = ride['isEmergency'] ?? false;
    
    // Map backend status to display status
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'requested': // Backend uses 'requested' for pending
        statusColor = Colors.orange;
        statusLabel = 'Pending';
        break;
      case 'accepted': // Backend uses 'accepted' for confirmed
        statusColor = Colors.blue;
        statusLabel = 'Confirmed';
        break;
      case 'on-the-way':
      case 'on_the_way': // Backend uses underscore
        statusColor = Colors.purple;
        statusLabel = 'On The Way';
        break;
      case 'in-progress':
      case 'in_progress': // Backend uses underscore
        statusColor = Colors.teal;
        statusLabel = 'In Progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusLabel = 'Completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusLabel = 'Cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailsScreen(
                rideId: ride['_id'],
              ),
            ),
          );
          if (result == true) {
            _loadRides();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isEmergency ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEmergency ? Icons.emergency : Icons.local_shipping,
                      color: isEmergency ? Colors.red : Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patient['fullName'] ?? 'Unknown Patient',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isEmergency) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'EMERGENCY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          patient['phone'] ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ride['pickupLocation']?['address'] ?? 'Location not available',
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (ride['dropLocation'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride['dropLocation']['address'] ?? 'Destination not set',
                        style: TextStyle(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (ride['estimatedFare'] != null)
                    Text(
                      '₹${ride['estimatedFare']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
