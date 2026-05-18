import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'upload_report_screen.dart';

/// Pathology booking details screen
class PathologyBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const PathologyBookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<PathologyBookingDetailsScreen> createState() => _PathologyBookingDetailsScreenState();
}

class _PathologyBookingDetailsScreenState extends State<PathologyBookingDetailsScreen> {
  final _apiClient = OnMintApiClient();
  Map<String, dynamic>? _booking;
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
      final data = await _apiClient.admin.getPathologyBookingDetails(widget.bookingId);
      setState(() {
        _booking = data;
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

  Future<void> _acceptBooking() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.admin.acceptPathologyBooking(widget.bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking accepted')),
        );
        _loadBooking();
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

  Future<void> _markSampleCollected() async {
    setState(() => _isProcessing = true);
    try {
      await _apiClient.admin.updatePathologyStatus(
        widget.bookingId,
        'sample_collected',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample marked as collected')),
        );
        _loadBooking();
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

  void _uploadReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadReportScreen(
          bookingId: widget.bookingId,
        ),
      ),
    );
    if (result == true) {
      _loadBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                      _buildSection('Patient Information', [
                        _buildInfoRow('Name', _booking!['patient']?['fullName'] ?? 'N/A'),
                        _buildInfoRow('Phone', _booking!['patient']?['phone'] ?? 'N/A'),
                        _buildInfoRow('Age', '${_booking!['patient']?['age'] ?? 'N/A'} years'),
                        _buildInfoRow('Gender', _booking!['patient']?['gender'] ?? 'N/A'),
                        if (_booking!['patient']?['address'] != null)
                          _buildInfoRow('Address', _booking!['patient']['address']),
                      ]),
                      
                      const SizedBox(height: 20),
                      
                      _buildSection('Booking Details', [
                        _buildInfoRow('Date', _formatDate(_booking!['scheduledTime'])),
                        _buildInfoRow('Time', _formatTime(_booking!['scheduledTime'])),
                        _buildInfoRow('Status', _booking!['status'] ?? 'N/A'),
                        if (_booking!['totalFees'] != null)
                          _buildInfoRow('Total Fees', '₹${_booking!['totalFees']}'),
                      ]),
                      
                      const SizedBox(height: 20),
                      
                      _buildSection('Tests', [
                        if (_booking!['tests'] != null)
                          ...(_booking!['tests'] as List).map((test) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.science, color: Colors.teal),
                                  title: Text(test['name'] ?? 'Unknown Test'),
                                  trailing: Text(
                                    '₹${test['price'] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              )),
                      ]),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      if (_booking!['status'] == 'requested') ...[
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _acceptBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
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
                              : const Text('Accept Booking'),
                        ),
                      ],
                      
                      if (_booking!['status'] == 'accepted') ...[
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _markSampleCollected,
                          icon: const Icon(Icons.check),
                          label: const Text('Mark Sample Collected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      
                      if (_booking!['status'] == 'sample_collected') ...[
                        ElevatedButton.icon(
                          onPressed: _uploadReport,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'N/A';
    final date = DateTime.parse(dateStr);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
