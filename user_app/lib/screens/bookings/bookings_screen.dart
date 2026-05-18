import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import 'package:api_client/api_client.dart';
import '../../config/app_colors.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiClient = OnMintApiClient();
  
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoadingActive = false;
  bool _isLoadingAll = false;
  String? _activeError;
  String? _allError;
  int _currentPage = 1;
  bool _hasMoreBookings = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActiveBookings();
    _loadAllBookings(refresh: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveBookings() async {
    setState(() {
      _isLoadingActive = true;
      _activeError = null;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.patient.getActiveBookings();
      setState(() {
        _activeBookings = response.map((booking) => booking.toJson()).toList();
      });
    } catch (e) {
      setState(() {
        _activeError = 'Error loading active bookings: $e';
      });
    } finally {
      setState(() {
        _isLoadingActive = false;
      });
    }
  }

  Future<void> _loadAllBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    setState(() {
      _isLoadingAll = true;
      _allError = null;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.patient.getBookings(
        page: _currentPage,
        limit: 10,
      );

      // Handle the actual API response format: {success: true, data: [...], pagination: {...}}
      List<Map<String, dynamic>> newBookings = [];
      Map<String, dynamic> pagination = {};
      
      if (response['success'] == true) {
        if (response['data'] is List) {
          newBookings = (response['data'] as List).cast<Map<String, dynamic>>();
        }
        if (response['pagination'] is Map) {
          pagination = response['pagination'] as Map<String, dynamic>;
        }
      }
      
      setState(() {
        if (refresh) {
          _allBookings = newBookings;
        } else {
          _allBookings.addAll(newBookings);
        }
        
        _hasMoreBookings = pagination['hasNext'] ?? false;
        _currentPage = pagination['page'] ?? 1;
      });
    } catch (e) {
      setState(() {
        _allError = 'Error loading bookings: $e';
      });
    } finally {
      setState(() {
        _isLoadingAll = false;
      });
    }
  }

  Future<void> _loadMoreBookings() async {
    if (_hasMoreBookings && !_isLoadingAll) {
      _currentPage++;
      await _loadAllBookings();
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiClient.initialize();
        await _apiClient.patient.cancelBooking(bookingId, reason: 'User requested cancellation');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh both lists
        _loadActiveBookings();
        _loadAllBookings(refresh: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rateBooking(String bookingId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RateBookingDialog(),
    );

    if (result != null) {
      try {
        await _apiClient.initialize();
        await _apiClient.patient.rateBooking(
          bookingId,
          rating: result['rating'],
          review: result['review'],
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rating submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh both lists
        _loadActiveBookings();
        _loadAllBookings(refresh: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting rating: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewBookingDetails(String bookingId) async {
    try {
      await _apiClient.initialize();
      final response = await _apiClient.patient.getBookingDetails(bookingId);
      showDialog(
        context: context,
        builder: (context) => _BookingDetailsDialog(booking: response.toJson()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading booking details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'All Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveBookingsTab(),
          _buildAllBookingsTab(),
        ],
      ),
    );
  }

  Widget _buildActiveBookingsTab() {
    if (_isLoadingActive) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_activeError!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadActiveBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_activeBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Your active appointments will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActiveBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeBookings.length,
        itemBuilder: (context, index) {
          final booking = _activeBookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildAllBookingsTab() {
    if (_isLoadingAll && _allBookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allError != null && _allBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_allError!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadAllBookings(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allBookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Your booking history will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadAllBookings(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allBookings.length + (_hasMoreBookings ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _allBookings.length) {
            // Load more indicator
            return Container(
              padding: const EdgeInsets.all(16),
              child: _isLoadingAll
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _loadMoreBookings,
                      child: const Text('Load More'),
                    ),
            );
          }

          final booking = _allBookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final bookingId = booking['_id'] ?? '';
    final serviceType = booking['serviceType'] ?? 'Unknown';
    final status = booking['status'] ?? 'pending';
    final scheduledTime = booking['scheduledTime'];
    final providerName = booking['provider']?['firstName'] ?? 'Provider';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: _getServiceColor(serviceType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getServiceIcon(serviceType),
                    color: _getServiceColor(serviceType),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceType.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (scheduledTime != null)
                        Text(
                          '$serviceType • ${DateFormatter.formatForCard(scheduledTime)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Provider: $providerName',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewBookingDetails(bookingId),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'confirmed' || status == 'pending')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(bookingId),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                if (status == 'completed')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rateBooking(bookingId),
                      icon: const Icon(Icons.star_outline, size: 16),
                      label: const Text('Rate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.info;
      case 'completed':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'doctor':
        return AppColors.doctor;
      case 'nurse':
        return AppColors.nurse;
      case 'pathology':
        return AppColors.pathology;
      case 'ambulance':
        return AppColors.ambulance;
      case 'bloodbank':
        return AppColors.bloodbank;
      case 'pharmacist':
        return AppColors.pharmacist;
      default:
        return AppColors.primary;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'doctor':
        return Icons.local_hospital;
      case 'nurse':
        return Icons.healing;
      case 'pathology':
        return Icons.science;
      case 'ambulance':
        return Icons.local_shipping;
      case 'bloodbank':
        return Icons.bloodtype;
      case 'pharmacist':
        return Icons.local_pharmacy;
      default:
        return Icons.medical_services;
    }
  }
}

class _RateBookingDialog extends StatefulWidget {
  @override
  State<_RateBookingDialog> createState() => _RateBookingDialogState();
}

class _RateBookingDialogState extends State<_RateBookingDialog> {
  int _rating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Service'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How was your experience?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            decoration: const InputDecoration(
              labelText: 'Review (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'rating': _rating,
            'review': _reviewController.text.trim(),
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _BookingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingDetailsDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Booking Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Service', booking['serviceType'] ?? 'Unknown'),
            _buildDetailRow('Status', booking['status'] ?? 'Unknown'),
            _buildDetailRow('Provider', booking['provider']?['firstName'] ?? 'Unknown'),
            if (booking['scheduledTime'] != null)
              _buildDetailRow('Scheduled Time', DateFormatter.formatToHumanReadable(booking['scheduledTime'])),
            if (booking['notes'] != null)
              _buildDetailRow('Notes', booking['notes']),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}