import 'package:flutter/material.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({Key? key}) : super(key: key);

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
  late final PatientService _patientService;
  
  List<Map<String, dynamic>> _ambulances = [];
  String _selectedType = '';
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _ambulanceTypes = [
    {'id': '', 'name': 'All Types', 'icon': Icons.local_shipping},
    {'id': 'basic', 'name': 'Basic Life Support', 'icon': Icons.medical_services},
    {'id': 'advanced', 'name': 'Advanced Life Support', 'icon': Icons.emergency},
    {'id': 'patient_transport', 'name': 'Patient Transport', 'icon': Icons.accessible},
    {'id': 'cardiac', 'name': 'Cardiac Ambulance', 'icon': Icons.favorite},
    {'id': 'neonatal', 'name': 'Neonatal', 'icon': Icons.child_care},
    {'id': 'air', 'name': 'Air Ambulance', 'icon': Icons.flight},
    {'id': 'mortuary', 'name': 'Mortuary Van', 'icon': Icons.local_shipping},
  ];

  @override
  void initState() {
    super.initState();
    _patientService = PatientService();
    _loadAmbulances();
  }

  Future<void> _loadAmbulances() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _patientService.getNearbyServices(
        serviceType: 'ambulance',
        limit: 50,
      );

      if (response.success && response.data != null) {
        final ambulances = response.data!['ambulances'] ?? [];
        setState(() {
          _ambulances = List<Map<String, dynamic>>.from(ambulances);
        });
      }
    } catch (e) {
      print('Error loading ambulances: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance'),
        backgroundColor: const Color(0xFFFF9A9E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildEmergencySection(),
          _buildTypesSection(),
          Expanded(child: _buildAmbulancesList()),
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
          colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
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
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emergency, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Emergency Ambulance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Need immediate medical assistance? Call emergency ambulance now',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _callEmergency(),
                  icon: const Icon(Icons.call),
                  label: const Text('Call 108'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _bookEmergency(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Book Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ambulance Types',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _ambulanceTypes.length,
            itemBuilder: (context, index) {
              final type = _ambulanceTypes[index];
              final isSelected = _selectedType == type['id'];
              
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type['id']),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF9A9E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type['icon'],
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFFFF9A9E) : Colors.grey[700],
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

  Widget _buildAmbulancesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9A9E)));
    }

    if (_ambulances.isEmpty) {
      return const Center(
        child: Text('No ambulances available', style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _ambulances.length,
      itemBuilder: (context, index) {
        final ambulance = _ambulances[index];
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
                        color: const Color(0xFFFF9A9E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Color(0xFFFF9A9E),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ambulance['driverName'] ?? 'Ambulance Service',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            ambulance['vehicleType'] ?? 'Basic Life Support',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            'Vehicle: ${ambulance['vehicleNumber'] ?? 'N/A'}',
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
                        'Available',
                        style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (ambulance['equipmentAvailable'] != null) ...[
                  Text(
                    'Equipment Available:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (ambulance['equipmentAvailable'] as List).map((equipment) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          equipment.toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.blue),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Response Time',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Text(
                            '5-10 mins',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _bookAmbulance(ambulance),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9A9E)),
                      child: const Text('Book Now', style: TextStyle(color: Colors.white)),
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

  void _callEmergency() {
    // TODO: Implement emergency call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling emergency services...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _bookEmergency() {
    // TODO: Implement emergency booking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking emergency ambulance...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _bookAmbulance(Map<String, dynamic> ambulance) {
    // TODO: Implement ambulance booking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking ${ambulance['driverName']}...'),
        backgroundColor: const Color(0xFFFF9A9E),
      ),
    );
  }
}