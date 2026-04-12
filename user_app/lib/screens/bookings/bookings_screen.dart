import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PatientService _patientService = PatientService();
  
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
    _loadAllBookings();
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
      final response = await _patientService.getActiveBookings();
      if (response.success && response.data != null) {
        setState(() {
          _activeBookings = List<Map<String, dynamic>>.from(
            response.data!['bookings'] ?? []
          );
        });
      } else {
        setState(() {
          _activeError = response.error?.message ?? 'Failed to load active bookings';
        });
      }
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
      _allBookings.clear();
    }

    setState(() {
      _isLoadingAll = true;
      _allError = null;
    });

    try {
      final response = await _patientService.getBookings(
        page: _currentPage,
        limit: 10,
      );

      if (response.success && response.data != null) {
        final newBookings = List<Map<String, dynamic>>.from(
          response.data!['bookings'] ?? []
        );
        
        final pagination = response.data!['pagination'] ?? {};
        
        setState(() {
          if (refresh) {
            _allBookings = newBookings;
          } else {
            _allBookings.addAll(newBookings);
          }
          
          _hasMoreBookings = pagination['hasNext'] ?? false;
          _currentPage = pagination['page'] ?? 1;
        });
      } else {
        setState(() {
          _allError = response.error?.message ?? 'Failed to load bookings';
        });
      }
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
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
          // Refresh both lists
          _loadActiveBookings();
          _loadAllBookings(refresh: true);
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

  Future<void> _rateBooking(String bookingId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RateBookingDialog(),
    );

    if (result != null) {
      try {
        final response = await _patientService.rateBooking(
          bookingId,
          rating: result['rating'],
          review: result['review'],
        );
        
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rating submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh both lists
          _loadActiveBookings();
          _loadAllBookings(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to submit rating'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      final response = await _patientService.getBookingDetails(bookingId);
      if (response.success && response.data != null) {
        showDialog(
          context: context,
          builder: (context) => _BookingDetailsDialog(booking: response.data!),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to load booking details'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            Icon(Icons.error, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_activeError!, style: TextStyle(color: AppColors.error)),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No active bookings'),
            const SizedBox(height: 8),
            const Text(
              'Your active bookings will appear here',
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
          return _buildBookingCard(booking, isActive: true);
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
            Icon(Icons.error, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(_allError!, style: TextStyle(color: AppColors.error)),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No bookings found'),
            const SizedBox(height: 8),
            const Text(
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
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _isLoadingAll
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _loadMoreBookings,
                        child: const Text('Load More'),
                      ),
              ),
            );
          }

          final booking = _allBookings[index];
          return _buildBookingCard(booking, isActive: false);
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, {required bool isActive}) {
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';
    final bookingId = booking['_id'] ?? booking['id'] ?? '';
    final serviceType = booking['serviceType'] ?? 'Service';
    final providerName = booking['providerName'] ?? booking['doctorName'] ?? 'Provider';
    final scheduledTime = booking['scheduledTime'] ?? 'Time TBD';
    
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
                  backgroundColor: _getServiceTypeColor(serviceType),
                  child: Icon(
                    _getServiceTypeIcon(serviceType),
                    color: Colors.white,
                    size: 20,
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
                        '$serviceType • ${DateFormatter.formatForCard(scheduledTime)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
            
            if (booking['symptoms'] != null || booking['testType'] != null) ...[
              const SizedBox(height: 12),
              Text(
                booking['symptoms'] != null 
                    ? 'Symptoms: ${booking['symptoms']}'
                    : 'Test: ${booking['testType']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            
            if (booking['notes'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${booking['notes']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            
            // Action buttons based on status
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewBookingDetails(bookingId),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'pending' || status == 'accepted' || status == 'confirmed') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(bookingId),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ] else if (status == 'completed' && booking['rating'] == null) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rateBooking(bookingId),
                      icon: const Icon(Icons.star_outline, size: 16),
                      label: const Text('Rate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'scheduled':
        return AppColors.warning;
      case 'accepted':
      case 'confirmed':
        return AppColors.info;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color _getServiceTypeColor(String serviceType) {
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

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'doctor':
        return Icons.local_hospital;
      case 'nurse':
        return Icons.healing;
      case 'pathology':
        return Icons.biotech;
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
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Experience'),
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
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write a review (optional)...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'rating': _rating,
              'review': _reviewController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
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
    final status = booking['status']?.toString() ?? 'Unknown';
    final serviceType = booking['serviceType'] ?? 'Service';
    final providerName = booking['providerName'] ?? booking['doctorName'] ?? 'Provider';
    final scheduledTime = booking['scheduledTime'] ?? 'Time TBD';
    final createdAt = booking['createdAt'] ?? '';
    
    return AlertDialog(
      title: const Text('Booking Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Provider', providerName),
            _buildDetailRow('Service', serviceType),
            _buildDetailRow('Status', status),
            _buildDetailRow('Scheduled Time', scheduledTime),
            if (booking['symptoms'] != null)
              _buildDetailRow('Symptoms', booking['symptoms']),
            if (booking['testType'] != null)
              _buildDetailRow('Test Type', booking['testType']),
            if (booking['notes'] != null)
              _buildDetailRow('Notes', booking['notes']),
            if (booking['address'] != null)
              _buildDetailRow('Address', booking['address']),
            if (booking['phone'] != null)
              _buildDetailRow('Phone', booking['phone']),
            if (createdAt.isNotEmpty)
              _buildDetailRow('Booked On', createdAt),
            if (booking['rating'] != null) ...[
              _buildDetailRow('Your Rating', '${booking['rating']} stars'),
              if (booking['review'] != null)
                _buildDetailRow('Your Review', booking['review']),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}