import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:location_service/location_service.dart';
import 'package:ui_components/ui_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _specializationController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  LocationPoint? _currentLocation;
  String _selectedRole = 'doctor';
  List<String> _selectedLanguages = [];

  final List<String> _vendorRoles = [
    'doctor',
    'pharmacist', 
    'nurse',
    'ambulance',
    'bloodbank',
    'pathology',
  ];

  final List<String> _languages = [
    'English',
    'Hindi',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Urdu',
    'Kannada',
    'Malayalam',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _specializationController.dispose();
    _qualificationsController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final location = await locationProvider.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required. Please enable location services.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Create role-specific registration request
    RegistrationRequest registrationRequest;
    
    switch (_selectedRole) {
      case 'doctor':
        registrationRequest = RegistrationRequest.doctor(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: FormValidators.cleanPhoneNumber(_phoneController.text),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          location: _currentLocation!,
          specialization: _specializationController.text.trim(),
          qualifications: _qualificationsController.text.trim().split(',').map((e) => e.trim()).toList(),
          experience: int.tryParse(_experienceController.text) ?? 0,
          consultationFee: double.tryParse(_consultationFeeController.text) ?? 0,
          licenseNumber: _licenseNumberController.text.trim(),
          languages: _selectedLanguages,
          about: 'Experienced ${_specializationController.text.trim()} with ${_experienceController.text} years of experience.',
          availability: [
            {
              "day": "MONDAY",
              "slots": [
                {"startTime": "09:00", "endTime": "12:00", "isAvailable": true},
                {"startTime": "17:00", "endTime": "20:00", "isAvailable": true}
              ]
            },
            {
              "day": "WEDNESDAY", 
              "slots": [
                {"startTime": "09:00", "endTime": "12:00", "isAvailable": true}
              ]
            },
            {
              "day": "FRIDAY",
              "slots": [
                {"startTime": "17:00", "endTime": "20:00", "isAvailable": true}
              ]
            }
          ],
        );
        break;
      case 'pharmacist':
        registrationRequest = RegistrationRequest.pharmacist(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: FormValidators.cleanPhoneNumber(_phoneController.text),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          location: _currentLocation!,
          pharmacyName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()} Pharmacy',
          licenseNumber: _licenseNumberController.text.trim(),
          deliveryTimes: ["30min", "1hr", "same_day"],
          minimumOrderAmount: 99,
          deliveryFee: 50,
          operatingHours: {"open": "08:00", "close": "22:00"},
        );
        break;
      case 'bloodbank':
        registrationRequest = RegistrationRequest.bloodbank(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: FormValidators.cleanPhoneNumber(_phoneController.text),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          location: _currentLocation!,
          bankName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()} Blood Bank',
          licenseNumber: _licenseNumberController.text.trim(),
          bloodStock: [
            {"bloodGroup": "A+", "unitsAvailable": 25},
            {"bloodGroup": "B+", "unitsAvailable": 18},
            {"bloodGroup": "O+", "unitsAvailable": 30},
            {"bloodGroup": "AB+", "unitsAvailable": 10}
          ],
          emergencyContact: FormValidators.cleanPhoneNumber(_phoneController.text),
          operatingHours: {"open": "00:00", "close": "23:59"},
        );
        break;
      case 'ambulance':
        registrationRequest = RegistrationRequest.ambulance(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: FormValidators.cleanPhoneNumber(_phoneController.text),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          location: _currentLocation!,
          driverName: '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          driverLicense: _licenseNumberController.text.trim(),
          vehicleNumber: 'VH-${_pincodeController.text.trim()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          vehicleType: 'Advanced Life Support',
          equipmentAvailable: ["Oxygen Cylinder", "ECG Monitor", "Defibrillator", "First Aid Kit", "Ventilator"],
          isAvailable: true,
          currentLocation: _currentLocation!,
        );
        break;
      default:
        // For other roles like nurse, pathology, etc.
        registrationRequest = RegistrationRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: FormValidators.cleanPhoneNumber(_phoneController.text),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          role: _selectedRole,
          location: _currentLocation!,
          additionalFields: {
            'licenseNumber': _licenseNumberController.text.trim(),
            'specialization': _specializationController.text.trim(),
            'experience': int.tryParse(_experienceController.text) ?? 1, // Default to 1 year if not provided
          },
        );
    }

    final success = await authProvider.register(registrationRequest.toJson());

    if (mounted) {
      if (success) {
        print('🎉 Registration successful!');
        print('👤 Current user: ${authProvider.currentUser?.email}');
        print('🔍 User role: ${authProvider.currentUser?.role}');
        print('🔍 Is vendor: ${authProvider.isVendor}');
        
        // Always navigate to home after successful registration
        // The backend has created the user, so we trust the registration was successful
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Join as Provider',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your healthcare provider account',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Role Selection
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Provider Type',
                      prefixIcon: Icon(Icons.work_outlined),
                    ),
                    items: _vendorRoles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(RoleUtils.getRoleDisplayName(role)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Personal Information
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => FormValidators.validateName(value, fieldName: 'First name'),
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) => FormValidators.validateName(value, fieldName: 'Last name'),
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Icon(Icons.person_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: FormValidators.validatePhone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Information
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          textCapitalization: TextCapitalization.words,
                          validator: FormValidators.validateCity,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          textCapitalization: TextCapitalization.words,
                          validator: FormValidators.validateState,
                          decoration: const InputDecoration(
                            labelText: 'State',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validatePincode,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                    ),
                  ),
                  
                  // Role-specific fields
                  if (_selectedRole == 'doctor') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _specializationController,
                      validator: FormValidators.validateSpecialization,
                      decoration: const InputDecoration(
                        labelText: 'Specialization',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                        hintText: 'e.g., Cardiologist, Dermatologist',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _qualificationsController,
                      validator: FormValidators.validateQualifications,
                      decoration: const InputDecoration(
                        labelText: 'Qualifications',
                        prefixIcon: Icon(Icons.school_outlined),
                        hintText: 'MBBS, MD (Cardiology), DNB (Cardiology)',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            validator: FormValidators.validateExperience,
                            decoration: const InputDecoration(
                              labelText: 'Experience (Years)',
                              prefixIcon: Icon(Icons.timeline_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _consultationFeeController,
                            keyboardType: TextInputType.number,
                            validator: FormValidators.validateConsultationFee,
                            decoration: const InputDecoration(
                              labelText: 'Consultation Fee (₹)',
                              prefixIcon: Icon(Icons.currency_rupee_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseNumberController,
                      validator: FormValidators.validateLicenseNumber,
                      decoration: const InputDecoration(
                        labelText: 'Medical License Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'DOC-XX-YYYY-NNNNN',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Languages
                    const Text(
                      'Languages Spoken',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _languages.map((language) {
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
                        );
                      }).toList(),
                    ),
                  ] else if (_selectedRole == 'pharmacist') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Pharmacy Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseNumberController,
                      validator: FormValidators.validateLicenseNumber,
                      decoration: const InputDecoration(
                        labelText: 'Pharmacy License Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'PHARM-XX-YYYY-NNNNN',
                      ),
                    ),
                  ] else if (_selectedRole == 'bloodbank') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Blood Bank Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseNumberController,
                      validator: FormValidators.validateLicenseNumber,
                      decoration: const InputDecoration(
                        labelText: 'Blood Bank License Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'BB-XX-YYYY-NNN',
                      ),
                    ),
                  ] else if (_selectedRole == 'ambulance') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Ambulance Service Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseNumberController,
                      validator: FormValidators.validateLicenseNumber,
                      decoration: const InputDecoration(
                        labelText: 'Driver License Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: 'DL-NNNNNNNNNNNN',
                      ),
                    ),
                  ] else ...[
                    // For other roles (nurse, pathology, etc.)
                    const SizedBox(height: 24),
                    const Text(
                      'Professional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _specializationController,
                      decoration: const InputDecoration(
                        labelText: 'Specialization (Optional)',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      validator: FormValidators.validateExperience,
                      decoration: const InputDecoration(
                        labelText: 'Experience (Years)',
                        prefixIcon: Icon(Icons.timeline_outlined),
                        hintText: 'Enter years of experience',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _licenseNumberController,
                      validator: FormValidators.validateLicenseNumber,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Location Status
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _currentLocation != null ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentLocation != null ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentLocation != null ? Icons.location_on : Icons.location_off,
                              color: _currentLocation != null ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentLocation != null 
                                    ? 'Location detected successfully'
                                    : 'Location required for registration',
                                style: TextStyle(
                                  color: _currentLocation != null ? AppColors.success : AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_currentLocation == null)
                              TextButton(
                                onPressed: _getCurrentLocation,
                                child: const Text('Enable'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: FormValidators.validatePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => FormValidators.validateConfirmPassword(value, _passwordController.text),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: authProvider.isLoading
                            ? const SmallLoadingWidget()
                            : const Text('Create Account'),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}