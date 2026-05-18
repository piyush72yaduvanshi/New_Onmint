import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class BloodBanksScreen extends StatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  State<BloodBanksScreen> createState() => _BloodBanksScreenState();
}

class _BloodBanksScreenState extends State<BloodBanksScreen> {
  final _apiClient = OnMintApiClient();
  List<dynamic> _bloodBanks = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadBloodBanks();
  }

  Future<void> _loadBloodBanks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _apiClient.initialize();
      final response = await _apiClient.admin.getAllBloodBanks(
        page: 1,
        limit: 20,
      );

      setState(() {
        _bloodBanks = response['bloodBanks'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStock(String bloodBankId, List<Map<String, dynamic>> stockList) async {
    try {
      await _apiClient.admin.updateBloodStock(bloodBankId, stockList);
      ToastUtils.showSuccess('Blood stock updated successfully');
      _loadBloodBanks();
    } catch (e) {
      ToastUtils.showError('Failed to update stock: ${e.toString()}');
    }
  }

  void _showStockUpdateDialog(dynamic bloodBank) {
    final controllers = <String, TextEditingController>{};
    
    // Get existing blood stock
    final existingStock = bloodBank['bloodStock'] as List? ?? [];
    final stockMap = <String, int>{};
    for (var item in existingStock) {
      stockMap[item['bloodGroup']] = item['unitsAvailable'] ?? 0;
    }

    for (var group in _bloodGroups) {
      controllers[group] = TextEditingController(
        text: (stockMap[group] ?? 0).toString(),
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Blood Stock - ${bloodBank['firstName'] ?? 'Blood Bank'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _bloodGroups.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[group],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '$group (units)',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.water_drop,
                      color: _getStockColor(int.tryParse(controllers[group]!.text) ?? 0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final stockList = <Map<String, dynamic>>[];
              for (var entry in controllers.entries) {
                stockList.add({
                  'bloodGroup': entry.key,
                  'unitsAvailable': int.tryParse(entry.value.text) ?? 0,
                });
              }
              Navigator.pop(context);
              _updateStock(bloodBank['_id'], stockList);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodBank,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int units) {
    if (units == 0) return Colors.red;
    if (units < 5) return Colors.orange;
    if (units < 10) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getStockStatus(int units) {
    if (units == 0) return 'Out of Stock';
    if (units < 5) return 'Critical';
    if (units < 10) return 'Low';
    return 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadBloodBanks,
                )
              : _bloodBanks.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No Blood Banks',
                      message: 'No blood banks found',
                      icon: Icons.bloodtype,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBloodBanks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bloodBanks.length,
                        itemBuilder: (context, index) {
                          final bloodBank = _bloodBanks[index];
                          final stockList = bloodBank['bloodStock'] as List? ?? [];
                          
                          // Convert array to map for easier access
                          final stock = <String, int>{};
                          for (var item in stockList) {
                            stock[item['bloodGroup']] = item['unitsAvailable'] ?? 0;
                          }
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: const Icon(
                                  Icons.bloodtype,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                bloodBank['bankName'] ?? bloodBank['firstName'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    bloodBank['email'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    bloodBank['phone'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (bloodBank['city'] != null)
                                    Text(
                                      '${bloodBank['city']}, ${bloodBank['state'] ?? ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showStockUpdateDialog(bloodBank),
                                tooltip: 'Update Stock',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Blood Stock Levels',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          childAspectRatio: 1,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: _bloodGroups.length,
                                        itemBuilder: (context, idx) {
                                          final group = _bloodGroups[idx];
                                          final units = stock[group] ?? 0;
                                          final color = _getStockColor(units);
                                          
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              border: Border.all(color: color),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  group,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: color,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$units',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: color,
                                                  ),
                                                ),
                                                Text(
                                                  'units',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          _buildLegendItem('Available', Colors.green),
                                          const SizedBox(width: 12),
                                          _buildLegendItem('Low', Colors.yellow.shade700),
                                          const SizedBox(width: 12),
                                          _buildLegendItem('Critical', Colors.orange),
                                          const SizedBox(width: 12),
                                          _buildLegendItem('Out', Colors.red),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
