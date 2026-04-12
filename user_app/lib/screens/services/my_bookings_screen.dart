import 'package:flutter/material.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late final PatientService _patientService;
  
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _activeBookings = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = false;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _patientService = PatientService();
    _loadBookings();
  }

  Future<void> _loadBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _bookings.clear();
      _activeBookings.clear();
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all bookings
      final bookingsResponse = await _patientService.getBookings(
        page: _currentPage,
        limit: 10,
      );

      if (bookingsResponse.success && bookingsResponse.data != null) {
        final bookingsList = List<Map<String, dynamic>>.from(
          bookingsResponse.data!['bookings'] ?? []
        );
        
        setState(() {
          if (refresh) {
            _bookings = bookingsList;
          } else {
            _bookings.addAll(bookingsList);
          }
          _hasMore = bookingsList.length >= 10;
        });
      }

      // Load active bookings
      final activeResponse = await _patientService.getActiveBookings();
      if (activeResponse.success && activeResponse.data != null) {
        final activeList = List<Map<String, dynamic>>.from(
          activeResponse.data!['bookings'] ?? []
        );
        
        setState(() {
          _activeBookings = activeList;
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading bookings: $e';
        _isLoading = false;
      });
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await _patientService.cancelBooking(bookingId);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadBookings(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to cancel booking'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _loadBookings(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'All Bookings (${_bookings.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTabIndex == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        'Active (${_activeBookings.length})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 1
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading && _bookings.isEmpty && _activeBookings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _bookings.isEmpty && _activeBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(_error!, style: TextStyle(color: AppColors.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadBookings(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _selectedTabIndex == 0
                        ? _buildAllBookingsList()
                        : _buildActiveBookingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllBookingsList() {
    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No bookings yet'),
            const SizedBox(height: 8),
            Text(
              'Book a service to get started',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bookings.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _currentPage++;
                    _loadBookings();
                  },
                  child: const Text('Load More'),
                ),
              ),
            );
          }

          final booking = _bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildActiveBookingsList() {
    if (_activeBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No active bookings'),
            const SizedBox(height: 8),
            Text(
              'Your active bookings will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeBookings.length,
      itemBuilder: (context, index) {
        final booking = _activeBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final providerName = booking['provider'] != null
        ? '${booking['provider']['firstName'] ?? ''} ${booking['provider']['lastName'] ?? ''}'.trim()
        : 'Service Provider';
    final serviceType = booking['serviceType']?.toString() ?? 'Service';
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';
    final scheduledTime = booking['scheduledTime']?.toString() ?? '';
    final bookingId = booking['_id'] ?? booking['id'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    providerName.isNotEmpty
                        ? providerName.substring(0, 1).toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        serviceType,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  scheduledTime.isNotEmpty
                      ? DateTime.parse(scheduledTime).toString().split('.')[0]
                      : 'Time TBD',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsScreen(
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (status == 'requested' || status == 'pending')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(bookingId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancel'),
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
    switch (status) {
      case 'accepted':
      case 'confirmed':
        return AppColors.success;
      case 'requested':
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
