import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../doctors/doctors_screen.dart';
import '../services/nurses_screen.dart';
import '../services/ambulance_screen.dart';
import '../services/pathology_screen.dart';
import '../services/doctor_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;
  bool _isLocationLoading = false;
  String _currentCity = 'Mumbai';
  String _currentState = 'Maharashtra';

  // Healthcare service categories with images
  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'id': 'doctor',
      'title': 'Doctor',
      'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'imagePath': 'images/doctor_icon.png',
      'icon': Icons.local_hospital,
    },
    {
      'id': 'nurse',
      'title': 'Nurse',
      'gradient': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      'imagePath': 'images/nurse.png',
      'icon': Icons.healing,
    },
    {
      'id': 'pathology',
      'title': 'Lab Test',
      'gradient': [const Color(0xFF4A90E2), const Color(0xFF50C9FF)],
      'imagePath': 'images/lab_test.png',
      'icon': Icons.science,
    },
    {
      'id': 'ambulance',
      'title': 'Ambulance',
      'gradient': [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
      'imagePath': 'images/ambulance.png',
      'icon': Icons.local_shipping,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadData();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() => _isLocationLoading = true);
    
    try {
      // For web, location services work differently
      // Try to get location without strict permission check
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,  // Use low accuracy for faster response
          timeLimit: const Duration(seconds: 3),  // Shorter timeout
        ).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('Location timeout');
          },
        );
        
        // Try OpenStreetMap Nominatim API first
        try {
          final response = await http.get(
            Uri.parse(
              'https://nominatim.openstreetmap.org/reverse?'
              'format=json&lat=${position.latitude}&lon=${position.longitude}&'
              'addressdetails=1'
            ),
            headers: {'User-Agent': 'OnMintHealthcare/1.0'},
          ).timeout(const Duration(seconds: 3));
          
          if (response.statusCode == 200 && mounted) {
            final data = json.decode(response.body);
            final address = data['address'];
            
            if (address != null) {
              setState(() {
                _currentCity = address['city'] ?? 
                              address['town'] ?? 
                              address['village'] ?? 
                              address['suburb'] ??
                              _getCityFromCoordinates(position.latitude, position.longitude);
                _currentState = address['state'] ?? 'India';
                _isLocationLoading = false;
              });
              return;
            }
          }
        } catch (e) {
          print('Nominatim API error: $e');
        }
        
        // Fallback to coordinate-based city detection
        if (mounted) {
          setState(() {
            _currentCity = _getCityFromCoordinates(position.latitude, position.longitude);
            _currentState = 'India';
            _isLocationLoading = false;
          });
          return;
        }
      } catch (e) {
        print('Location error: $e');
      }
    } catch (e) {
      print('Location permission error: $e');
    }
    
    // Fallback to default (always executed if location fails)
    if (mounted) {
      setState(() {
        _currentCity = 'Mumbai';
        _currentState = 'Maharashtra';
        _isLocationLoading = false;
      });
    }
  }

  String _getCityFromCoordinates(double lat, double lon) {
    // Major Indian cities with their approximate coordinate ranges
    final cities = [
      {'name': 'Mumbai', 'lat': 19.0760, 'lon': 72.8777, 'range': 0.5},
      {'name': 'Delhi', 'lat': 28.7041, 'lon': 77.1025, 'range': 0.5},
      {'name': 'Bangalore', 'lat': 12.9716, 'lon': 77.5946, 'range': 0.5},
      {'name': 'Hyderabad', 'lat': 17.3850, 'lon': 78.4867, 'range': 0.5},
      {'name': 'Chennai', 'lat': 13.0827, 'lon': 80.2707, 'range': 0.5},
      {'name': 'Kolkata', 'lat': 22.5726, 'lon': 88.3639, 'range': 0.5},
      {'name': 'Pune', 'lat': 18.5204, 'lon': 73.8567, 'range': 0.5},
      {'name': 'Ahmedabad', 'lat': 23.0225, 'lon': 72.5714, 'range': 0.5},
      {'name': 'Jaipur', 'lat': 26.9124, 'lon': 75.7873, 'range': 0.5},
      {'name': 'Surat', 'lat': 21.1702, 'lon': 72.8311, 'range': 0.5},
      {'name': 'Lucknow', 'lat': 26.8467, 'lon': 80.9462, 'range': 0.5},
      {'name': 'Kanpur', 'lat': 26.4499, 'lon': 80.3319, 'range': 0.5},
      {'name': 'Nagpur', 'lat': 21.1458, 'lon': 79.0882, 'range': 0.5},
      {'name': 'Indore', 'lat': 22.7196, 'lon': 75.8577, 'range': 0.5},
      {'name': 'Thane', 'lat': 19.2183, 'lon': 72.9781, 'range': 0.3},
      {'name': 'Bhopal', 'lat': 23.2599, 'lon': 77.4126, 'range': 0.5},
      {'name': 'Visakhapatnam', 'lat': 17.6868, 'lon': 83.2185, 'range': 0.5},
      {'name': 'Patna', 'lat': 25.5941, 'lon': 85.1376, 'range': 0.5},
      {'name': 'Vadodara', 'lat': 22.3072, 'lon': 73.1812, 'range': 0.5},
      {'name': 'Ghaziabad', 'lat': 28.6692, 'lon': 77.4538, 'range': 0.3},
      {'name': 'Ludhiana', 'lat': 30.9010, 'lon': 75.8573, 'range': 0.5},
      {'name': 'Agra', 'lat': 27.1767, 'lon': 78.0081, 'range': 0.5},
      {'name': 'Nashik', 'lat': 19.9975, 'lon': 73.7898, 'range': 0.5},
      {'name': 'Faridabad', 'lat': 28.4089, 'lon': 77.3178, 'range': 0.3},
      {'name': 'Meerut', 'lat': 28.9845, 'lon': 77.7064, 'range': 0.5},
      {'name': 'Rajkot', 'lat': 22.3039, 'lon': 70.8022, 'range': 0.5},
      {'name': 'Varanasi', 'lat': 25.3176, 'lon': 82.9739, 'range': 0.5},
      {'name': 'Srinagar', 'lat': 34.0837, 'lon': 74.7973, 'range': 0.5},
      {'name': 'Amritsar', 'lat': 31.6340, 'lon': 74.8723, 'range': 0.5},
      {'name': 'Allahabad', 'lat': 25.4358, 'lon': 81.8463, 'range': 0.5},
      {'name': 'Ranchi', 'lat': 23.3441, 'lon': 85.3096, 'range': 0.5},
      {'name': 'Howrah', 'lat': 22.5958, 'lon': 88.2636, 'range': 0.3},
      {'name': 'Coimbatore', 'lat': 11.0168, 'lon': 76.9558, 'range': 0.5},
      {'name': 'Jabalpur', 'lat': 23.1815, 'lon': 79.9864, 'range': 0.5},
      {'name': 'Gwalior', 'lat': 26.2183, 'lon': 78.1828, 'range': 0.5},
      {'name': 'Vijayawada', 'lat': 16.5062, 'lon': 80.6480, 'range': 0.5},
      {'name': 'Jodhpur', 'lat': 26.2389, 'lon': 73.0243, 'range': 0.5},
      {'name': 'Madurai', 'lat': 9.9252, 'lon': 78.1198, 'range': 0.5},
      {'name': 'Raipur', 'lat': 21.2514, 'lon': 81.6296, 'range': 0.5},
      {'name': 'Kota', 'lat': 25.2138, 'lon': 75.8648, 'range': 0.5},
    ];
    
    // Find closest city
    double minDistance = double.infinity;
    String closestCity = 'Mumbai';
    
    for (var city in cities) {
      final cityLat = city['lat'] as double;
      final cityLon = city['lon'] as double;
      final range = city['range'] as double;
      
      final distance = ((lat - cityLat).abs() + (lon - cityLon).abs());
      
      if (distance < range && distance < minDistance) {
        minDistance = distance;
        closestCity = city['name'] as String;
      }
    }
    
    return closestCity;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Load medicines only
      final medicinesResponse = await _patientService.searchMedicines(limit: 20);
      final medicines = medicinesResponse['data'] ?? [];
      
      if (mounted) {
        setState(() {
          _medicines = List<Map<String, dynamic>>.from(medicines);
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Fixed Header with Location and Search
          _buildFixedHeader(),
          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Service Cards with Images
                    _buildQuickServiceCards(),
                    
                    const SizedBox(height: 20),
                    
                    // QR Scan Section for Appointment Token
                    _buildAppointmentTokenSection(),
                    
                    const SizedBox(height: 16),
                    
                    // Advertisement Banner
                    _buildAdvertisementBanner(),
                    
                    const SizedBox(height: 20),
                    
                    // Medicine Categories Section
                    _buildMedicineCategoriesSection(),
                    
                    const SizedBox(height: 32),
                    
                    // General Medicines Section (NEW)
                    if (!_isLoading && _medicines.isNotEmpty) ...[
                      _buildGeneralMedicinesSection(),
                      const SizedBox(height: 32),
                    ],
                    
                    // Featured Medicines Section
                    if (!_isLoading && _medicines.isNotEmpty) ...[
                      _buildFeaturedMedicinesSection(),
                      const SizedBox(height: 32),
                    ],
                    
                    // Most Purchased Section
                    if (!_isLoading && _medicines.isNotEmpty) ...[
                      _buildMostPurchasedSection(),
                      const SizedBox(height: 32),
                    ],
                    
                    // High Discount Section
                    if (!_isLoading && _medicines.isNotEmpty) ...[
                      _buildHighDiscountSection(),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
            // Location Bar
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Location icon
                  GestureDetector(
                    onTap: _showLocationPicker,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF4A90E2),
                      size: 24,
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
                                    '$_currentCity, $_currentState',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification icon
                  GestureDetector(
                    onTap: () {
                      // Navigate to notifications
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Container(
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
                        colors: [Color(0xFF4A90E2), Color(0xFF50C9FF)],
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
                onSubmitted: (value) {
                  // Implement search
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServiceCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _serviceCategories.map((category) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateToServiceScreen(category['id']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  // Rectangle container for service icons with images
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/${category['imagePath']}',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            category['icon'],
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Service name
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final name = 'Dr. ${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}'.trim();
    final specialization = doctor['specialization']?.toString() ?? 'General Physician';
    final experience = doctor['experience']?.toString() ?? '0';
    final fee = doctor['consultationFee']?.toString() ?? '500';
    
    return GestureDetector(
      onTap: () {
        // Convert Map to User object for navigation
        try {
          final doctorUser = User.fromJson(doctor);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctorUser),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading doctor details: $e')),
          );
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF667EEA),
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1) : 'D',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  specialization,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$experience years exp',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Text(
                  '₹$fee',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNurseCard(Map<String, dynamic> nurse) {
    final name = '${nurse['firstName'] ?? ''} ${nurse['lastName'] ?? ''}'.trim();
    final specialization = nurse['specialization']?.toString() ?? 'General Nursing';
    final experience = nurse['experience']?.toString() ?? '0';
    final fee = nurse['consultationFee']?.toString() ?? '300';
    
    return GestureDetector(
      onTap: () {
        // Navigate to nurse detail screen
        try {
          final nurseUser = User.fromJson(nurse);
          Navigator.pushNamed(
            context,
            '/nurse-detail',
            arguments: nurseUser,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading nurse details: $e')),
          );
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF11998E),
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1) : 'N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  specialization,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$experience years exp',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Text(
                  '₹$fee',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF11998E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToServiceScreen(String serviceId) {
    switch (serviceId) {
      case 'doctor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DoctorsScreen()),
        );
        break;
      case 'nurse':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NursesScreen()),
        );
        break;
      case 'ambulance':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AmbulanceScreen()),
        );
        break;
      case 'pathology':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PathologyScreen()),
        );
        break;
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
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
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF4A90E2),
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
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.location_city, color: Color(0xFF4A90E2), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Or Select City & State',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Major Indian Cities
                  _buildCityTile('Mumbai', 'Maharashtra'),
                  _buildCityTile('Delhi', 'Delhi'),
                  _buildCityTile('Bangalore', 'Karnataka'),
                  _buildCityTile('Hyderabad', 'Telangana'),
                  _buildCityTile('Chennai', 'Tamil Nadu'),
                  _buildCityTile('Kolkata', 'West Bengal'),
                  _buildCityTile('Pune', 'Maharashtra'),
                  _buildCityTile('Ahmedabad', 'Gujarat'),
                  _buildCityTile('Jaipur', 'Rajasthan'),
                  _buildCityTile('Lucknow', 'Uttar Pradesh'),
                  _buildCityTile('Kanpur', 'Uttar Pradesh'),
                  _buildCityTile('Nagpur', 'Maharashtra'),
                  _buildCityTile('Indore', 'Madhya Pradesh'),
                  _buildCityTile('Thane', 'Maharashtra'),
                  _buildCityTile('Bhopal', 'Madhya Pradesh'),
                  _buildCityTile('Visakhapatnam', 'Andhra Pradesh'),
                  _buildCityTile('Patna', 'Bihar'),
                  _buildCityTile('Vadodara', 'Gujarat'),
                  _buildCityTile('Ghaziabad', 'Uttar Pradesh'),
                  _buildCityTile('Ludhiana', 'Punjab'),
                  _buildCityTile('Agra', 'Uttar Pradesh'),
                  _buildCityTile('Nashik', 'Maharashtra'),
                  _buildCityTile('Faridabad', 'Haryana'),
                  _buildCityTile('Meerut', 'Uttar Pradesh'),
                  _buildCityTile('Rajkot', 'Gujarat'),
                  _buildCityTile('Varanasi', 'Uttar Pradesh'),
                  _buildCityTile('Srinagar', 'Jammu and Kashmir'),
                  _buildCityTile('Aurangabad', 'Maharashtra'),
                  _buildCityTile('Dhanbad', 'Jharkhand'),
                  _buildCityTile('Amritsar', 'Punjab'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTile(String city, String state) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined, color: Color(0xFF4A90E2), size: 20),
      title: Text(
        city,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        state,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
        ),
      ),
      onTap: () {
        setState(() {
          _currentCity = city;
          _currentState = state;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAppointmentTokenSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
            onTap: () {
              // Open QR scanner
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('QR Scanner'),
                  content: const Text('QR scanner functionality will be implemented here.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ); 
            },
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget _buildEnhancedMedicineCard(Map<String, dynamic> medicine) {
    final name = medicine['name']?.toString() ?? 'Medicine';
    final price = medicine['discountedPrice'] ?? medicine['price'] ?? 0;
    final originalPrice = medicine['price'] ?? price;
    final hasDiscount = medicine['discountedPrice'] != null && originalPrice > price;
    final discountPercent = hasDiscount 
        ? ((originalPrice - price) / originalPrice * 100).round()
        : 0;
    final medicineId = medicine['_id']?.toString() ?? medicine['id']?.toString() ?? '';
    final manufacturer = medicine['manufacturer']?.toString() ?? '';
    
    return Container(
      width: 160,
      height: 280,  // Phone-friendly dimensions
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,  // Use minimum space needed
        children: [
          // Image with discount badge
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildMedicineImage(medicine),
                ),
              ),
              // Discount badge
              if (hasDiscount)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$discountPercent% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              // Stock status
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'In Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Medicine details
          Expanded(  // Use Expanded to fill remaining space
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  
                  // Manufacturer
                  if (manufacturer.isNotEmpty)
                    Text(
                      manufacturer,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(120)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),  // Push buttons to bottom
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '₹$originalPrice',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (medicineId.isNotEmpty) {
                              Navigator.pushNamed(
                                context,
                                '/medicine-detail',
                                arguments: medicineId,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Buy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF4A90E2),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Color(0xFF4A90E2),
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineImage(Map<String, dynamic> medicine) {
    String? imageUrl;
    
    // Try to get image from various fields
    if (medicine['images'] != null && (medicine['images'] as List).isNotEmpty) {
      imageUrl = medicine['images'][0];
    } else if (medicine['imageUrl'] != null) {
      imageUrl = medicine['imageUrl'];
    }
    
    // Fix relative URLs
    if (imageUrl != null && imageUrl.startsWith('/images/')) {
      imageUrl = 'http://localhost:5000$imageUrl';
    }
    
    // If no image, show placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medication,
                size: 50,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'No Image',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 140,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image Error',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner with gradient background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB6C1), Color(0xFFFFC0CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GENUINE EVERYDAY MEDICINES',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B4513),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '11 YEARS OF BRINGING CARE TO HEALTH!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Medicine cards in horizontal scroll
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              final medicine = _medicines[index];
              return _buildGeneralMedicineCard(medicine);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralMedicineCard(Map<String, dynamic> medicine) {
    final name = medicine['name']?.toString() ?? 'Medicine';
    final price = medicine['discountedPrice'] ?? medicine['price'] ?? 0;
    final originalPrice = medicine['price'] ?? price;
    final hasDiscount = originalPrice > price;
    final discountPercent = hasDiscount 
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;
    final rating = medicine['rating']?.toDouble() ?? 4.5;
    final medicineId = medicine['_id']?.toString() ?? medicine['id']?.toString() ?? '';
    
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          // Image with badges
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildMedicineImage(medicine),
                ),
              ),
              // Rating badge (top-left)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bestseller badge (top-right)
              if (rating >= 4.5)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bestseller',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${medicine['quantity'] ?? '10'} ${medicine['unit'] ?? 'tablets'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get by ${_getDeliveryDate()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  
                  // Price
                  Row(
                    children: [
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹$originalPrice',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasDiscount)
                    Text(
                      '$discountPercent% off',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  const SizedBox(height: 8),
                  
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (medicineId.isNotEmpty) {
                          Navigator.pushNamed(context, '/medicine-detail', arguments: medicineId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'ADD',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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

  String _getDeliveryDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 3));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[deliveryDate.weekday - 1]}, ${deliveryDate.day} ${months[deliveryDate.month - 1]}';
  }

  Widget _buildFeaturedMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Text(
                'Featured Medicines',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'HOT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medicines-list', arguments: 'featured');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              return _buildEnhancedMedicineCard(_medicines[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMostPurchasedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF10B981),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Most Purchased',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medicines-list', arguments: 'popular');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              return _buildEnhancedMedicineCard(_medicines[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighDiscountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(
                Icons.local_offer,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'High Discount',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Up to 70% OFF',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medicines-list', arguments: 'discount');
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              return _buildEnhancedMedicineCard(_medicines[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCategoriesSection() {
    final medicineCategories = [
      // Row 1
      {'name': 'Vitamins &\nSupplements', 'icon': Icons.medication, 'color': const Color(0xFFFF9E80)},
      {'name': 'Homeopathic\nMedicine', 'icon': Icons.local_florist, 'color': const Color(0xFF81D4FA)},
      {'name': 'Monitoring\nDevices', 'icon': Icons.monitor_heart, 'color': const Color(0xFFE1BEE7)},
      {'name': 'Protein &\nSupplements', 'icon': Icons.fitness_center, 'color': const Color(0xFFA5D6A7)},
      
      // Row 2
      {'name': 'Sexual\nWellness', 'icon': Icons.favorite, 'color': const Color(0xFFFFCDD2)},
      {'name': 'Ayurvedic\nWellness', 'icon': Icons.spa, 'color': const Color(0xFFC5E1A5)},
      {'name': 'Food &\nNutrition', 'icon': Icons.restaurant, 'color': const Color(0xFFFFF59D)},
      {'name': 'Pet Care', 'icon': Icons.pets, 'color': const Color(0xFFFFE082)},
      
      // Row 3
      {'name': 'Skin Care', 'icon': Icons.face, 'color': const Color(0xFFB3E5FC)},
      {'name': 'Men Care', 'icon': Icons.man, 'color': const Color(0xFFCE93D8)},
      {'name': 'Women Care', 'icon': Icons.woman, 'color': const Color(0xFFF8BBD0)},
      {'name': 'Elderly Care', 'icon': Icons.elderly, 'color': const Color(0xFFDCE775)},
      
      // Row 4
      {'name': 'Pain Relief', 'icon': Icons.healing, 'color': const Color(0xFFFFAB91)},
      {'name': 'Diabetes', 'icon': Icons.bloodtype, 'color': const Color(0xFFA5D6A7)},
      {'name': 'Hair Care', 'icon': Icons.content_cut, 'color': const Color(0xFFFFCC80)},
      {'name': 'Oral Care', 'icon': Icons.clean_hands, 'color': const Color(0xFF80CBC4)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF50C9FF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Shop by Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/medicines-list');
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 4x4 Grid of Categories
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 columns
            childAspectRatio: 0.85, // Slightly taller cards
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: medicineCategories.length,
          itemBuilder: (context, index) {
            final category = medicineCategories[index];
            
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/medicines-list',
                  arguments: {'category': category['name']},
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon instead of image
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Category name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}