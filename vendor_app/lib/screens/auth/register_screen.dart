import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Consultation types (for doctor and nurse)
  final List<String> _consultationTypes = [];
  
  // Profile picture
  XFile? _profilePicture;
  
  // Documents
  final Map<String, XFile?> _documents = {
    'license': null,
    'certificate': null,
    'idProof': null,
    'addressProof': null,
  };

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profilePicture = image;
        });
      }
    } catch (e) {
      ToastUtils.showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (file != null) {
        setState(() {
          _documents[documentType] = file;
        });
      }
    } catch (e) {
      ToastUtils.showError('Failed to pick document: ${e.toString()}');
    }
  }

  void _removeDocument(String documentType) {
    setState(() {
      _documents[documentType] = null;
    });
  }

  bool _validateDocuments() {
    // Check if required documents are uploaded
    final requiredDocs = ['license', 'certificate', 'idProof'];
    for (String doc in requiredDocs) {
      if (_documents[doc] == null) {
        ToastUtils.showError('Please upload ${_getDocumentDisplayName(doc)}');
        return false;
      }
    }
    return true;
  }

  String _getDocumentDisplayName(String docType) {
    switch (docType) {
      case 'license': return 'Professional License';
      case 'certificate': return 'Degree Certificate';
      case 'idProof': return 'ID Proof';
      case 'addressProof': return 'Address Proof';
      default: return docType;
    }
  }
  
  Widget _buildConsultationTypesSelector() {
    return Column(
      children: [
        CheckboxListTile(
          title: Row(
            children: [
              Icon(Icons.videocam, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              const Text('Video Call Consultation'),
            ],
          ),
          subtitle: const Text('Online consultation via video call'),
          value: _consultationTypes.contains('video-call'),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _consultationTypes.add('video-call');
              } else {
                _consultationTypes.remove('video-call');
              }
            });
          },
          activeColor: Colors.blue,
        ),
        CheckboxListTile(
          title: Row(
            children: [
              Icon(Icons.person, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              const Text('In-Person Visit'),
            ],
          ),
          subtitle: const Text('Patient visits your clinic/location'),
          value: _consultationTypes.contains('in-person'),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _consultationTypes.add('in-person');
              } else {
                _consultationTypes.remove('in-person');
              }
            });
          },
          activeColor: Colors.green,
        ),
        CheckboxListTile(
          title: Row(
            children: [
              Icon(Icons.phone, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              const Text('Phone Call Consultation'),
            ],
          ),
          subtitle: const Text('Consultation via phone call'),
          value: _consultationTypes.contains('phone-call'),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _consultationTypes.add('phone-call');
              } else {
                _consultationTypes.remove('phone-call');
              }
            });
          },
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ToastUtils.showError('Please select your role');
      return;
    }
    
    // Validate consultation types for doctor and nurse
    if ((_selectedRole == 'doctor' || _selectedRole == 'nurse') && _consultationTypes.isEmpty) {
      ToastUtils.showError('Please select at least one consultation type');
      return;
    }

    if (!_validateDocuments()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Prepare registration data
      final Map<String, dynamic> registrationData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole!,
      };
      
      // Add consultation types for doctor and nurse
      if ((_selectedRole == 'doctor' || _selectedRole == 'nurse') && _consultationTypes.isNotEmpty) {
        registrationData['consultationTypes'] = _consultationTypes;
      }

      // Note: File upload for registration not yet implemented in backend
      // For now, just register with basic data
      final success = await authProvider.register(registrationData);

      if (!success) {
        if (mounted) {
          ToastUtils.showError(authProvider.error ?? 'Registration failed');
        }
        return;
      }

      if (mounted) {
        ToastUtils.showSuccess('Registration successful! Please wait for admin approval.');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError('Registration failed: ${e.toString()}');
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
        title: const Text('Register as Provider'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Role Selection
                const Text(
                  'Select Your Role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: AppConfig.vendorRoles.map((role) {
                    final isSelected = _selectedRole == role;
                    final color = AppColors.getRoleColor(role);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRole = role);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppConfig.getRoleIcon(role),
                              color: isSelected ? Colors.white : color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppConfig.getRoleDisplayName(role),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Consultation Types (for doctor and nurse only)
                if (_selectedRole == 'doctor' || _selectedRole == 'nurse') ...[
                  const Text(
                    'Consultation Types Offered',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Select the types of consultations you offer (select at least one)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildConsultationTypesSelector(),
                  
                  const SizedBox(height: 32),
                ],
                
                // Personal Information
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        hint: 'Enter first name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        hint: 'Enter last name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      return 'Phone number must be 10 digits';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Security
                const Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Profile Picture Section
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildProfilePictureSection(),
                
                const SizedBox(height: 32),
                
                // Documents Section
                const Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Please upload clear photos of the following documents:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildDocumentsSection(),
                
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: 'Register',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.info),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: AppColors.info, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your account will be reviewed by admin before activation',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickProfilePicture,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            image: _profilePicture != null
                ? DecorationImage(
                    image: FileImage(File(_profilePicture!.path)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profilePicture == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      children: [
        _buildDocumentItem('license', 'Professional License', Icons.card_membership, true),
        const SizedBox(height: 16),
        _buildDocumentItem('certificate', 'Degree Certificate', Icons.school, true),
        const SizedBox(height: 16),
        _buildDocumentItem('idProof', 'ID Proof (Aadhar/PAN)', Icons.credit_card, true),
        const SizedBox(height: 16),
        _buildDocumentItem('addressProof', 'Address Proof', Icons.home, false),
      ],
    );
  }

  Widget _buildDocumentItem(String docType, String title, IconData icon, bool required) {
    final hasDocument = _documents[docType] != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasDocument ? AppColors.success : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasDocument ? AppColors.success.withOpacity(0.05) : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasDocument ? AppColors.success : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasDocument ? Icons.check : icon,
              color: hasDocument ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (required)
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                if (hasDocument)
                  const Text(
                    'Document uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                  )
                else
                  Text(
                    required ? 'Required document' : 'Optional document',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (hasDocument)
            IconButton(
              onPressed: () => _removeDocument(docType),
              icon: const Icon(Icons.close, color: Colors.red),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _pickDocument(docType),
              icon: const Icon(Icons.upload, size: 16),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }
}
