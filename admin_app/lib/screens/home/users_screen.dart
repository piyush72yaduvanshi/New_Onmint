import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _apiClient = OnMintApiClient();
  final _searchController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = true;
  String _selectedRole = 'all';
  String _selectedStatus = 'all';
  int _currentPage = 1;
  int _totalPages = 1;

  final List<String> _roles = ['all', 'patient', 'doctor', 'nurse', 'pharmacist', 'ambulance', 'bloodbank', 'pathology'];
  final List<String> _statuses = ['all', 'pending', 'approved', 'rejected', 'blocked', 'active'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      await _apiClient.initialize();
      final result = await _apiClient.admin.getAllUsers(
        page: _currentPage,
        limit: 20,
        role: _selectedRole == 'all' ? null : _selectedRole,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      
      setState(() {
        _users = (result['users'] as List?)?.map((e) => User.fromJson(e)).toList() ?? [];
        _totalPages = result['totalPages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastUtils.showError('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Role Filter
                Row(
                  children: [
                    const Text('Role: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _roles.map((role) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: _selectedRole == role,
                                label: Text(role.toUpperCase()),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedRole = role;
                                    _currentPage = 1;
                                  });
                                  _loadUsers();
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Status Filter
                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _statuses.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: _selectedStatus == status,
                                label: Text(status.toUpperCase()),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedStatus = status;
                                    _currentPage = 1;
                                  });
                                  _loadUsers();
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadUsers,
              child: _isLoading
                  ? const LoadingWidget(message: 'Loading users...')
                  : _users.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.people,
                          title: 'No Users Found',
                          message: 'No users match the selected filters',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _users.length + 1, // +1 for pagination
                          itemBuilder: (context, index) {
                            if (index == _users.length) {
                              return _buildPagination();
                            }
                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
          child: Icon(_getRoleIcon(user.role), color: _getRoleColor(user.role)),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.role.toUpperCase()} • ${user.phone}'),
            if (user.email.isNotEmpty) Text(user.email, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(user.status),
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                if (user.status != 'blocked')
                  const PopupMenuItem(value: 'block', child: Text('Block User')),
                if (user.status == 'blocked')
                  const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'rejected':
      case 'blocked':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildPagination() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
              _loadUsers();
            } : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            onPressed: _currentPage < _totalPages ? () {
              setState(() => _currentPage++);
              _loadUsers();
            } : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor': return AppColors.doctor;
      case 'nurse': return AppColors.nurse;
      case 'pharmacist': return AppColors.pharmacy;
      case 'ambulance': return AppColors.ambulance;
      case 'bloodbank': return AppColors.bloodBank;
      case 'pathology': return AppColors.pathology;
      default: return AppColors.primary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'doctor': return Icons.medical_services;
      case 'nurse': return Icons.local_hospital;
      case 'pharmacist': return Icons.medication;
      case 'ambulance': return Icons.local_hospital;
      case 'bloodbank': return Icons.bloodtype;
      case 'pathology': return Icons.science;
      case 'patient': return Icons.person;
      default: return Icons.person;
    }
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'block':
        _blockUser(user);
        break;
      case 'unblock':
        _unblockUser(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Role', user.role.toUpperCase()),
              _buildDetailRow('Status', user.status.toUpperCase()),
              _buildDetailRow('Phone', user.phone),
              if (user.email.isNotEmpty) _buildDetailRow('Email', user.email),
              if (user.address != null) _buildDetailRow('Address', user.address!.fullAddress),
              _buildDetailRow('Joined', _formatDate(user.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _blockUser(User user) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to block ${user.fullName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
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
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ToastUtils.showError('Please provide a reason');
                return;
              }
              
              Navigator.pop(context);
              
              try {
                await _apiClient.admin.blockUser(user.id, reason: reasonController.text.trim());
                ToastUtils.showSuccess('User blocked successfully');
                _loadUsers();
              } catch (e) {
                ToastUtils.showError('Failed to block user');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _unblockUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _apiClient.admin.unblockUser(user.id);
                ToastUtils.showSuccess('User unblocked successfully');
                _loadUsers();
              } catch (e) {
                ToastUtils.showError('Failed to unblock user');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}
