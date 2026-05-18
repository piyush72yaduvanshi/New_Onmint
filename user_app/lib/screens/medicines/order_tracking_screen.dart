import 'dart:async';
import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  
  const OrderTrackingScreen({super.key, required this.orderId});
  
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _apiClient = OnMintApiClient();
  Timer? _timer;
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadOrder();
    
    // Poll every 5 seconds for real-time updates
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadOrder();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadOrder() async {
    try {
      await _apiClient.initialize();
      final booking = await _apiClient.patient.getBookingDetails(widget.orderId);
      
      if (mounted) {
        setState(() {
          _order = booking.toJson();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrder,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Status Card
                        _buildStatusCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Status Timeline
                        _buildStatusTimeline(),
                        
                        const SizedBox(height: 24),
                        
                        // Pharmacist Info (if assigned)
                        if (_order!['provider'] != null)
                          _buildPharmacistCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Order Items
                        _buildOrderItems(),
                        
                        const SizedBox(height: 24),
                        
                        // Delivery Address
                        _buildDeliveryAddress(),
                        
                        const SizedBox(height: 24),
                        
                        // Order Details
                        _buildOrderDetails(),
                      ],
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildStatusCard() {
    final status = _order!['status'] ?? 'requested';
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: _getStatusColor(status),
            ),
            const SizedBox(height: 16),
            Text(
              _getStatusText(status),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(status),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (status == 'requested') ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Looking for nearby pharmacists...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusTimeline() {
    final status = _order!['status'] ?? 'requested';
    final statuses = ['requested', 'accepted', 'preparing', 'ready', 'on_the_way', 'completed'];
    final currentIndex = statuses.indexOf(status);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...statuses.asMap().entries.map((entry) {
              final index = entry.key;
              final statusName = entry.value;
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;
              
              return _buildTimelineItem(
                statusName,
                isCompleted,
                isCurrent,
                index < statuses.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem(String status, bool isCompleted, bool isCurrent, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(status),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
                if (isCurrent)
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPharmacistCard() {
    final provider = _order!['provider'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_pharmacy, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Pharmacist Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    provider['firstName']?[0]?.toUpperCase() ?? 'P',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider['pharmacyName'] ?? 
                        '${provider['firstName']} ${provider['lastName']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (provider['phone'] != null)
                        Text(
                          provider['phone'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    // Add call functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItems() {
    final items = _order!['items'] as List? ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      '${item['quantity']}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['medicine']?['name'] ?? 'Medicine',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      '₹${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${_order!['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeliveryAddress() {
    final location = _order!['location'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              location?['address'] ?? 'No address provided',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Order ID', _order!['_id']?.substring(0, 12) ?? 'N/A'),
            _buildDetailRow('Payment Method', _order!['paymentMethod'] ?? 'COD'),
            _buildDetailRow('Order Date', _formatDate(_order!['createdAt'])),
            if (_order!['notes'] != null && _order!['notes'].toString().isNotEmpty)
              _buildDetailRow('Notes', _order!['notes']),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'requested':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'preparing':
        return Icons.medication;
      case 'ready':
        return Icons.inventory;
      case 'on_the_way':
        return Icons.local_shipping;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
      case 'preparing':
      case 'ready':
        return Colors.blue;
      case 'on_the_way':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'Waiting for Pharmacist';
      case 'accepted':
        return 'Order Accepted';
      case 'preparing':
        return 'Preparing Your Order';
      case 'ready':
        return 'Ready for Delivery';
      case 'on_the_way':
        return 'Out for Delivery';
      case 'completed':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown Status';
    }
  }
  
  String _getStatusDescription(String status) {
    switch (status) {
      case 'requested':
        return 'Looking for nearby pharmacists to accept your order...';
      case 'accepted':
        return 'A pharmacist has accepted your order';
      case 'preparing':
        return 'Your medicines are being prepared';
      case 'ready':
        return 'Your order is ready for delivery';
      case 'on_the_way':
        return 'Your order is on the way';
      case 'completed':
        return 'Your order has been delivered successfully';
      case 'cancelled':
        return 'This order was cancelled';
      default:
        return '';
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
