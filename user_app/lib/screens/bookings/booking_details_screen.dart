import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';

/// Booking details screen for patients
class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _apiClient = OnMintApiClient();
  Booking? _booking;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() => _isLoading = true);
    try {
      await _apiClient.initialize();
      final booking = await _apiClient.patient.getBookingDetails(widget.bookingId);
      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading booking: $e')),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    final reason = await _showCancelDialog();
    if (reason == null) return;

    setState(() => _isProcessing = true);
    try {
      await _apiClient.patient.cancelBooking(widget.bookingId, reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled')),
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

  Future<String?> _showCancelDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for cancellation',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
              ? const Center(child: Text('Booking not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 20),
                      _buildSection('Provider Information', [
                        _buildInfoRow('Name', _booking!.providerDetails?.fullName ?? 'N/A'),
                        _buildInfoRow('Phone', _booking!.providerDetails?.phone ?? 'N/A'),
                        _buildInfoRow('Service', _formatServiceType(_booking!.serviceType)),
                      ]),
                      const SizedBox(height: 20),
                      _buildSection('Booking Details', [
                        _buildInfoRow('Date', _formatDate(_booking!.scheduledTime)),
                        _buildInfoRow('Time', _formatTime(_booking!.scheduledTime)),
                        _buildInfoRow('Status', _formatStatus(_booking!.status)),
                        if (_booking!.price > 0)
                          _buildInfoRow('Amount', '₹${_booking!.price.toStringAsFixed(2)}'),
                      ]),
                      if (_booking!.location.address != null) ...[
                        const SizedBox(height: 20),
                        _buildSection('Location', [
                          Text(_booking!.location.address!),
                        ]),
                      ],
                      if (_booking!.notes != null && _booking!.notes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSection('Notes', [
                          Text(_booking!.notes!),
                        ]),
                      ],
                      const SizedBox(height: 24),
                      if (_booking!.canBeCancelled) ...[
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _cancelBooking,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (_booking!.status.toLowerCase()) {
      case 'requested':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Waiting for confirmation';
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        statusText = 'Booking confirmed';
        break;
      case 'on_the_way':
        statusColor = Colors.purple;
        statusIcon = Icons.directions_car;
        statusText = 'Provider is on the way';
        break;
      case 'in_progress':
        statusColor = Colors.indigo;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Service in progress';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Service completed';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Booking cancelled';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = _booking!.status;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStatus(_booking!.status),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatServiceType(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'doctor':
        return 'Doctor Consultation';
      case 'nurse':
        return 'Nurse Service';
      case 'ambulance':
        return 'Ambulance Service';
      case 'pharmacist':
      case 'pharmacy':
        return 'Medicine Order';
      case 'pathology':
        return 'Lab Test';
      case 'bloodbank':
        return 'Blood Request';
      default:
        return serviceType;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
