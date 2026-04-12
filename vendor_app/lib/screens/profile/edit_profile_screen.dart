import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final HealthcareProviderService _providerService;
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  
  List<String> _selectedQualifications = [];
  List<String> _selectedLanguages = [];
  List<Map<String, dynamic>> _testsOffered = [];
  bool _isLoading = false;
  String _providerType = 'doctor';

  final List<String> _availableQualifications = [
    'MBBS', 'MD', 'MS', 'DNB', 'DM', 'MCh', 'BAMS', 'BHMS', 'BDS', 'MDS',
    'BPT', 'MPT', 'BSc Nursing', 'MSc Nursing', 'Diploma', 'Certificate'
  ];

  final List<String> _availableLanguages = [
    'Hindi', 'English', 'Bengali', 'Telugu', 'Marathi', 'Tamil', 'Gujarati',
    'Urdu', 'Kannada', 'Odia', 'Malayalam', 'Punjabi', 'Assamese'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize service based on user role
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _providerType = authProvider.currentUser?.role ?? 'doctor';
    _providerService = HealthcareProviderService(_providerType);
    
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _consultationFeeController.dispose();
    _experienceController.dispose();
    _aboutController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      setState(() {
        _specializationController.text = user.specialization ?? '';
        _consultationFeeController.text = user.consultationFee?.toString() ?? '';
        _experienceController.text = user.experience?.toString() ?? '';
        _aboutController.text = user.about ?? '';
        _licenseNumberController.text = user.licenseNumber ?? '';
        _selectedQualifications = List<String>.from(user.qualifications ?? []);
        _selectedLanguages = List<String>.from(user.languages ?? []);
      });
    }

    // Load tests offered for pathology providers
    if (_providerType == 'pathology') {
      try {
        final response = await _providerService.getProfile();
        if (response.success && response.data != null) {
          final testsOffered = response.data!['testsOffered'];
          if (testsOffered is List) {
            setState(() {
              _testsOffered = List<Map<String, dynamic>>.from(testsOffered);
            });
          }
        }
      } catch (e) {
        print('Error loading tests offered: $e');
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profileData = <String, dynamic>{};
      
      // Common fields for all provider types
      if (_aboutController.text.trim().isNotEmpty) {
        profileData['about'] = _aboutController.text.trim();
      }
      if (_licenseNumberController.text.trim().isNotEmpty) {
        profileData['licenseNumber'] = _licenseNumberController.text.trim();
      }
      if (_selectedLanguages.isNotEmpty) {
        profileData['languages'] = _selectedLanguages;
      }

      // Doctor and nurse specific fields
      if (_providerType == 'doctor' || _providerType == 'nurse') {
        if (_specializationController.text.trim().isNotEmpty) {
          profileData['specialization'] = _specializationController.text.trim();
        }
        if (_consultationFeeController.text.trim().isNotEmpty) {
          profileData['consultationFee'] = int.tryParse(_consultationFeeController.text.trim()) ?? 0;
        }
        if (_experienceController.text.trim().isNotEmpty) {
          profileData['experience'] = int.tryParse(_experienceController.text.trim()) ?? 0;
        }
        if (_selectedQualifications.isNotEmpty) {
          profileData['qualifications'] = _selectedQualifications;
        }
      }

      final response = await _providerService.updateProfile(profileData);

      if (response.success) {
        // Update tests offered for pathology providers
        if (_providerType == 'pathology' && _testsOffered.isNotEmpty) {
          await _providerService.updateTestsOffered(_testsOffered);
        }

        // Refresh the user profile in AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshProfile();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.error?.message ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${_providerType.toUpperCase()} Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor and Nurse specific fields
              if (_providerType == 'doctor' || _providerType == 'nurse') ...[
                // Specialization
                const Text(
                  'Specialization',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _specializationController,
                  decoration: InputDecoration(
                    hintText: _providerType == 'doctor' 
                        ? 'e.g., Cardiologist, General Physician'
                        : 'e.g., ICU Nurse, Pediatric Nurse',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your specialization';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Consultation Fee
                const Text(
                  'Consultation Fee (₹)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _consultationFeeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 500',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter consultation fee';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Experience
                const Text(
                  'Experience (Years)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 5',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter years of experience';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Qualifications
                const Text(
                  'Qualifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableQualifications.map((qualification) {
                    final isSelected = _selectedQualifications.contains(qualification);
                    return FilterChip(
                      label: Text(qualification),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedQualifications.add(qualification);
                          } else {
                            _selectedQualifications.remove(qualification);
                          }
                        });
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
              ],

              // License Number (for all provider types)
              const Text(
                'License Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseNumberController,
                decoration: InputDecoration(
                  hintText: '${_providerType} license number',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your license number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Languages
              const Text(
                'Languages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableLanguages.map((language) {
                  final isSelected = _selectedLanguages.contains(language);
                  return FilterChip(
                    label: Text(language),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLanguages.add(language);
                        } else {
                          _selectedLanguages.remove(language);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),

              // Pathology specific - Tests Offered
              if (_providerType == 'pathology') ...[
                const Text(
                  'Tests Offered',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._testsOffered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final test = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: test['name'] ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Test Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _testsOffered[index]['name'] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: test['price']?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price (₹)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _testsOffered[index]['price'] = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _testsOffered.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _testsOffered.add({'name': '', 'price': 0});
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // About
              const Text(
                'About',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _aboutController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell patients about yourself and your ${_providerType == 'pathology' ? 'lab services' : 'expertise'}...',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write something about yourself';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}