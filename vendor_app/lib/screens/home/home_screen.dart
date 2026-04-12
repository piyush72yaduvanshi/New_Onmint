import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'package:api_client/api_client.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/availability_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const AppointmentsTab(),
    const ServicesTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
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
  late final HealthcareProviderService _providerService;
  
  Map<String, dynamic>? _dashboardData;
  List<Map<String, dynamic>> _todayAppointments = [];
  List<Map<String, dynamic>> _todayBookings = [];
  List<Map<String, dynamic>> _testsOffered = [];
  bool _isLoading = false;
  String? _error;
  String _providerType = 'doctor';

  @override
  void initState() {
    super.initState();
    // Initialize service based on user role
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _providerType = authProvider.currentUser?.role ?? 'doctor';
    _providerService = HealthcareProviderService(_providerType);
    
    // Refresh profile data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfileData();
      _loadDashboardData();
    });
  }

  Future<void> _refreshProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshProfile();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load dashboard data
      final dashboardResponse = await _providerService.getDashboard();
      if (dashboardResponse.success && dashboardResponse.data != null) {
        setState(() {
          _dashboardData = dashboardResponse.data;
          _todayAppointments = List<Map<String, dynamic>>.from(
            dashboardResponse.data!['upcomingAppointments'] ?? []
          );
        });
      }

      // Load bookings for pathology and other service providers
      if (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank') {
        final bookingsResponse = await _providerService.getBookings(limit: 5);
        if (bookingsResponse.success && bookingsResponse.data != null) {
          setState(() {
            _todayBookings = List<Map<String, dynamic>>.from(
              bookingsResponse.data!['bookings'] ?? []
            );
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _error = 'Failed to load dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          final userStatus = user?.status?.toLowerCase() ?? 'pending';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.getRoleColor(user?.role ?? ''),
                          child: Text(
                            (user?.firstName?.isNotEmpty == true) 
                                ? user!.firstName.substring(0, 1).toUpperCase() 
                                : 'V',
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
                                'Welcome, ${user?.fullName ?? 'Vendor'}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                RoleUtils.getRoleDisplayName(user?.role ?? ''),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(userStatus).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _getStatusColor(userStatus)),
                          ),
                          child: Text(
                            _getStatusDisplayName(userStatus),
                            style: TextStyle(
                              color: _getStatusColor(userStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Status-based content
                if (userStatus == 'pending') ...[
                  _buildPendingStatusContent(context),
                ] else if (userStatus == 'approved' || userStatus == 'active') ...[
                  _buildApprovedStatusContent(context, user),
                ] else if (userStatus == 'rejected') ...[
                  _buildRejectedStatusContent(context),
                ] else if (userStatus == 'blocked') ...[
                  _buildBlockedStatusContent(context),
                ] else ...[
                  _buildDefaultStatusContent(context, user),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingStatusContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppColors.warning.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 48,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                Text(
                  'Application Under Review',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your vendor application is currently being reviewed by our admin team. You will be notified once the review is complete.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'What happens next?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepItem('1. Admin reviews your documents and qualifications'),
                    _buildStepItem('2. Verification of licenses and certifications'),
                    _buildStepItem('3. Approval notification via email and app'),
                    _buildStepItem('4. Access to full vendor dashboard and features'),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact Support'),
                  subtitle: const Text('support@onmint.com'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Call Us'),
                  subtitle: const Text('+91 1800-123-4567'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedStatusContent(BuildContext context, User? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Message
        Card(
          color: AppColors.success.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Approved!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'You can now access all vendor features and start serving patients.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
        
        // Stats Cards
        Text(
          'Today\'s Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Today\'s Appointments',
                '${_dashboardData?['todayAppointments'] ?? 0}',
                Icons.calendar_today,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Consultations',
                '${_dashboardData?['totalConsultations'] ?? 0}',
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Average Rating',
                '${_dashboardData?['rating']?['average']?.toStringAsFixed(1) ?? '0.0'}',
                Icons.star,
                AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Rating Count',
                '${_dashboardData?['rating']?['count'] ?? 0}',
                Icons.reviews,
                AppColors.info,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Recent Appointments/Bookings
        Text(
          _providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' 
              ? 'Recent Bookings' 
              : 'Today\'s Appointments',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    onPressed: _loadDashboardData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank')
          _buildBookingsList()
        else
          _buildAppointmentsList(),
      ],
    );
  }

  Widget _buildBlockedStatusContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppColors.error.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.block,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Account Blocked',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your account has been temporarily blocked by the administrator. Please contact support for assistance.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to contact support
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@onmint.com'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone Support'),
                  subtitle: const Text('+91 1800-123-4567'),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Support Hours'),
                  subtitle: const Text('Mon-Fri: 9:00 AM - 6:00 PM'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedStatusContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppColors.error.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.cancel,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Application Rejected',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unfortunately, your vendor application has been rejected. Please review the feedback and reapply with the necessary corrections.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to reapplication or contact support
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultStatusContent(BuildContext context, User? user) {
    return _buildApprovedStatusContent(context, user);
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAppointmentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'scheduled':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
      case 'active':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'blocked':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'approved':
        return 'APPROVED';
      case 'active':
        return 'ACTIVE';
      case 'rejected':
        return 'REJECTED';
      case 'blocked':
        return 'BLOCKED';
      default:
        return status.toUpperCase();
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_todayAppointments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No appointments today',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your schedule is clear for today',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: _todayAppointments.map((appointment) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.patient,
                  child: Text(
                    appointment['patientName']?.substring(0, 1)?.toUpperCase() ?? 'P',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(appointment['patientName'] ?? 'Patient'),
                subtitle: Text('${appointment['serviceType'] ?? 'Consultation'} • ${appointment['scheduledTime'] ?? 'Time TBD'}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAppointmentStatusColor(appointment['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status']?.toString().toUpperCase() ?? 'SCHEDULED',
                    style: TextStyle(
                      color: _getAppointmentStatusColor(appointment['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (appointment != _todayAppointments.last)
                const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_todayBookings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.book_online_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No recent bookings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New bookings will appear here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: _todayBookings.map((booking) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.patient,
                  child: Text(
                    booking['patientName']?.substring(0, 1)?.toUpperCase() ?? 'P',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(booking['patientName'] ?? 'Patient'),
                subtitle: Text('${booking['serviceType'] ?? 'Service'} • ${booking['scheduledTime'] ?? 'Time TBD'}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAppointmentStatusColor(booking['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status']?.toString().toUpperCase() ?? 'PENDING',
                    style: TextStyle(
                      color: _getAppointmentStatusColor(booking['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (booking != _todayBookings.last)
                const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({Key? key}) : super(key: key);

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  late final HealthcareProviderService _providerService;
  
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;
  String _providerType = 'doctor';

  @override
  void initState() {
    super.initState();
    // Initialize service based on user role
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _providerType = authProvider.currentUser?.role ?? 'doctor';
    _providerService = HealthcareProviderService(_providerType);
    
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank') {
      await _loadBookings(refresh: refresh);
    } else {
      await _loadAppointments(refresh: refresh);
    }
  }

  Future<void> _loadAppointments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _appointments.clear();
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _providerService.getAppointments(
        page: _currentPage,
        limit: 10,
      );

      if (response.success && response.data != null) {
        final newAppointments = List<Map<String, dynamic>>.from(
          response.data!['appointments'] ?? []
        );
        
        final pagination = response.data!['pagination'] ?? {};
        
        setState(() {
          if (refresh) {
            _appointments = newAppointments;
          } else {
            _appointments.addAll(newAppointments);
          }
          
          _totalPages = pagination['totalPages'] ?? 1;
          _hasMore = pagination['hasNext'] ?? false;
          _currentPage = pagination['page'] ?? 1;
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load appointments';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading appointments: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookings({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _bookings.clear();
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _providerService.getBookings(
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
            _bookings = newBookings;
          } else {
            _bookings.addAll(newBookings);
          }
          
          _totalPages = pagination['totalPages'] ?? 1;
          _hasMore = pagination['hasNext'] ?? false;
          _currentPage = pagination['page'] ?? 1;
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load bookings';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading bookings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAppointments() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await _loadData();
    }
  }

  Future<void> _viewAppointmentDetails(Map<String, dynamic> appointment) async {
    showDialog(
      context: context,
      builder: (context) => _AppointmentDetailsDialog(appointment: appointment),
    );
  }

  Future<void> _scheduleCollection(String bookingId) async {
    // Show dialog to get scheduled time
    final scheduledTime = await showDialog<String>(
      context: context,
      builder: (context) => _ScheduleCollectionDialog(),
    );

    if (scheduledTime != null && scheduledTime.isNotEmpty) {
      try {
        final response = await _providerService.scheduleCollection(bookingId, scheduledTime);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Collection scheduled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to schedule collection'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling collection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadReport(String bookingId) async {
    // Show dialog to get report data
    final reportData = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UploadReportDialog(),
    );

    if (reportData != null) {
      try {
        final response = await _providerService.uploadReport(bookingId, reportData);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to upload report'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _acceptAppointment(String appointmentId) async {
    try {
      ApiResponse<Map<String, dynamic>> response;
      
      if (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank') {
        response = await _providerService.acceptBooking(appointmentId);
      } else {
        response = await _providerService.acceptAppointment(appointmentId);
      }
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                ? 'Booking accepted successfully'
                : 'Appointment accepted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error?.message ?? 'Failed to accept ${_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' ? 'booking' : 'appointment'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accepting ${_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' ? 'booking' : 'appointment'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectAppointment(String appointmentId) async {
    // Show dialog to get rejection reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectAppointmentDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        ApiResponse<Map<String, dynamic>> response;
        
        if (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank') {
          response = await _providerService.rejectBooking(appointmentId, reason: reason);
        } else {
          response = await _providerService.rejectAppointment(appointmentId, reason: reason);
        }
        
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                  ? 'Booking rejected'
                  : 'Appointment rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadData(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to reject ${_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' ? 'booking' : 'appointment'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting ${_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' ? 'booking' : 'appointment'}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeAppointment(String appointmentId) async {
    // Show dialog to get completion notes
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => _CompleteAppointmentDialog(),
    );

    if (notes != null) {
      try {
        final response = await _providerService.completeAppointment(appointmentId, notes: notes);
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData(refresh: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to complete appointment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' 
            ? 'Bookings' 
            : 'Appointments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _loadData(refresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _appointments.isEmpty && _bookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _appointments.isEmpty && _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadData(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _appointments.isEmpty && _bookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                                ? Icons.book_online_outlined 
                                : Icons.calendar_today_outlined, 
                            size: 64, 
                            color: Colors.grey
                          ),
                          const SizedBox(height: 16),
                          Text(_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                              ? 'No bookings found' 
                              : 'No appointments found'),
                          const SizedBox(height: 8),
                          Text(
                            _providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                                ? 'Your bookings will appear here'
                                : 'Your appointments will appear here',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadData(refresh: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: (_providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' 
                            ? _bookings.length 
                            : _appointments.length) + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          final items = _providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank' 
                              ? _bookings 
                              : _appointments;
                              
                          if (index == items.length) {
                            // Load more indicator
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                        onPressed: _loadMoreAppointments,
                                        child: const Text('Load More'),
                                      ),
                              ),
                            );
                          }

                          final item = items[index];
                          return _providerType == 'pathology' || _providerType == 'ambulance' || _providerType == 'bloodbank'
                              ? _buildBookingCard(item)
                              : _buildAppointmentCard(item);
                        },
                      ),
                    ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status']?.toString().toLowerCase() ?? 'pending';
    final appointmentId = appointment['_id'] ?? appointment['id'] ?? '';
    final patientName = appointment['patient']?['firstName'] != null && appointment['patient']?['lastName'] != null
        ? '${appointment['patient']['firstName']} ${appointment['patient']['lastName']}'
        : appointment['patientName'] ?? 'Patient';
    final scheduledTime = DateFormatter.formatToHumanReadable(appointment['scheduledTime']);
    final serviceType = appointment['serviceType'] ?? 'Consultation';
    
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
                  backgroundColor: AppColors.patient,
                  child: Text(
                    patientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$serviceType • $scheduledTime',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (appointment['consultationType'] != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            appointment['consultationType'].toString().replaceAll('_', ' '),
                            style: TextStyle(
                              color: AppColors.info,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAppointmentStatusColor(appointment['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status']?.toString().toUpperCase() ?? 'SCHEDULED',
                    style: TextStyle(
                      color: _getAppointmentStatusColor(appointment['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (appointment['notes'] != null && appointment['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Notes: ${appointment['notes']}',
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (appointment['price'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                  Text(
                    '${appointment['price']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (appointment['isEmergency'] == true) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EMERGENCY',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            
            // Action buttons based on status
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewAppointmentDetails(appointment),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'requested' || status == 'pending') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectAppointment(appointmentId),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptAppointment(appointmentId),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else if (status == 'accepted' || status == 'confirmed') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeAppointment(appointmentId),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
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

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status']?.toString().toLowerCase() ?? 'pending';
    final bookingId = booking['_id'] ?? booking['id'] ?? '';
    final patientName = booking['patient']?['firstName'] != null && booking['patient']?['lastName'] != null
        ? '${booking['patient']['firstName']} ${booking['patient']['lastName']}'
        : booking['patientName'] ?? 'Patient';
    final scheduledTime = DateFormatter.formatToHumanReadable(booking['scheduledTime']);
    final serviceType = booking['serviceType'] ?? 'Service';
    
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
                  backgroundColor: AppColors.patient,
                  child: Text(
                    patientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$serviceType • $scheduledTime',
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
                    color: _getAppointmentStatusColor(booking['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status']?.toString().toUpperCase() ?? 'PENDING',
                    style: TextStyle(
                      color: _getAppointmentStatusColor(booking['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (booking['testType'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Test: ${booking['testType']}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (booking['notes'] != null && booking['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${booking['notes']}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (booking['price'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 16, color: Colors.grey[600]),
                  Text(
                    '${booking['price']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            
            // Action buttons based on status and provider type
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewAppointmentDetails(booking),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'pending' || status == 'requested') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectAppointment(bookingId),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptAppointment(bookingId),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else if (status == 'accepted' && _providerType == 'pathology') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleCollection(bookingId),
                      icon: const Icon(Icons.schedule, size: 16),
                      label: const Text('Schedule Collection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ] else if (status == 'sample_collected' && _providerType == 'pathology') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _uploadReport(bookingId),
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Upload Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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

  Color _getAppointmentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
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
}

class ServicesTab extends StatelessWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Services Management - Coming Soon'),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.getRoleColor(user?.role ?? ''),
                        child: Text(
                          (user?.firstName?.isNotEmpty == true) 
                              ? user!.firstName.substring(0, 1).toUpperCase() 
                              : 'V',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'Vendor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        RoleUtils.getRoleDisplayName(user?.role ?? ''),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outlined),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: const Text('Availability'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AvailabilityScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.analytics_outlined),
                      title: const Text('Analytics'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      onTap: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RejectAppointmentDialog extends StatefulWidget {
  @override
  State<_RejectAppointmentDialog> createState() => _RejectAppointmentDialogState();
}

class _RejectAppointmentDialogState extends State<_RejectAppointmentDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please provide a reason for rejecting this appointment:'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
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
            if (_reasonController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_reasonController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _CompleteAppointmentDialog extends StatefulWidget {
  @override
  State<_CompleteAppointmentDialog> createState() => _CompleteAppointmentDialogState();
}

class _CompleteAppointmentDialogState extends State<_CompleteAppointmentDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add any notes about the consultation (optional):'),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Consultation notes...',
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
            Navigator.of(context).pop(_notesController.text.trim());
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('Complete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _ScheduleCollectionDialog extends StatefulWidget {
  @override
  State<_ScheduleCollectionDialog> createState() => _ScheduleCollectionDialogState();
}

class _ScheduleCollectionDialogState extends State<_ScheduleCollectionDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Sample Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select date and time for sample collection:'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Text(_selectedDate != null 
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  child: Text(_selectedTime != null 
                      ? _selectedTime!.format(context)
                      : 'Select Time'),
                ),
              ),
            ],
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
            if (_selectedDate != null && _selectedTime != null) {
              final scheduledDateTime = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );
              Navigator.of(context).pop(scheduledDateTime.toIso8601String());
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Schedule', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _UploadReportDialog extends StatefulWidget {
  @override
  State<_UploadReportDialog> createState() => _UploadReportDialogState();
}

class _UploadReportDialogState extends State<_UploadReportDialog> {
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _reportController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter report details:'),
          const SizedBox(height: 16),
          TextField(
            controller: _reportController,
            decoration: const InputDecoration(
              labelText: 'Report Summary',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Additional Notes (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
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
            if (_reportController.text.trim().isNotEmpty) {
              Navigator.of(context).pop({
                'reportSummary': _reportController.text.trim(),
                'notes': _notesController.text.trim(),
                'uploadedAt': DateTime.now().toIso8601String(),
              });
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Upload', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _AppointmentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const _AppointmentDetailsDialog({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final patient = appointment['patient'] ?? {};
    final provider = appointment['provider'] ?? {};
    final location = appointment['location'] ?? {};
    
    final patientName = patient['firstName'] != null && patient['lastName'] != null
        ? '${patient['firstName']} ${patient['lastName']}'
        : 'Patient';
    
    final providerName = provider['firstName'] != null && provider['lastName'] != null
        ? 'Dr. ${provider['firstName']} ${provider['lastName']}'
        : 'Provider';

    return AlertDialog(
      title: const Text('Appointment Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSectionTitle('Patient Information'),
            _buildDetailRow('Name', patientName),
            if (patient['email'] != null)
              _buildDetailRow('Email', patient['email']),
            if (patient['phone'] != null)
              _buildDetailRow('Phone', patient['phone']),
            if (patient['city'] != null && patient['state'] != null)
              _buildDetailRow('Location', '${patient['city']}, ${patient['state']}'),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Provider Information'),
            _buildDetailRow('Doctor', providerName),
            if (provider['specialization'] != null)
              _buildDetailRow('Specialization', provider['specialization']),
            if (provider['experience'] != null)
              _buildDetailRow('Experience', '${provider['experience']} years'),
            
            const SizedBox(height: 16),
            _buildSectionTitle('Appointment Details'),
            _buildDetailRow('Status', appointment['status']?.toString().toUpperCase() ?? 'Unknown'),
            _buildDetailRow('Service Type', appointment['serviceType'] ?? 'Consultation'),
            _buildDetailRow('Scheduled Time', DateFormatter.formatToHumanReadable(appointment['scheduledTime'])),
            if (appointment['consultationType'] != null)
              _buildDetailRow('Consultation Type', appointment['consultationType'].toString().replaceAll('_', ' ')),
            if (appointment['price'] != null)
              _buildDetailRow('Fee', '₹${appointment['price']}'),
            if (appointment['paymentMethod'] != null)
              _buildDetailRow('Payment Method', appointment['paymentMethod'].toString().toUpperCase()),
            if (appointment['paymentStatus'] != null)
              _buildDetailRow('Payment Status', appointment['paymentStatus'].toString().toUpperCase()),
            
            if (appointment['notes'] != null && appointment['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Notes', appointment['notes']),
            ],
            
            if (location['address'] != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Address', location['address']),
            ],
            
            if (appointment['isEmergency'] == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'EMERGENCY APPOINTMENT',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            _buildSectionTitle('Timeline'),
            _buildDetailRow('Created', DateFormatter.formatToHumanReadable(appointment['createdAt'])),
            _buildDetailRow('Last Updated', DateFormatter.formatToHumanReadable(appointment['updatedAt'])),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}