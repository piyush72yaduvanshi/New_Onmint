import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final _apiClient = OnMintApiClient();
  List<User> _pendingApprovals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingApprovals();
  }

  Future<void> _loadPendingApprovals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _apiClient.initialize();
      final approvals = await _apiClient.admin.getPendingApprovals();
      setState(() {
        _pendingApprovals = approvals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _approveProvider(String providerId) async {
    try {
      await _apiClient.admin.approveProvider(providerId, notes: 'Approved by admin');
      ToastUtils.showSuccess('Provider approved successfully');
      _loadPendingApprovals();
    } catch (e) {
      ToastUtils.showError('Failed to approve provider');
    }
  }

  Future<void> _rejectProvider(String providerId) async {
    try {
      await _apiClient.admin.rejectProvider(providerId, reason: 'Invalid credentials');
      ToastUtils.showSuccess('Provider rejected');
      _loadPendingApprovals();
    } catch (e) {
      ToastUtils.showError('Failed to reject provider');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading pending approvals...');
    }

    if (_error != null) {
      return CustomErrorWidget(message: _error!, onRetry: _loadPendingApprovals);
    }

    if (_pendingApprovals.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'No Pending Approvals',
        message: 'All provider applications have been reviewed',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingApprovals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingApprovals.length,
        itemBuilder: (context, index) {
          final provider = _pendingApprovals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          _getRoleIcon(provider.role),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              provider.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, provider.email),
                  _buildInfoRow(Icons.phone, provider.phone),
                  if (provider.licenseNumber != null)
                    _buildInfoRow(Icons.badge, provider.licenseNumber!),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Approve',
                          onPressed: () => _approveProvider(provider.id),
                          color: AppColors.success,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Reject',
                          onPressed: () => _rejectProvider(provider.id),
                          color: AppColors.error,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return Icons.medical_services;
      case 'nurse':
        return Icons.local_hospital;
      case 'pharmacist':
        return Icons.medication;
      case 'ambulance':
        return Icons.local_hospital;
      case 'bloodbank':
        return Icons.bloodtype;
      case 'pathology':
        return Icons.science;
      default:
        return Icons.person;
    }
  }
}
