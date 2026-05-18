import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final _apiClient = OnMintApiClient();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'All';

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Confirmed',
    'On the Way',
    'In Progress',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Initialize API client
      await _apiClient.initialize();
      
      // Map frontend status to backend status
      String? backendStatus;
      switch (_selectedStatus) {
        case 'All':
          backendStatus = 'all';
          break;
        case 'Pending':
          backendStatus = 'pending';
          break;
        case 'Confirmed':
          backendStatus = 'accepted'; // Changed from 'confirmed' to 'accepted'
          break;
        case 'On the Way':
          backendStatus = 'on_the_way';
          break;
        case 'In Progress':
          backendStatus = 'in_progress';
          break;
        case 'Completed':
          backendStatus = 'completed';
          break;
        default:
          backendStatus = null;
      }

      final response = await _apiClient.pharmacist.getOrders(
        status: backendStatus,
      );

      setState(() {
        // The response is a map with 'data' and 'pagination' keys
        _orders = (response['data'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      await _apiClient.initialize();
      await _apiClient.pharmacist.acceptOrder(orderId);
      ToastUtils.showSuccess('Order accepted');
      _loadOrders();
    } catch (e) {
      ToastUtils.showError(e.toString());
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _apiClient.initialize();
      await _apiClient.pharmacist.updateOrderStatus(orderId, status);
      ToastUtils.showSuccess('Order status updated');
      _loadOrders();
    } catch (e) {
      ToastUtils.showError(e.toString());
    }
  }

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Order ID & Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order['_id'].substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          _buildStatusChip(order['status']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(DateTime.parse(order['createdAt'])),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Customer Info
              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person, 'Name', order['patientName'] ?? 'N/A'),
                      const Divider(),
                      _buildInfoRow(Icons.phone, 'Phone', order['patientPhone'] ?? 'N/A'),
                      const Divider(),
                      _buildInfoRow(
                        Icons.location_on, 
                        'Delivery Address', 
                        order['deliveryAddress'] ?? order['location']?['address'] ?? 'N/A'
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Medicines
              const Text(
                'Medicines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (order['medicines'] != null && (order['medicines'] as List).isNotEmpty)
                ...((order['medicines'] as List).map((medicine) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.medication, color: AppColors.primary),
                      title: Text(medicine['name'] ?? 'Unknown Medicine'),
                      subtitle: Text('Quantity: ${medicine['quantity'] ?? 0}'),
                      trailing: Text(
                        '₹${(medicine['price'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList())
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      order['requirements']?['description'] ?? 'No medicine details available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Total Amount
              Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order['medicines'] != null && (order['medicines'] as List).isNotEmpty
                            ? '₹${((order['medicines'] as List).fold<double>(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)))).toStringAsFixed(2)}'
                            : '₹${order['price'] ?? order['totalAmount'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              if (order['status'] == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _acceptOrder(order['_id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Accept Order'),
                      ),
                    ),
                  ],
                )
              else if (order['status'] == 'accepted')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order['_id'], 'on_the_way');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Start Delivery'),
                      ),
                    ),
                  ],
                )
              else if (order['status'] == 'on_the_way')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order['_id'], 'in_progress');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Mark In Progress'),
                      ),
                    ),
                  ],
                )
              else if (order['status'] == 'in_progress')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateOrderStatus(order['_id'], 'completed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Mark as Completed'),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = _selectedStatus == status;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                      _loadOrders();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Orders List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadOrders,
                      )
                    : _orders.isEmpty
                        ? const EmptyStateWidget(
                            title: 'No Orders',
                            message: 'No orders found',
                            icon: Icons.shopping_bag,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return _buildOrderCard(order);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    // Handle both old and new data structures
    final patient = order['patient'];
    final patientName = patient is Map 
        ? '${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}'.trim()
        : (order['patientName'] ?? 'Unknown Customer');
    
    final requirements = order['requirements'];
    final description = requirements is Map 
        ? (requirements['description'] ?? '')
        : (order['description'] ?? '');
    
    // Count items from description or items array
    int itemCount = 0;
    if (order['items'] != null && order['items'] is List) {
      itemCount = (order['items'] as List).length;
    } else if (order['medicines'] != null && order['medicines'] is List) {
      itemCount = (order['medicines'] as List).length;
    } else if (description.isNotEmpty) {
      // Try to extract item count from description
      final match = RegExp(r'Total items: (\d+)').firstMatch(description);
      if (match != null) {
        itemCount = int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['_id'].substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order['status']),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                patientName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                itemCount > 0 ? '$itemCount item(s)' : description.split('.').first,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(DateTime.parse(order['createdAt'])),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (order['price'] != null)
                    Text(
                      '₹${order['price']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  else if (order['totalAmount'] != null)
                    Text(
                      '₹${order['totalAmount']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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

  Widget _buildStatusChip(String? status) {
    Color color;
    String label;
    
    switch (status?.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'on_the_way':
      case 'on the way':
        color = Colors.purple;
        label = 'On the Way';
        break;
      case 'in_progress':
      case 'in progress':
        color = Colors.indigo;
        label = 'In Progress';
        break;
      case 'preparing':
        color = Colors.purple;
        label = 'Preparing';
        break;
      case 'ready':
        color = Colors.teal;
        label = 'Ready';
        break;
      case 'completed':
      case 'delivered':
        color = Colors.green;
        label = 'Completed';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status ?? 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
