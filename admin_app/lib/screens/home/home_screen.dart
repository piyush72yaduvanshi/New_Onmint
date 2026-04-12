import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const AllUsersTab(),
    const PendingApprovalsTab(),
    const ApprovedProvidersTab(),
    const RejectedProvidersTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.surface,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: const TextStyle(color: AppColors.primary),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
                label: Text('All Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pending_outlined),
                selectedIcon: Icon(Icons.pending),
                label: Text('Pending'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outlined),
                selectedIcon: Icon(Icons.check_circle),
                label: Text('Working'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cancel_outlined),
                selectedIcon: Icon(Icons.cancel),
                label: Text('Rejected'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          // Main Content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _adminService.getDashboardStats();
      if (response.success && response.data != null) {
        setState(() {
          _dashboardStats = response.data;
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load dashboard stats';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading dashboard stats: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadDashboardStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.admin,
                          child: Text(
                            (user?.firstName != null && user!.firstName.isNotEmpty) 
                                ? user.firstName.substring(0, 1).toUpperCase() 
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.fullName ?? 'Admin'}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'OnMint Platform Administrator',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Overview
                Text(
                  'Platform Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Card(
                    color: AppColors.error.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadDashboardStats,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Users',
                        '${_dashboardStats?['totalUsers'] ?? 0}',
                        Icons.people,
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        context,
                        'Active Bookings',
                        '${_dashboardStats?['activeBookings'] ?? 0}',
                        Icons.calendar_today,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        context,
                        'Emergency Count',
                        '${_dashboardStats?['emergencyCount'] ?? 0}',
                        Icons.emergency,
                        AppColors.error,
                      ),
                      _buildStatCard(
                        context,
                        'Pending Approvals',
                        '${_dashboardStats?['pendingApprovals'] ?? 0}',
                        Icons.pending,
                        AppColors.warning,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
class AllUsersTab extends StatefulWidget {
  const AllUsersTab({Key? key}) : super(key: key);

  @override
  State<AllUsersTab> createState() => _AllUsersTabState();
}

class _AllUsersTabState extends State<AllUsersTab> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedRole;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 DEBUG: Starting user load process');
      print('🔍 DEBUG: Current filters - Role: $_selectedRole, Status: $_selectedStatus');
      
      // First test API connection
      print('🧪 Testing API connection...');
      final testResponse = await _adminService.testApiConnection();
      print('🧪 Connection test result: ${testResponse.success}');
      
      // Then load users with filters
      print('🔍 Loading users with filters - Role: $_selectedRole, Status: $_selectedStatus');
      
      final response = await _adminService.getAllUsers(
        role: _selectedRole,
        status: _selectedStatus,
      );
      
      print('Load users response received: Success=${response.success}');
      
      if (response.success && response.data != null) {
        print('Setting ${response.data!.length} users in state');
        setState(() {
          _users = response.data!;
        });
        
        if (_users.isNotEmpty) {
          print('Sample user data: ${_users.first}');
        } else {
          print('No users returned from API');
        }
      } else {
        final errorMsg = response.error?.message ?? 'Failed to load users';
        print('Load users failed: $errorMsg');
        setState(() {
          _error = errorMsg;
        });
      }
    } catch (e) {
      final errorMsg = 'Error loading users: $e';
      print('Load users exception: $errorMsg');
      setState(() {
        _error = errorMsg;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveProvider(String userId) async {
    try {
      final response = await _adminService.approveProvider(userId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provider approved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to approve provider'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving provider: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectProvider(String userId, String reason) async {
    try {
      final response = await _adminService.rejectProvider(userId, reason);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provider rejected successfully'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to reject provider'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting provider: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _blockUser(String userId) async {
    try {
      final response = await _adminService.blockUser(userId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User blocked successfully'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to block user'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error blocking user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      final response = await _adminService.unblockUser(userId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to unblock user'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unblocking user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              // Test without any filters
              setState(() {
                _selectedRole = null;
                _selectedStatus = null;
              });
              _loadUsers();
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Filters',
          ),
          IconButton(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Roles')),
                      DropdownMenuItem(value: 'patient', child: Text('Patient')),
                      DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                      DropdownMenuItem(value: 'pharmacist', child: Text('Pharmacist')),
                      DropdownMenuItem(value: 'nurse', child: Text('Nurse')),
                      DropdownMenuItem(value: 'ambulance', child: Text('Ambulance')),
                      DropdownMenuItem(value: 'bloodbank', child: Text('Blood Bank')),
                      DropdownMenuItem(value: 'pathology', child: Text('Pathology')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                      _loadUsers();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'approved', child: Text('Approved (includes Active)')),
                      DropdownMenuItem(value: 'active', child: Text('Active Only')),
                      DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _loadUsers();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: AppColors.error),
                            const SizedBox(height: 16),
                            Text(_error!, style: TextStyle(color: AppColors.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                                const SizedBox(height: 16),
                                const Text('No users found'),
                                const SizedBox(height: 8),
                                Text(
                                  'Filters: Role=${_selectedRole ?? 'All'}, Status=${_selectedStatus ?? 'All'}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedRole = null;
                                      _selectedStatus = null;
                                    });
                                    _loadUsers();
                                  },
                                  child: const Text('Clear Filters'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Users count header
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Text(
                                      'Found ${_users.length} users',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_selectedRole != null || _selectedStatus != null)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedRole = null;
                                            _selectedStatus = null;
                                          });
                                          _loadUsers();
                                        },
                                        child: const Text('Clear Filters'),
                                      ),
                                  ],
                                ),
                              ),
                              // Users list
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _users.length,
                                  itemBuilder: (context, index) {
                                    final user = _users[index];
                                    return _buildUserCard(user);
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['_id'] ?? user['id'] ?? '';
    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? '';
    final role = user['role'] ?? '';
    final status = user['status'] ?? '';
    final city = user['city'] ?? '';
    final state = user['state'] ?? '';
    final specialization = user['specialization'] ?? '';
    final experience = user['experience'];
    final consultationFee = user['consultationFee'];
    final qualifications = user['qualifications'];
    final languages = user['languages'];
    final licenseNumber = user['licenseNumber'] ?? '';
    
    final isBlocked = status == 'blocked';
    final isPending = status == 'pending';
    final isApproved = status == 'approved' || status == 'active';
    final isVendor = ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role),
          child: Text(
            firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getRoleDisplayName(role),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Information
                Text(
                  'Contact Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (email.isNotEmpty) _buildDetailRow(Icons.email, 'Email', email),
                if (phone.isNotEmpty) _buildDetailRow(Icons.phone, 'Phone', phone),
                if (city.isNotEmpty || state.isNotEmpty) 
                  _buildDetailRow(Icons.location_on, 'Location', '$city, $state'.replaceAll(RegExp(r'^,\s*|,\s*$'), '')),
                
                if (isVendor) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Professional Information',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (specialization.isNotEmpty)
                    _buildDetailRow(Icons.medical_services, 'Specialization', specialization),
                  if (experience != null)
                    _buildDetailRow(Icons.work, 'Experience', '$experience years'),
                  if (consultationFee != null)
                    _buildDetailRow(Icons.currency_rupee, 'Consultation Fee', '₹$consultationFee'),
                  if (licenseNumber.isNotEmpty)
                    _buildDetailRow(Icons.badge, 'License Number', licenseNumber),
                  if (qualifications is List && qualifications.isNotEmpty)
                    _buildDetailRow(Icons.school, 'Qualifications', qualifications.join(', ')),
                  if (languages is List && languages.isNotEmpty)
                    _buildDetailRow(Icons.language, 'Languages', languages.join(', ')),
                ],
                
                const SizedBox(height: 16),
                
                // Action Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (isVendor && isPending) ...[
                        ElevatedButton.icon(
                          onPressed: () => _approveProvider(userId),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(userId),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ] else if (isVendor && !isApproved && !isPending) ...[
                        ElevatedButton.icon(
                          onPressed: () => _approveProvider(userId),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Re-approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      if (isBlocked) ...[
                        ElevatedButton.icon(
                          onPressed: () => _unblockUser(userId),
                          icon: const Icon(Icons.lock_open, size: 16),
                          label: const Text('Unblock'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (!isBlocked && role != 'admin') ...[
                        OutlinedButton.icon(
                          onPressed: () => _blockUser(userId),
                          icon: const Icon(Icons.block, size: 16),
                          label: const Text('Block'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      OutlinedButton.icon(
                        onPressed: () => _showUserDetailsDialog(user),
                        icon: const Icon(Icons.info, size: 16),
                        label: const Text('More Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if ((user['_id'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.person, 'User ID', user['_id'] ?? ''),
                if ((user['email'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.email, 'Email', user['email'] ?? ''),
                if ((user['phone'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.phone, 'Phone', user['phone'] ?? ''),
                if ((user['city'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.location_on, 'City', user['city'] ?? ''),
                if ((user['state'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.location_on, 'State', user['state'] ?? ''),
                if ((user['pincode'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.location_on, 'Pincode', user['pincode'] ?? ''),
                if ((user['role'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.work, 'Role', user['role'] ?? ''),
                if ((user['status'] ?? '').isNotEmpty)
                  _buildDetailRow(Icons.info, 'Status', user['status'] ?? ''),
                if (user['specialization'] != null && user['specialization'].toString().isNotEmpty)
                  _buildDetailRow(Icons.medical_services, 'Specialization', user['specialization'].toString()),
                if (user['experience'] != null)
                  _buildDetailRow(Icons.work, 'Experience', '${user['experience']} years'),
                if (user['consultationFee'] != null)
                  _buildDetailRow(Icons.currency_rupee, 'Fee', '₹${user['consultationFee']}'),
                if (user['licenseNumber'] != null && user['licenseNumber'].toString().isNotEmpty)
                  _buildDetailRow(Icons.badge, 'License', user['licenseNumber'].toString()),
                if (user['qualifications'] is List && (user['qualifications'] as List).isNotEmpty)
                  _buildDetailRow(Icons.school, 'Qualifications', (user['qualifications'] as List).join(', ')),
                if (user['languages'] is List && (user['languages'] as List).isNotEmpty)
                  _buildDetailRow(Icons.language, 'Languages', (user['languages'] as List).join(', ')),
                if (user['about'] != null && user['about'].toString().isNotEmpty)
                  _buildDetailRow(Icons.description, 'About', user['about'].toString()),
                if (user['createdAt'] != null)
                  _buildDetailRow(Icons.calendar_today, 'Joined', 
                    DateTime.parse(user['createdAt']).toString().split(' ')[0]),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.admin;
      case 'doctor':
        return AppColors.doctor;
      case 'patient':
        return AppColors.patient;
      case 'pharmacist':
        return AppColors.pharmacist;
      default:
        return AppColors.primary;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      case 'patient':
        return 'Patient';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
      case 'active':
        return AppColors.success;
      case 'rejected':
      case 'blocked':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showRejectDialog(String userId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Provider Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
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
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _rejectProvider(userId, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
class PendingApprovalsTab extends StatefulWidget {
  const PendingApprovalsTab({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsTab> createState() => _PendingApprovalsTabState();
}

class _PendingApprovalsTabState extends State<PendingApprovalsTab> {
  final AdminService _adminService = AdminService();
  List<PendingApproval> _pendingApprovals = [];
  bool _isLoading = false;
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
      final response = await _adminService.getPendingApprovals();
      if (response.success && response.data != null) {
        setState(() {
          _pendingApprovals = response.data!
              .map((json) => PendingApproval.fromJson(json))
              .toList();
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load pending approvals';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading pending approvals: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveProvider(String providerId) async {
    try {
      final response = await _adminService.approveProvider(providerId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provider approved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadPendingApprovals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to approve provider'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving provider: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectProvider(String providerId, String reason) async {
    try {
      final response = await _adminService.rejectProvider(providerId, reason);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provider rejected successfully'),
            backgroundColor: AppColors.warning,
          ),
        );
        _loadPendingApprovals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to reject provider'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting provider: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadPendingApprovals,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingApprovals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _pendingApprovals.isEmpty
                  ? const Center(
                      child: Text('No pending approvals'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingApprovals.length,
                      itemBuilder: (context, index) {
                        final approval = _pendingApprovals[index];
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
                                        approval.firstName.isNotEmpty 
                                            ? approval.firstName.substring(0, 1).toUpperCase()
                                            : 'V',
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
                                            approval.fullName,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            approval.roleDisplayName,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Chip(
                                      label: Text(approval.status.toUpperCase()),
                                      backgroundColor: AppColors.warning,
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 12),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow(Icons.email, approval.email),
                                          _buildInfoRow(Icons.phone, approval.phone),
                                          _buildInfoRow(Icons.location_on, '${approval.city}, ${approval.state}'),
                                          if (approval.specialization != null)
                                            _buildInfoRow(Icons.medical_services, approval.specialization!),
                                          if (approval.experience != null)
                                            _buildInfoRow(Icons.work, '${approval.experience} years experience'),
                                          if (approval.consultationFee != null)
                                            _buildInfoRow(Icons.currency_rupee, '₹${approval.consultationFee} consultation fee'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (approval.qualifications != null && approval.qualifications!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Qualifications: ${approval.qualificationsString}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                
                                if (approval.languages != null && approval.languages!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Languages: ${approval.languagesString}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 16),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showRejectDialog(approval.id),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _approveProvider(approval.id),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String providerId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Provider Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
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
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                _rejectProvider(providerId, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class ApprovedProvidersTab extends StatefulWidget {
  const ApprovedProvidersTab({Key? key}) : super(key: key);

  @override
  State<ApprovedProvidersTab> createState() => _ApprovedProvidersTabState();
}

class _ApprovedProvidersTabState extends State<ApprovedProvidersTab> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _approvedProviders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApprovedProviders();
  }

  Future<void> _loadApprovedProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _adminService.getAllUsers(
        status: 'approved',
      );
      if (response.success && response.data != null) {
        setState(() {
          _approvedProviders = response.data!.where((user) {
            final role = user['role']?.toString() ?? '';
            return ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);
          }).toList();
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load approved providers';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading approved providers: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approved Providers (Active & Approved)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadApprovedProviders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadApprovedProviders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _approvedProviders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                          SizedBox(height: 16),
                          Text('No approved providers yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _approvedProviders.length,
                      itemBuilder: (context, index) {
                        final provider = _approvedProviders[index];
                        return _buildProviderCard(provider);
                      },
                    ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final firstName = provider['firstName'] ?? '';
    final lastName = provider['lastName'] ?? '';
    final role = provider['role'] ?? '';
    final specialization = provider['specialization'] ?? '';
    final experience = provider['experience'];
    final consultationFee = provider['consultationFee'];
    final city = provider['city'] ?? '';
    final state = provider['state'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success,
          child: Text(
            firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'P',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Unknown Provider',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getRoleDisplayName(role)),
            if (specialization.isNotEmpty)
              Text('Specialization: $specialization', style: const TextStyle(fontSize: 12)),
            if (experience != null)
              Text('Experience: $experience years', style: const TextStyle(fontSize: 12)),
            if (consultationFee != null)
              Text('Fee: ₹$consultationFee', style: const TextStyle(fontSize: 12)),
            Text('Location: $city, $state', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success),
          ),
          child: const Text(
            'APPROVED',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      default:
        return role;
    }
  }
}

class RejectedProvidersTab extends StatefulWidget {
  const RejectedProvidersTab({Key? key}) : super(key: key);

  @override
  State<RejectedProvidersTab> createState() => _RejectedProvidersTabState();
}

class _RejectedProvidersTabState extends State<RejectedProvidersTab> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _rejectedProviders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRejectedProviders();
  }

  Future<void> _loadRejectedProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _adminService.getAllUsers(
        status: 'rejected',
      );
      if (response.success && response.data != null) {
        setState(() {
          _rejectedProviders = response.data!.where((user) {
            final role = user['role']?.toString() ?? '';
            return ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);
          }).toList();
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load rejected providers';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading rejected providers: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reApproveProvider(String userId) async {
    try {
      final response = await _adminService.approveProvider(userId);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Provider re-approved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadRejectedProviders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to re-approve provider'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error re-approving provider: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Providers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadRejectedProviders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRejectedProviders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _rejectedProviders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, size: 64, color: AppColors.error),
                          SizedBox(height: 16),
                          Text('No rejected providers'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rejectedProviders.length,
                      itemBuilder: (context, index) {
                        final provider = _rejectedProviders[index];
                        return _buildProviderCard(provider);
                      },
                    ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final userId = provider['_id'] ?? provider['id'] ?? '';
    final firstName = provider['firstName'] ?? '';
    final lastName = provider['lastName'] ?? '';
    final role = provider['role'] ?? '';
    final specialization = provider['specialization'] ?? '';
    final experience = provider['experience'];
    final consultationFee = provider['consultationFee'];
    final city = provider['city'] ?? '';
    final state = provider['state'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.error,
          child: Text(
            firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'P',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName'.trim() : 'Unknown Provider',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getRoleDisplayName(role)),
            if (specialization.isNotEmpty)
              Text('Specialization: $specialization', style: const TextStyle(fontSize: 12)),
            if (experience != null)
              Text('Experience: $experience years', style: const TextStyle(fontSize: 12)),
            if (consultationFee != null)
              Text('Fee: ₹$consultationFee', style: const TextStyle(fontSize: 12)),
            Text('Location: $city, $state', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error),
              ),
              child: const Text(
                'REJECTED',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _reApproveProvider(userId),
              icon: const Icon(Icons.refresh, color: AppColors.success),
              tooltip: 'Re-approve',
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      default:
        return role;
    }
  }
}
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.admin,
                          child: Text(
                            (user?.firstName != null && user!.firstName.isNotEmpty) 
                                ? user.firstName.substring(0, 1).toUpperCase() 
                                : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.fullName ?? 'Admin User',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.admin.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.admin),
                          ),
                          child: const Text(
                            'ADMINISTRATOR',
                            style: TextStyle(
                              color: AppColors.admin,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              user?.email ?? 'No email',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              user?.phone ?? 'No phone',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Profile Information
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('First Name', user?.firstName ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('Last Name', user?.lastName ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('Email', user?.email ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('Phone', user?.phone ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('City', user?.city ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('State', user?.state ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('Pincode', user?.pincode ?? 'Not provided'),
                        const Divider(),
                        _buildInfoRow('Role', user?.role ?? 'admin'),
                        const Divider(),
                        _buildInfoRow('Status', user?.status ?? 'active'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Account Actions
                Text(
                  'Account Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('Edit Profile'),
                        subtitle: const Text('Update your personal information'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to edit profile
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outlined),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your account password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to change password
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_outlined),
                        title: const Text('Security Settings'),
                        subtitle: const Text('Manage account security'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to security settings
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                        subtitle: const Text('Sign out of your account'),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
