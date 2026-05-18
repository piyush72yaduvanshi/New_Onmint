import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class AmbulancesScreen extends StatefulWidget {
  const AmbulancesScreen({super.key});

  @override
  State<AmbulancesScreen> createState() => _AmbulancesScreenState();
}

class _AmbulancesScreenState extends State<AmbulancesScreen> {
  final _apiClient = OnMintApiClient();
  List<User> _ambulances = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadAmbulances();
  }

  Future<void> _loadAmbulances() async {
    setState(() => _isLoading = true);
    
    try {
      await _apiClient.initialize();
      final result = await _apiClient.admin.getAllAmbulances(
        page: _currentPage,
        limit: 20,
      );
      
      setState(() {
        _ambulances = (result['ambulances'] as List?)
            ?.map((e) => User.fromJson(e))
            .toList() ?? [];
        _totalPages = result['totalPages'] ?? 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastUtils.showError('Failed to load ambulances');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Management'),
        backgroundColor: AppColors.ambulance,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAmbulanceForm(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAmbulances,
        child: _isLoading
            ? const LoadingWidget(message: 'Loading ambulances...')
            : _ambulances.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.local_hospital,
                    title: 'No Ambulances Found',
                    message: 'Add ambulances to get started',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _ambulances.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _ambulances.length) {
                        return _buildPagination();
                      }
                      final ambulance = _ambulances[index];
                      return _buildAmbulanceCard(ambulance);
                    },
                  ),
      ),
    );
  }

  Widget _buildAmbulanceCard(User ambulance) {
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
                    color: AppColors.ambulance.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital, color: AppColors.ambulance, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ambulance.vehicleNumber ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ambulance.vehicleType ?? 'Standard Ambulance',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (ambulance.isAvailable ?? false)
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (ambulance.isAvailable ?? false) ? 'AVAILABLE' : 'BUSY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: (ambulance.isAvailable ?? false) ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Driver: ${ambulance.driverName ?? "N/A"}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('License: ${ambulance.driverLicense ?? "N/A"}'),
              ],
            ),
            if (ambulance.equipmentAvailable != null && ambulance.equipmentAvailable!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Equipment:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ambulance.equipmentAvailable!.map((equipment) {
                  return Chip(
                    label: Text(equipment),
                    backgroundColor: AppColors.ambulance.withOpacity(0.1),
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showAmbulanceForm(ambulance: ambulance),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteAmbulance(ambulance),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
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
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadAmbulances();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page $_currentPage of $_totalPages'),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadAmbulances();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _showAmbulanceForm({User? ambulance}) {
    final isEdit = ambulance != null;
    
    // User fields
    final emailController = TextEditingController(text: ambulance?.email);
    final passwordController = TextEditingController();
    final firstNameController = TextEditingController(text: ambulance?.firstName);
    final lastNameController = TextEditingController(text: ambulance?.lastName);
    final phoneController = TextEditingController(text: ambulance?.phone);
    final cityController = TextEditingController(text: ambulance?.city);
    final stateController = TextEditingController(text: ambulance?.state);
    final pincodeController = TextEditingController(text: ambulance?.pincode);
    
    // Ambulance specific fields
    final driverNameController = TextEditingController(text: ambulance?.driverName);
    final driverLicenseController = TextEditingController(text: ambulance?.driverLicense);
    final vehicleNumberController = TextEditingController(text: ambulance?.vehicleNumber);
    String vehicleType = ambulance?.vehicleType ?? 'Basic';
    final equipmentController = TextEditingController(
      text: ambulance?.equipmentAvailable?.join(', '),
    );
    bool isAvailable = ambulance?.isAvailable ?? true;

    // Valid vehicle types from backend
    final vehicleTypes = ['Basic', 'Advanced Life Support', 'ICU Ambulance'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Ambulance' : 'Add Ambulance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Information Section
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isEdit, // Email cannot be changed
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    hintText: 'ambulance@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                
                if (!isEdit)
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      border: OutlineInputBorder(),
                      hintText: 'Minimum 6 characters',
                    ),
                  ),
                if (!isEdit) const SizedBox(height: 12),
                
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                    hintText: '9876543210',
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cityController,
                        decoration: const InputDecoration(
                          labelText: 'City *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: stateController,
                        decoration: const InputDecoration(
                          labelText: 'State *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Pincode *',
                    border: OutlineInputBorder(),
                    hintText: '110001',
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Ambulance Information Section
                const Text(
                  'Ambulance Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number *',
                    border: OutlineInputBorder(),
                    hintText: 'DL-01-AB-1234',
                  ),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type *',
                    border: OutlineInputBorder(),
                  ),
                  items: vehicleTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => vehicleType = value!);
                  },
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: driverNameController,
                  decoration: const InputDecoration(
                    labelText: 'Driver Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: driverLicenseController,
                  decoration: const InputDecoration(
                    labelText: 'Driver License *',
                    border: OutlineInputBorder(),
                    hintText: 'DL-1234567890',
                  ),
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: equipmentController,
                  decoration: const InputDecoration(
                    labelText: 'Equipment (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'Oxygen, Defibrillator, Stretcher',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (value) {
                    setDialogState(() => isAvailable = value);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate required fields
                if (vehicleNumberController.text.trim().isEmpty ||
                    driverNameController.text.trim().isEmpty ||
                    driverLicenseController.text.trim().isEmpty ||
                    firstNameController.text.trim().isEmpty ||
                    lastNameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty ||
                    stateController.text.trim().isEmpty ||
                    pincodeController.text.trim().isEmpty) {
                  ToastUtils.showError('Please fill all required fields');
                  return;
                }
                
                if (!isEdit && emailController.text.trim().isEmpty) {
                  ToastUtils.showError('Email is required');
                  return;
                }
                
                // Validate email format
                if (!isEdit && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
                  ToastUtils.showError('Please enter a valid email address');
                  return;
                }
                
                if (!isEdit && passwordController.text.trim().length < 6) {
                  ToastUtils.showError('Password must be at least 6 characters');
                  return;
                }
                
                // Validate phone number (10 digits starting with 6-9)
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phoneController.text.trim())) {
                  ToastUtils.showError('Phone number must be 10 digits starting with 6-9');
                  return;
                }
                
                // Validate pincode (6 digits)
                if (!RegExp(r'^\d{6}$').hasMatch(pincodeController.text.trim())) {
                  ToastUtils.showError('Pincode must be 6 digits');
                  return;
                }

                Navigator.pop(context);

                final equipment = equipmentController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final data = {
                  // User fields
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'city': cityController.text.trim(),
                  'state': stateController.text.trim(),
                  'pincode': pincodeController.text.trim(),
                  'location': {
                    'type': 'Point',
                    'coordinates': [77.1025, 28.7041], // Default Delhi coordinates
                  },
                  // Ambulance specific fields
                  'vehicleNumber': vehicleNumberController.text.trim(),
                  'vehicleType': vehicleType,
                  'driverName': driverNameController.text.trim(),
                  'driverLicense': driverLicenseController.text.trim(),
                  'equipmentAvailable': equipment,
                  'isAvailable': isAvailable,
                  'currentLocation': {
                    'type': 'Point',
                    'coordinates': [77.1025, 28.7041], // Default Delhi coordinates
                  },
                };
                
                // Add email and password only for new ambulances
                if (!isEdit) {
                  data['email'] = emailController.text.trim();
                  data['password'] = passwordController.text.trim();
                  data['role'] = 'ambulance';
                }

                try {
                  if (isEdit) {
                    await _apiClient.admin.updateAmbulance(ambulance.id, data);
                    ToastUtils.showSuccess('Ambulance updated successfully');
                  } else {
                    await _apiClient.admin.createAmbulance(data);
                    ToastUtils.showSuccess('Ambulance added successfully');
                  }
                  _loadAmbulances();
                } catch (e) {
                  ToastUtils.showError(
                    isEdit ? 'Failed to update ambulance: ${e.toString()}' : 'Failed to add ambulance: ${e.toString()}',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ambulance,
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAmbulance(User ambulance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ambulance'),
        content: Text('Are you sure you want to delete ${ambulance.vehicleNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await _apiClient.admin.deleteAmbulance(ambulance.id);
                ToastUtils.showSuccess('Ambulance deleted successfully');
                _loadAmbulances();
              } catch (e) {
                ToastUtils.showError('Failed to delete ambulance');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
