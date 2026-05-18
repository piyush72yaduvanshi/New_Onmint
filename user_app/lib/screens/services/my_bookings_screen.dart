import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import '../../utils/app_colors.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

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
  bool _showRealtimeBookings = true; // Toggle between regular and realtime bookings

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

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Map<String, dynamic>> bookingsList = [];
      
      if (_showRealtimeBookings) {
        // Load realtime bookings
        final realtimeResponse = await _patientService.getMyRealtimeBookings(
          page: _currentPage,
          limit: 10,
        );
        final data = realtimeResponse['data'];
        if (data is List) {
          bookingsList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['bookings'] != null) {
          bookingsList = List<Map<String, dynamic>>.from(data['bookings']);
        }
      } else {
        // Load regular bookings
        bookingsList = await _patientService.getBookings(
          page: _currentPage,
          limit: 10,
        );
      }
        
      if (mounted) {
        setState(() {
          if (refresh) {
            _bookings = bookingsList;
          } else {
            _bookings.addAll(bookingsList);
          }
          _hasMore = bookingsList.length >= 10;
        });
      }

      // Load active bookings (filter from all bookings)
      final activeList = bookingsList.where((booking) {
        final status = booking['status']?.toString().toLowerCase() ?? '';
        return status == 'requested' || status == 'pending' || status == 'accepted' || 
               status == 'confirmed' || status == 'on_the_way' || status == 'in_progress';
      }).toList();
        
      if (mounted) {
        setState(() {
          _activeBookings = activeList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading bookings: $e';
          _isLoading = false;
        });
      }
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

    if (confirmed == true && mounted) {
      // Ask for cancellation reason
      final reasonController = TextEditingController();
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancellation Reason'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Please provide a reason...',
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
              onPressed: () => Navigator.pop(context, reasonController.text.trim()),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (reason != null && reason.isNotEmpty && mounted) {
        try {
          if (_showRealtimeBookings) {
            await _patientService.cancelRealtimeBooking(bookingId, reason: reason);
          } else {
            await _patientService.cancelBooking(bookingId, reason: reason);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
            _loadBookings(refresh: true);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error cancelling booking: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showRealtimeBookings ? 'Instant Bookings' : 'Regular Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showRealtimeBookings = !_showRealtimeBookings;
              });
              _loadBookings(refresh: true);
            },
            icon: Icon(_showRealtimeBookings ? Icons.flash_on : Icons.calendar_today),
            tooltip: _showRealtimeBookings ? 'Switch to Regular' : 'Switch to Instant',
          ),
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
                            const Icon(Icons.error, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: AppColors.error)),
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
    // Handle both regular and realtime bookings
    final providerData = booking['provider'] ?? booking['acceptedProvider'];
    final providerName = providerData != null
        ? '${providerData['firstName'] ?? ''} ${providerData['lastName'] ?? ''}'.trim()
        : (_showRealtimeBookings ? 'Waiting for doctor...' : 'Service Provider');
    final serviceType = booking['serviceType']?.toString() ?? 'Service';
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';
    final scheduledTime = booking['scheduledTime']?.toString() ?? booking['preferredTime']?.toString() ?? '';
    final bookingId = booking['_id'] ?? booking['id'] ?? '';
    final urgency = booking['urgency']?.toString();
    final isEmergency = booking['isEmergency'] == true;
    final notifiedCount = booking['notifiedProviders']?.length ?? 0;

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
                  backgroundColor: isEmergency ? Colors.red : AppColors.primary,
                  child: Icon(
                    isEmergency ? Icons.emergency : Icons.local_hospital,
                    color: Colors.white,
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
                      Row(
                        children: [
                          Text(
                            serviceType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_showRealtimeBookings && urgency != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getUrgencyColor(urgency).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                urgency.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getUrgencyColor(urgency),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
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
            
            // Show notified providers count for realtime bookings
            if (_showRealtimeBookings && status == 'pending' && notifiedCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '$notifiedCount doctors notified - waiting for acceptance',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  scheduledTime.isNotEmpty
                      ? DateTime.parse(scheduledTime).toString().split('.')[0]
                      : 'Time TBD',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            
            // Show description for realtime bookings
            if (_showRealtimeBookings && booking['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                booking['description'].toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
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
                        side: const BorderSide(color: AppColors.error),
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
      case 'on_the_way':
        return AppColors.success;
      case 'requested':
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'rejected':
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
  
  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
