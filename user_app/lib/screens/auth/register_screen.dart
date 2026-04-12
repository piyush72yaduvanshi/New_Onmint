import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:location_service/location_service.dart' as location;
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
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  location.LocationPoint? _currentLocation;

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
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = Provider.of<location.LocationProvider>(context, listen: false);
    final locationResult = await locationProvider.getCurrentLocation();
    if (locationResult != null) {
      setState(() {
        _currentLocation = locationResult;
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
    
    final registrationData = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'phone': FormValidators.cleanPhoneNumber(_phoneController.text),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
      'role': 'patient',
      'location': _currentLocation!.toJson(),
    };

    print('🚀 Attempting registration with data: $registrationData');

    final success = await authProvider.register(registrationData);

    if (mounted) {
      if (success) {
        print('🎉 Registration successful, navigating to home');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        final errorMessage = authProvider.error ?? 'Registration failed';
        print('💔 Registration failed: $errorMessage');
        
        // Show detailed error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registration Failed'),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  // Header
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Join OnMint',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your patient account',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
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
                  
                  // Email
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
                  
                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: FormValidators.validatePhone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '9876543210',
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
                  
                  // Pincode
                  TextFormField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    validator: FormValidators.validatePincode,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                      hintText: '400001',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Status
                  Consumer<location.LocationProvider>(
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
                  
                  // Confirm Password
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
                  
                  // Register Button
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
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
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