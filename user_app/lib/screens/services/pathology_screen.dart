import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';

class PathologyScreen extends StatefulWidget {
  const PathologyScreen({super.key});

  @override
  State<PathologyScreen> createState() => _PathologyScreenState();
}

class _PathologyScreenState extends State<PathologyScreen> {
  final PatientService _patientService = PatientService();
  
  List<Map<String, dynamic>> _labs = [];
  String _selectedCategory = '';
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _testCategories = [
    {'id': '', 'name': 'All Tests', 'icon': Icons.science},
    {'id': 'blood_test', 'name': 'Blood Test', 'icon': Icons.bloodtype},
    {'id': 'urine_test', 'name': 'Urine Test', 'icon': Icons.local_hospital},
    {'id': 'diabetes', 'name': 'Diabetes', 'icon': Icons.monitor_heart},
    {'id': 'thyroid', 'name': 'Thyroid', 'icon': Icons.medical_services},
    {'id': 'liver', 'name': 'Liver Function', 'icon': Icons.health_and_safety},
    {'id': 'kidney', 'name': 'Kidney Function', 'icon': Icons.water_drop},
    {'id': 'cardiac', 'name': 'Cardiac', 'icon': Icons.favorite},
    {'id': 'vitamin', 'name': 'Vitamin', 'icon': Icons.medication},
    {'id': 'allergy', 'name': 'Allergy Test', 'icon': Icons.warning},
  ];

  @override
  void initState() {
    super.initState();
    _loadLabs();
  }

  Future<void> _loadLabs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      // TODO: Implement pathology labs API endpoint
      // For now, show empty state
      if (mounted) {
        setState(() {
          _labs = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _labs = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Tests'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildQuickBookSection(),
          _buildCategoriesSection(),
          Expanded(child: _buildLabsList()),
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
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Lab Tests?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book lab tests with home sample collection',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF6B6B),
                  ),
                  child: const Text('Book Test'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home, color: Colors.white),
              ),
            ],
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
            'Test Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _testCategories.length,
            itemBuilder: (context, index) {
              final category = _testCategories[index];
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
                          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[100],
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
                          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[700],
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

  Widget _buildLabsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
    }

    if (_labs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No labs available', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Pathology lab services coming soon',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _labs.length,
      itemBuilder: (context, index) {
        final lab = _labs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFFF6B6B),
                      child: Icon(Icons.science, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lab['labName'] ?? 'Lab Center',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            lab['address'] ?? 'Lab Address',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
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
                            'Home Collection',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Text(
                            'Available',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
                      child: const Text('Book Test', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
