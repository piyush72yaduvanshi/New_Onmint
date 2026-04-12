import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import '../booking/book_appointment_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  late final PatientService _patientService;
  
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  String _selectedSpecialization = '';
  bool _isLoading = true;
  String? _error;
  
  final List<Map<String, dynamic>> _specializations = [
    {'id': '', 'name': 'All Doctors', 'icon': Icons.medical_services},
    {'id': 'cardiologist', 'name': 'Cardiologist', 'icon': Icons.favorite},
    {'id': 'dermatologist', 'name': 'Dermatologist', 'icon': Icons.face},
    {'id': 'gynecologist', 'name': 'Gynecologist', 'icon': Icons.pregnant_woman},
    {'id': 'pediatrician', 'name': 'Pediatrician', 'icon': Icons.child_care},
    {'id': 'orthopedic', 'name': 'Orthopedic', 'icon': Icons.accessibility},
    {'id': 'neurologist', 'name': 'Neurologist', 'icon': Icons.psychology},
    {'id': 'ophthalmologist', 'name': 'Eye Specialist', 'icon': Icons.visibility},
    {'id': 'dentist', 'name': 'Dentist', 'icon': Icons.medical_services},
    {'id': 'psychiatrist', 'name': 'Psychiatrist', 'icon': Icons.psychology_alt},
    {'id': 'general', 'name': 'General Physician', 'icon': Icons.local_hospital},
  ];

  @override
  void initState() {
    super.initState();
    _patientService = PatientService();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _patientService.getNearbyServices(
        serviceType: 'doctor',
        limit: 50,
      );

      if (response.success && response.data != null) {
        final doctors = response.data!['doctors'] ?? [];
        setState(() {
          _doctors = List<Map<String, dynamic>>.from(doctors);
          _filteredDoctors = _doctors;
        });
      } else {
        setState(() {
          _error = response.error?.message ?? 'Failed to load doctors';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading doctors: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBySpecialization(String specialization) {
    setState(() {
      _selectedSpecialization = specialization;
      if (specialization.isEmpty) {
        _filteredDoctors = _doctors;
      } else {
        _filteredDoctors = _doctors.where((doctor) {
          final doctorSpec = doctor['specialization']?.toString().toLowerCase() ?? '';
          return doctorSpec.contains(specialization.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Book Section
          _buildQuickBookSection(),
          
          // Specializations
          _buildSpecializationsSection(),
          
          // Doctors List
          Expanded(
            child: _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBookSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Immediate Consultation?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book an appointment with available doctors now',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _bookImmediateConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.video_call,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Specializations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _specializations.length,
            itemBuilder: (context, index) {
              final spec = _specializations[index];
              final isSelected = _selectedSpecialization == spec['id'];
              
              return GestureDetector(
                onTap: () => _filterBySpecialization(spec['id']),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          spec['icon'],
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        spec['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDoctorsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedSpecialization.isEmpty 
                  ? 'No doctors available'
                  : 'No doctors found for selected specialization',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedSpecialization.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _filterBySpecialization(''),
                child: const Text('View All Doctors'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _selectedSpecialization.isEmpty 
                ? 'Nearby Doctors (${_filteredDoctors.length})'
                : '${_specializations.firstWhere((s) => s['id'] == _selectedSpecialization)['name']} (${_filteredDoctors.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _filteredDoctors[index];
              return _buildDoctorCard(doctor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final doctorName = 'Dr. ${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}'.trim();
    final specialization = doctor['specialization']?.toString() ?? 'General Physician';
    final experience = doctor['experience']?.toString() ?? '0';
    final consultationFee = doctor['consultationFee']?.toString() ?? '500';
    final rating = '4.5'; // Mock rating
    final isAvailable = doctor['isAvailable'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    doctorName.isNotEmpty ? doctorName.substring(0, 2).toUpperCase() : 'DR',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
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
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.work_outline,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$experience years',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 12,
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultation Fee',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹$consultationFee',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: isAvailable ? () => _bookAppointment(doctor) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _bookImmediateConsultation() {
    // Find first available doctor
    final availableDoctor = _doctors.firstWhere(
      (doctor) => doctor['isAvailable'] == true,
      orElse: () => _doctors.isNotEmpty ? _doctors.first : {},
    );

    if (availableDoctor.isNotEmpty) {
      _bookAppointment(availableDoctor);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No doctors available for immediate consultation'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _bookAppointment(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(doctor: doctor),
      ),
    );
  }
}