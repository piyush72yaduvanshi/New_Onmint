import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'package:location_service/location_service.dart';
import '../doctors/doctors_screen.dart';
import '../booking/book_appointment_screen.dart';
import '../services/services_screen.dart';
import '../bookings/bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PatientService _patientService = PatientService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _nearbyDoctors = [];
  List<Map<String, dynamic>> _nearbyNurses = [];
  List<Map<String, dynamic>> _nearbyPharmacies = [];
  List<Map<String, dynamic>> _nearbyAmbulances = [];
  List<Map<String, dynamic>> _nearbyBloodBanks = [];
  List<Map<String, dynamic>> _nearbyLabs = [];
  List<Map<String, dynamic>> _activeBookings = [];
  
  bool _isLoading = true;
  bool _isLocationLoading = true;
  String _selectedCategory = '';  // Start with no selection
  int _selectedBottomNavIndex = 0;
  int _unreadNotificationsCount = 0;
  
  double? _currentLatitude;
  double? _currentLongitude;
  String _currentCity = 'Loading...';
  String _currentState = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Healthcare service categories with modern design
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'id': 'doctor',
      'title': 'Doctor',
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'useImage': true,
      'imagePath': 'images/doctor_icon.png',
      'icon': Icons.local_hospital,
    },
    {
      'id': 'nurse',
      'title': 'Nurse',
      'gradient': [Color(0xFF11998E), Color(0xFF38EF7D)],
      'useImage': true,
      'imagePath': 'images/nurse.png',
      'icon': Icons.healing,
    },
    {
      'id': 'pharmacist',
      'title': 'Pharmacy',
      'gradient': [Color(0xFF667EEA), Color(0xFF764BA2)],
      'useImage': true,
      'imagePath': 'images/pharmacy.png',
      'icon': Icons.local_pharmacy,
    },
    {
      'id': 'pathology',
      'title': 'Lab Test',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
      'useImage': true,
      'imagePath': 'images/lab_test.png',
      'icon': Icons.science,
    },
    {
      'id': 'ambulance',
      'title': 'Ambulance',
      'gradient': [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
      'useImage': true,
      'imagePath': 'images/ambulance.png',
      'icon': Icons.local_shipping,
    },
    {
      'id': 'bloodbank',
      'title': 'Blood Bank',
      'gradient': [Color(0xFFFF416C), Color(0xFFFF4B2B)],
      'useImage': true,
      'imagePath': 'images/bloodbank.png',
      'icon': Icons.bloodtype,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location first
      await _getCurrentLocation();
      
      // Load nearby services
      await _loadNearbyServices();
      
      // Load active bookings
      await _loadActiveBookings();
      
      // Load notifications count
      await _loadUnreadNotificationsCount();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    
    try {
      final locationPoint = await _locationService.getCurrentLocation();
      if (locationPoint != null) {
        setState(() {
          _currentLatitude = locationPoint.latitude;
          _currentLongitude = locationPoint.longitude;
          _currentCity = 'Current Location'; // We'll get city name from reverse geocoding later
          _currentState = '';
          _isLocationLoading = false;
        });
        
        // Try to get address from coordinates (if geocoding is implemented)
        try {
          final address = await _locationService.getAddressFromLocation(locationPoint);
          if (address != null) {
            final parts = address.split(', ');
            setState(() {
              _currentCity = parts.length > 1 ? parts[1] : 'Current Location';
              _currentState = parts.length > 2 ? parts[2] : '';
            });
          }
        } catch (e) {
          print('Could not get address: $e');
          // Keep default values
        }
      } else {
        setState(() {
          _currentCity = 'Location unavailable';
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentCity = 'Location unavailable';
        _isLocationLoading = false;
      });
    }
  }
  Future<void> _loadNearbyServices() async {
    try {
      // First try to load nearby doctors if location is available
      if (_currentLatitude != null && _currentLongitude != null) {
        final doctorsResponse = await _patientService.getNearbyServices(
          serviceType: 'doctor',
          latitude: _currentLatitude!,
          longitude: _currentLongitude!,
          radius: 5,
        );

        if (doctorsResponse.success && doctorsResponse.data != null) {
          final doctors = doctorsResponse.data!['doctors'] ?? [];
          if (doctors is List && doctors.isNotEmpty) {
            setState(() {
              _nearbyDoctors = List<Map<String, dynamic>>.from(doctors);
            });
            print('✅ Loaded ${_nearbyDoctors.length} nearby doctors');
            return; // Exit early if we got nearby doctors
          }
        }
      }
      
      // Fallback: Load all active doctors if nearby search fails or no location
      print('🔄 Fallback: Loading all active doctors');
      final allDoctorsResponse = await _patientService.getAllDoctors(limit: 10);
      
      if (allDoctorsResponse.success && allDoctorsResponse.data != null) {
        final doctors = allDoctorsResponse.data!['doctors'] ?? [];
        setState(() {
          _nearbyDoctors = List<Map<String, dynamic>>.from(doctors);
        });
        print('✅ Loaded ${_nearbyDoctors.length} doctors as fallback');
      } else {
        print('❌ Failed to load doctors: ${allDoctorsResponse.error?.message}');
      }

      // Load other services (nurses, pharmacies, etc.) - similar pattern
      // For now, we'll focus on doctors as the main service

    } catch (e) {
      print('❌ Error loading nearby services: $e');
      // Try fallback even on exception
      try {
        final allDoctorsResponse = await _patientService.getAllDoctors(limit: 10);
        if (allDoctorsResponse.success && allDoctorsResponse.data != null) {
          final doctors = allDoctorsResponse.data!['doctors'] ?? [];
          setState(() {
            _nearbyDoctors = List<Map<String, dynamic>>.from(doctors);
          });
          print('✅ Loaded ${_nearbyDoctors.length} doctors as exception fallback');
        }
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
      }
    }
  }
  Future<void> _loadActiveBookings() async {
    try {
      final response = await _patientService.getActiveBookings();
      if (response.success && response.data != null) {
        setState(() {
          _activeBookings = List<Map<String, dynamic>>.from(response.data!['bookings'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading active bookings: $e');
    }
  }

  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final response = await _patientService.getUnreadCount();
      if (response.success) {
        setState(() {
          _unreadNotificationsCount = response.data ?? 0;
        });
      }
    } catch (e) {
      print('Error loading notifications count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed Header
          _buildFixedHeader(),
          // Scrollable Content
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF667EEA)))
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildQuickServiceCards(),
                          _buildAppointmentTokenSection(),
                          _buildAdvertisementBanner(),
                          _buildNearbyDoctorsSection(),
                          _buildActiveBookingsSection(),
                          _buildEmergencySection(),
                          const SizedBox(height: 100), // Space for bottom nav
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  Widget _buildFixedHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopNavigationBar(),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigationBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Location icon and city
          GestureDetector(
            onTap: _showLocationPicker,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _showLocationPicker,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLocationLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF667EEA),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _currentCity,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6B7280),
                          size: 18,
                        ),
                      ],
                    ),
                  if (!_isLocationLoading && _currentState.isNotEmpty)
                    Text(
                      _currentState,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification icon
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  if (_unreadNotificationsCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search doctors, services, medicines...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildQuickServiceCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _serviceCategories.take(4).map((category) {  // Only show first 4 services
          final isSelected = _selectedCategory == category['id'];
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _navigateToServiceScreen(category['id']),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    // Rectangle container for service icons
                    Container(
                      width: 65,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: isSelected 
                            ? LinearGradient(
                                colors: [
                                  (category['gradient'][0] as Color).withOpacity(0.8),
                                  (category['gradient'][1] as Color).withOpacity(0.8),
                                ],
                              )
                            : LinearGradient(
                                colors: category['gradient'],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: (category['gradient'][0] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: category['useImage'] == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/${category['imagePath']}',
                                width: 65,
                                height: 55,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    category['icon'],
                                    color: Colors.white,
                                    size: 28,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              category['icon'],
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                    const SizedBox(height: 8),
                    // Service name
                    Text(
                      category['title'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF667EEA) : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildAppointmentTokenSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF667EEA), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF667EEA),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'अपॉइंटमेंट टोकन प्राप्त करें',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF667EEA),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'QR कोड स्कैन करें',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openQRScanner(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF667EEA),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.campaign_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Up to 50% Savings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'with Generic Medicines',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildNearbyDoctorsSection() {
    if (_nearbyDoctors.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_searching,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Finding nearby doctors...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please ensure location is enabled',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.local_hospital,
                color: Color(0xFF667EEA),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Nearby Doctors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _navigateToAllDoctors(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF667EEA),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF667EEA),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nearbyDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _nearbyDoctors[index];
              return _buildDoctorCard(doctor);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return GestureDetector(
      onTap: () => _navigateToDoctorDetail(doctor),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor image placeholder
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: doctor['profilePicture'] != null && doctor['profilePicture'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        doctor['profilePicture'],
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF667EEA),
                              size: 32,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF667EEA),
                        size: 32,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}'.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['specialization'] ?? 'General Physician',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.5', // You can get this from doctor data
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '₹${doctor['consultationFee'] ?? 500}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: ElevatedButton(
                      onPressed: () => _bookAppointment(doctor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildActiveBookingsSection() {
    if (_activeBookings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Active Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _activeBookings.length,
          itemBuilder: (context, index) {
            final booking = _activeBookings[index];
            return _buildBookingCard(booking);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF667EEA),
            child: Text(
              booking['providerName']?.substring(0, 1)?.toUpperCase() ?? 'D',
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
                  booking['providerName'] ?? 'Healthcare Provider',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${booking['serviceType']?.toString().toUpperCase() ?? 'SERVICE'} • ${booking['scheduledTime'] ?? 'Time TBD'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              booking['status']?.toString().toUpperCase() ?? 'ACTIVE',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmergencySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '24/7 Emergency Support',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callEmergency(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.call,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBottomNavItem(Icons.home_rounded, 'Home', 0),
          _buildBottomNavItem(Icons.receipt_long_rounded, 'Bookings', 1),
          _buildLabTestButton(),
          _buildBottomNavItem(Icons.notifications_rounded, 'Alerts', 3),
          _buildBottomNavItem(Icons.bloodtype_rounded, 'Blood Bank', 4),
          _buildBottomNavItem(Icons.person_rounded, 'Profile', 5),
        ],
      ),
    );
  }
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 5) { // Profile tab
            Navigator.pushNamed(context, '/profile');
          } else if (index == 1) { // Bookings tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingsScreen()),
            );
          } else if (index == 3) { // Notifications tab
            Navigator.pushNamed(context, '/notifications');
          } else if (index == 4) { // Blood Bank tab
            Navigator.pushNamed(context, '/bloodbank');
          } else {
            setState(() => _selectedBottomNavIndex = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? const Color(0xFF667EEA) : Colors.grey[400],
                      size: 24,
                    ),
                    if (index == 3 && _unreadNotificationsCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotificationsCount > 99 ? '99+' : _unreadNotificationsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF667EEA) : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabTestButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToLabTests(),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                'Lab Test',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Navigation and action methods
  void _navigateToServiceScreen(String serviceId) {
    setState(() {
      _selectedCategory = serviceId;
    });
    
    // Navigate to dedicated service screens
    switch (serviceId) {
      case 'doctor':
        Navigator.pushNamed(context, '/doctors');
        break;
      case 'nurse':
        Navigator.pushNamed(context, '/nurses');
        break;
      case 'pathology':
        Navigator.pushNamed(context, '/pathology');
        break;
      case 'ambulance':
        Navigator.pushNamed(context, '/ambulance');
        break;
      case 'bloodbank':
        Navigator.pushNamed(context, '/bloodbank');
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServicesScreen(initialServiceType: serviceId),
          ),
        );
    }
  }

  void _navigateToDoctorDetail(Map<String, dynamic> doctor) {
    Navigator.pushNamed(context, '/doctor-detail', arguments: doctor);
  }

  void _navigateToAllDoctors() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DoctorsScreen(),
      ),
    );
  }

  void _navigateToLabTests() {
    Navigator.pushNamed(context, '/lab-tests');
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(doctor: doctor),
      ),
    );
  }

  void _callEmergency() async {
    if (_currentLatitude != null && _currentLongitude != null) {
      try {
        await _patientService.createEmergency({
          'location': {
            'coordinates': [_currentLongitude!, _currentLatitude!]
          },
          'serviceType': 'ambulance',
          'notes': 'Emergency request from mobile app',
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency request sent! Help is on the way.'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send emergency request. Please try again.'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
        }
      }
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.pushNamed(context, '/search', arguments: query);
  }

  void _openQRScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('QR Scanner'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: Color(0xFF667EEA),
              ),
              SizedBox(height: 16),
              Text(
                'QR Scanner functionality will be implemented here',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            // Current location option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              title: const Text(
                'Use Current Location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              subtitle: const Text(
                'Allow location access for better experience',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}