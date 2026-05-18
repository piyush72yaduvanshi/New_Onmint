import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_client/api_client.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';

class BloodRequestScreen extends StatefulWidget {
  final Map<String, dynamic> bloodBank;

  const BloodRequestScreen({
    super.key,
    required this.bloodBank,
  });

  @override
  State<BloodRequestScreen> createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _apiClient = OnMintApiClient();
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _patientAgeController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _addressController = TextEditingController();
  final _reasonController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  
  String? _selectedBloodGroup;
  String _urgency = 'Normal';
  bool _isLoading = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _urgencyLevels = ['Normal', 'Urgent', 'Emergency'];

  @override
  void dispose() {
    _patientNameController.dispose();
    _patientAgeController.dispose();
    _hospitalController.dispose();
    _addressController.dispose();
    _reasonController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBloodGroup == null) {
      ToastUtils.showError('Please select blood group');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final requestData = {
        'bloodBank': widget.bloodBank['_id'],
        'bloodGroup': _selectedBloodGroup,
        'units': int.parse(_unitsController.text),
        'patientName': _patientNameController.text,
        'patientAge': int.parse(_patientAgeController.text),
        'hospital': _hospitalController.text,
        'address': _addressController.text,
        'reason': _reasonController.text,
        'urgency': _urgency.toLowerCase(),
      };

      final booking = await _apiClient.patient.createBloodRequest(requestData);

      if (mounted) {
        _showSuccessDialog(booking);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(dynamic request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Request Submitted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ID: ${request['_id']}'),
            const SizedBox(height: 8),
            const Text(
              'Your blood request has been submitted. The blood bank will contact you shortly.',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to blood bank detail
              Navigator.of(context).pop(); // Go back to blood banks list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloodStock = widget.bloodBank['bloodStock'] ?? {};
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blood Bank Info Card
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.red.shade700, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.bloodBank['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.bloodBank['phone'] != null)
                              Text(
                                widget.bloodBank['phone'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
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

              // Blood Group Selection
              const Text(
                'Select Blood Group *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _bloodGroups.length,
                itemBuilder: (context, index) {
                  final group = _bloodGroups[index];
                  final isSelected = _selectedBloodGroup == group;
                  final units = bloodStock[group] ?? 0;
                  final isAvailable = units > 0;
                  
                  return InkWell(
                    onTap: isAvailable
                        ? () => setState(() => _selectedBloodGroup = group)
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.red.shade700
                            : isAvailable
                                ? Colors.white
                                : Colors.grey.shade200,
                        border: Border.all(
                          color: isSelected
                              ? Colors.red.shade700
                              : isAvailable
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            group,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.white
                                  : isAvailable
                                      ? Colors.black87
                                      : Colors.grey,
                            ),
                          ),
                          Text(
                            '$units units',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Units Required
              const Text(
                'Units Required *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Units Required',
                controller: _unitsController,
                hint: 'Number of units',
                prefixIcon: Icons.water_drop,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter units required';
                  }
                  final units = int.tryParse(value);
                  if (units == null || units < 1) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Urgency Level
              const Text(
                'Urgency Level *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _urgencyLevels.map((level) {
                  final isSelected = _urgency == level;
                  Color color = Colors.grey;
                  if (level == 'Urgent') color = Colors.orange;
                  if (level == 'Emergency') color = Colors.red;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _urgency = level),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            border: Border.all(color: color),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            level,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Patient Details
              const Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _patientNameController,
                label: 'Patient Name',
                hint: 'Enter patient name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _patientAgeController,
                label: 'Patient Age',
                hint: 'Enter patient age',
                prefixIcon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _hospitalController,
                label: 'Hospital Name',
                hint: 'Enter hospital name',
                prefixIcon: Icons.local_hospital,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Hospital Address',
                hint: 'Enter complete hospital address',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _reasonController,
                label: 'Reason for Requirement',
                hint: 'Brief reason for blood requirement',
                prefixIcon: Icons.note,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: 'Submit Request',
                onPressed: _isLoading ? null : _submitRequest,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
