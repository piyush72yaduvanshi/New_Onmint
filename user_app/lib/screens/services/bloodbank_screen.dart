import 'package:flutter/material.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class BloodbankScreen extends StatefulWidget {
  const BloodbankScreen({Key? key}) : super(key: key);

  @override
  State<BloodbankScreen> createState() => _BloodbankScreenState();
}

class _BloodbankScreenState extends State<BloodbankScreen> {
  late final PatientService _patientService;
  
  List<Map<String, dynamic>> _bloodBanks = [];
  String _selectedBloodGroup = '';
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _bloodGroups = [
    {'id': '', 'name': 'All Groups', 'color': Colors.grey},
    {'id': 'A+', 'name': 'A+', 'color': Colors.red},
    {'id': 'A-', 'name': 'A-', 'color': Colors.red[300]},
    {'id': 'B+', 'name': 'B+', 'color': Colors.blue},
    {'id': 'B-', 'name': 'B-', 'color': Colors.blue[300]},
    {'id': 'AB+', 'name': 'AB+', 'color': Colors.purple},
    {'id': 'AB-', 'name': 'AB-', 'color': Colors.purple[300]},
    {'id': 'O+', 'name': 'O+', 'color': Colors.green},
    {'id': 'O-', 'name': 'O-', 'color': Colors.green[300]},
  ];

  @override
  void initState() {
    super.initState();
    _patientService = PatientService();
    _loadBloodBanks();
  }

  Future<void> _loadBloodBanks() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _patientService.getNearbyServices(
        serviceType: 'bloodbank',
        limit: 50,
      );

      if (response.success && response.data != null) {
        final bloodBanks = response.data!['bloodbanks'] ?? [];
        setState(() {
          _bloodBanks = List<Map<String, dynamic>>.from(bloodBanks);
        });
      }
    } catch (e) {
      print('Error loading blood banks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Bank'),
        backgroundColor: const Color(0xFFFF416C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildEmergencySection(),
          _buildBloodGroupsSection(),
          Expanded(child: _buildBloodBanksList()),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bloodtype, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Emergency Blood Request',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Need blood urgently? Find nearby blood banks and request blood',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _requestEmergencyBlood(),
                  icon: const Icon(Icons.emergency),
                  label: const Text('Emergency Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF416C),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _donateBlood(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Donate'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Blood Groups',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              final group = _bloodGroups[index];
              final isSelected = _selectedBloodGroup == group['id'];
              
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodGroup = group['id']),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? group['color'] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected 
                              ? Border.all(color: group['color'], width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            group['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildBloodBanksList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF416C)));
    }

    if (_bloodBanks.isEmpty) {
      return const Center(
        child: Text('No blood banks available', style: TextStyle(fontSize: 16)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _selectedBloodGroup.isEmpty 
                ? 'Nearby Blood Banks (${_bloodBanks.length})'
                : 'Blood Banks with $_selectedBloodGroup (${_bloodBanks.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _bloodBanks.length,
            itemBuilder: (context, index) {
              final bloodBank = _bloodBanks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF416C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bloodtype,
                              color: Color(0xFFFF416C),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bloodBank['bankName'] ?? 'Blood Bank',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  bloodBank['address'] ?? 'Blood Bank Address',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  'Contact: ${bloodBank['emergencyContact'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '24/7 Open',
                              style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (bloodBank['bloodStock'] != null) ...[
                        const Text(
                          'Blood Availability:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (bloodBank['bloodStock'] as List).map((stock) {
                            final group = stock['bloodGroup'];
                            final units = stock['unitsAvailable'];
                            final isAvailable = units > 0;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAvailable ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '$group: $units units',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _callBloodBank(bloodBank),
                              icon: const Icon(Icons.call),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF416C),
                                side: const BorderSide(color: Color(0xFFFF416C)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _requestBlood(bloodBank),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF416C)),
                              child: const Text('Request Blood', style: TextStyle(color: Colors.white)),
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
        ),
      ],
    );
  }

  void _requestEmergencyBlood() {
    // TODO: Implement emergency blood request
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing emergency blood request...'),
        backgroundColor: Color(0xFFFF416C),
      ),
    );
  }

  void _donateBlood() {
    // TODO: Implement blood donation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your interest in blood donation!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callBloodBank(Map<String, dynamic> bloodBank) {
    // TODO: Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${bloodBank['bankName']}...'),
        backgroundColor: const Color(0xFFFF416C),
      ),
    );
  }

  void _requestBlood(Map<String, dynamic> bloodBank) {
    // TODO: Implement blood request
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requesting blood from ${bloodBank['bankName']}...'),
        backgroundColor: const Color(0xFFFF416C),
      ),
    );
  }
}