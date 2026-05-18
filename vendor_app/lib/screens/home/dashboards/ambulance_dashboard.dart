import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../../config/app_colors.dart';
import '../../ambulance/ride_details_screen.dart';
import '../../ambulance/ride_requests_screen.dart';

class AmbulanceDashboard extends StatefulWidget {
  const AmbulanceDashboard({super.key});

  @override
  State<AmbulanceDashboard> createState() => _AmbulanceDashboardState();
}

class _AmbulanceDashboardState extends State<AmbulanceDashboard> {
  final _apiClient = OnMintApiClient();
  DashboardStats? _dashboardData;
  List<Booking> _activeRequests = [];
  bool _isLoading = true;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.initialize();
      final data = await _apiClient.ambulance.getDashboard();
      // Fetch ALL ride requests with status='all'
      final requestsData = await _apiClient.ambulance.getRideRequests(
        page: 1,
        limit: 20,
        status: 'all', // Pass 'all' to get all statuses
      );
      setState(() {
        _dashboardData = data;
        _isAvailable = data.isAvailable ?? true;
        _activeRequests = (requestsData['data'] as List?)?.map((e) => Booking.fromJson(e)).toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastUtils.showError('Failed to load dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvailabilityToggle(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildActiveRequests(),
                ],
              ),
            ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppColors.ambulance, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Availability Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_isAvailable ? 'Available for requests' : 'Not available', 
                    style: TextStyle(fontSize: 12, color: _isAvailable ? AppColors.success : AppColors.error)),
                ],
              ),
            ),
            Switch(
              value: _isAvailable,
              onChanged: (value) => _toggleAvailability(value),
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.edit,
                title: 'Edit Profile',
                color: AppColors.info,
                onTap: _showEditProfileDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on,
                title: 'Update Location',
                color: AppColors.success,
                onTap: _updateCurrentLocation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _dashboardData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Active', '${stats?.activeRides ?? 0}', Icons.pending, AppColors.ambulance)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Completed', '${stats?.totalRides ?? 0}', Icons.check_circle, AppColors.success)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildActiveRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Ride Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // Navigate to full ride requests screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RideRequestsScreen(),
                  ),
                ).then((_) => _loadDashboard()); // Refresh on return
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activeRequests.isEmpty)
          const EmptyStateWidget(
            icon: Icons.local_shipping,
            title: 'No Requests',
            message: 'No ride requests at the moment',
          )
        else
          ..._activeRequests.map((request) => _buildRequestCard(request)),
      ],
    );
  }

  Widget _buildRequestCard(Booking request) {
    final status = request.status ?? 'requested';
    final canAccept = status == 'requested';
    
    // Status colors
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'requested':
        statusColor = AppColors.warning;
        statusLabel = 'PENDING';
        break;
      case 'accepted':
        statusColor = AppColors.info;
        statusLabel = 'ACCEPTED';
        break;
      case 'on-the-way':
      case 'on_the_way': // Backend uses underscore
        statusColor = AppColors.primary;
        statusLabel = 'ON THE WAY';
        break;
      case 'in-progress':
      case 'in_progress': // Backend uses underscore
        statusColor = AppColors.info;
        statusLabel = 'IN PROGRESS';
        break;
      case 'completed':
        statusColor = AppColors.success;
        statusLabel = 'COMPLETED';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusLabel = status.toUpperCase();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to ride details screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailsScreen(rideId: request.id),
            ),
          ).then((_) => _loadDashboard()); // Refresh on return
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
                      color: request.isEmergency ? AppColors.error.withOpacity(0.1) : AppColors.ambulance.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      request.isEmergency ? Icons.emergency : Icons.local_shipping,
                      color: request.isEmergency ? AppColors.error : AppColors.ambulance,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.patientDetails?.fullName ?? 'Patient',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (request.location.address != null)
                          Text(
                            request.location.address!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (request.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  request.notes!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (canAccept)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptRequest(request.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ambulance,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept Request'),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to ride details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideDetailsScreen(rideId: request.id),
                            ),
                          ).then((_) => _loadDashboard()); // Refresh on return
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: statusColor,
                        ),
                        child: const Text('View Details'),
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

  Future<void> _toggleAvailability(bool value) async {
    try {
      await _apiClient.ambulance.setAvailability(value);
      setState(() => _isAvailable = value);
      ToastUtils.showSuccess(value ? 'You are now available' : 'You are now unavailable');
    } catch (e) {
      ToastUtils.showError('Failed to update availability');
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await _apiClient.ambulance.acceptRideRequest(requestId);
      ToastUtils.showSuccess('Request accepted successfully');
      _loadDashboard(); // Refresh to remove accepted request from list
    } catch (e) {
      // Handle specific error messages
      final errorMessage = e.toString();
      if (errorMessage.contains('already accepted')) {
        ToastUtils.showError('This booking has already been accepted');
        _loadDashboard(); // Refresh to remove from list
      } else if (errorMessage.contains('not assigned')) {
        ToastUtils.showError('This booking is not assigned to you');
        _loadDashboard(); // Refresh list
      } else {
        ToastUtils.showError('Failed to accept request: ${e.toString()}');
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleTypeController = TextEditingController();
    final vehicleNumberController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Advanced Life Support',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., MH-12-AB-1234',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ambulance,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final updates = <String, dynamic>{};
        if (firstNameController.text.isNotEmpty) {
          updates['firstName'] = firstNameController.text;
        }
        if (lastNameController.text.isNotEmpty) {
          updates['lastName'] = lastNameController.text;
        }
        if (phoneController.text.isNotEmpty) {
          updates['phone'] = phoneController.text;
        }
        if (vehicleTypeController.text.isNotEmpty) {
          updates['vehicleType'] = vehicleTypeController.text;
        }
        if (vehicleNumberController.text.isNotEmpty) {
          updates['vehicleNumber'] = vehicleNumberController.text;
        }

        if (updates.isNotEmpty) {
          await _apiClient.ambulance.updateProfile(updates);
          ToastUtils.showSuccess('Profile updated successfully');
          _loadDashboard();
        }
      } catch (e) {
        ToastUtils.showError('Failed to update profile: ${e.toString()}');
      }
    }
  }

  Future<void> _updateCurrentLocation() async {
    try {
      ToastUtils.showInfo('Getting current location...');
      
      // For demo purposes, using fixed coordinates
      // In production, use location package to get actual GPS coordinates
      const latitude = 19.076;
      const longitude = 72.8777;
      
      await _apiClient.ambulance.updateLocation(latitude, longitude);
      ToastUtils.showSuccess('Location updated successfully');
    } catch (e) {
      ToastUtils.showError('Failed to update location: ${e.toString()}');
    }
  }
}
