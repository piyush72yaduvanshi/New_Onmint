import 'package:flutter/material.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class NursesScreen extends StatefulWidget {
  const NursesScreen({Key? key}) : super(key: key);

  @override
  State<NursesScreen> createState() => _NursesScreenState();
}

class _NursesScreenState extends State<NursesScreen> {
  late final PatientService _patientService;
  
  List<Map<String, dynamic>> _nurses = [];
  String _selectedCategory = '';
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _nurseCategories = [
    {'id': '', 'name': 'All Nurses', 'icon': Icons.health_and_safety},
    {'id': 'home_care', 'name': 'Home Care', 'icon': Icons.home_work},
    {'id': 'elderly_care', 'name': 'Elderly Care', 'icon': Icons.elderly},
    {'id': 'child_care', 'name': 'Child Care', 'icon': Icons.child_care},
    {'id': 'post_surgery', 'name': 'Post Surgery', 'icon': Icons.healing},
    {'id': 'wound_care', 'name': 'Wound Care', 'icon': Icons.medical_services},
    {'id': 'injection', 'name': 'Injection', 'icon': Icons.vaccines},
    {'id': 'physiotherapy', 'name': 'Physiotherapy', 'icon': Icons.accessibility_new},
  ];

  @override
  void initState() {
    super.initState();
    _patientService = PatientService();
    _loadNurses();
  }

  Future<void> _loadNurses() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _patientService.getNearbyServices(
        serviceType: 'nurse',
        limit: 50,
      );

      if (response.success && response.data != null) {
        final nurses = response.data!['nurses'] ?? [];
        setState(() {
          _nurses = List<Map<String, dynamic>>.from(nurses);
        });
      }
    } catch (e) {
      print('Error loading nurses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurses'),
        backgroundColor: const Color(0xFF11998E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildQuickBookSection(),
          _buildCategoriesSection(),
          Expanded(child: _buildNursesList()),
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
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Home Care Service?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book qualified nurses for home care services',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF11998E),
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Care Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _nurseCategories.length,
            itemBuilder: (context, index) {
              final category = _nurseCategories[index];
              final isSelected = _selectedCategory == category['id'];
              
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category['id']),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF11998E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'],
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF11998E) : Colors.grey[700],
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
      ],
    );
  }

  Widget _buildNursesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF11998E)));
    }

    if (_nurses.isEmpty) {
      return const Center(
        child: Text('No nurses available', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nurses.length,
      itemBuilder: (context, index) {
        final nurse = _nurses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF11998E),
              child: Text(
                '${nurse['firstName']?[0] ?? 'N'}${nurse['lastName']?[0] ?? 'U'}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('${nurse['firstName'] ?? ''} ${nurse['lastName'] ?? ''}'),
            subtitle: Text(nurse['specialization'] ?? 'Home Care Nurse'),
            trailing: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF11998E)),
              child: const Text('Book', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}