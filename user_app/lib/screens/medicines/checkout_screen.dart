import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:api_client/api_client.dart';
import '../../services/cart_service.dart';
import '../../utils/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _notesController = TextEditingController();
  final _apiClient = OnMintApiClient();
  
  String? _selectedState;
  String? _selectedCity;
  String _paymentMethod = 'cash';
  bool _useRegisteredAddress = false;
  bool _isLoading = false;

  // Indian States
  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
    'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
    'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi', 'Jammu and Kashmir',
  ];

  // Cities by state (sample - add more as needed)
  final Map<String, List<String>> _citiesByState = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Thane', 'Kolhapur'],
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Karol Bagh', 'Connaught Place'],
    'Karnataka': ['Bangalore', 'Mysore', 'Mangalore', 'Hubli', 'Belgaum'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut', 'Noida'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
  };

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user?.address != null) {
      setState(() {
        _streetController.text = user!.address!.street ?? '';
        _selectedCity = user.address!.city;
        _selectedState = user.address!.state;
        _pincodeController.text = user.address!.pincode ?? '';
      });
    }
  }

  void _toggleUseRegisteredAddress(bool? value) {
    if (value == true) {
      _loadUserAddress();
    } else {
      _streetController.clear();
      _pincodeController.clear();
      setState(() {
        _selectedCity = null;
        _selectedState = null;
      });
    }
    setState(() {
      _useRegisteredAddress = value ?? false;
    });
  }

  Future<void> _placeOrder() async {
    if (!_useRegisteredAddress && !_formKey.currentState!.validate()) {
      return;
    }

    if (!_useRegisteredAddress && (_selectedState == null || _selectedCity == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select state and city')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cart = Provider.of<CartService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      await _apiClient.initialize();

      // Build medicines array with details
      final items = cart.items.values.toList();
      
      // Build medicines array for API (only medicineId and quantity)
      final medicines = items.map((item) => {
        'medicineId': item.medicineId,
        'quantity': item.quantity,
      }).toList();
      
      // Build description from cart items
      final medicineList = items.map((item) => '${item.name} (${item.quantity}x)').join(', ');
      
      // Use registered address or form address
      String address;
      List<double> coordinates;
      
      if (_useRegisteredAddress && user?.address != null) {
        address = '${user!.address!.street}, ${user.address!.city}, ${user.address!.state} - ${user.address!.pincode}';
        // Use user's location coordinates if available
        coordinates = user.location?.coordinates ?? [0.0, 0.0];
      } else {
        address = '${_streetController.text}, $_selectedCity, $_selectedState - ${_pincodeController.text}';
        // Default coordinates (will be updated by backend if needed)
        coordinates = [0.0, 0.0];
      }

      final orderData = {
        'serviceType': 'pharmacist',
        'description': 'Medicine order: $medicineList. Total: ₹${cart.totalAmount.toStringAsFixed(2)}',
        'medicines': medicines, // Send medicines array with medicineId and quantity
        'address': address,
        'coordinates': coordinates,
        'urgency': 'medium',
        'isEmergency': false,
        'notes': _notesController.text.isEmpty 
          ? 'Payment method: $_paymentMethod. ${cart.totalQuantity} items ordered.'
          : _notesController.text,
      };

      await _apiClient.patient.createRealtimeBooking(orderData);

      cart.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! Nearby pharmacists will be notified.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
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
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.pharmacy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Items:'),
                                Text('${cart.totalQuantity}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${cart.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pharmacy,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Use Registered Address Checkbox
                    CheckboxListTile(
                      title: const Text('Use my registered address'),
                      value: _useRegisteredAddress,
                      onChanged: _toggleUseRegisteredAddress,
                      activeColor: AppColors.pharmacy,
                    ),
                    const SizedBox(height: 16),

                    // Show address form only if not using registered address
                    if (!_useRegisteredAddress) ...[
                      // Delivery Address
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Street Address
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter street address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // State Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedState,
                        decoration: const InputDecoration(
                          labelText: 'State *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: _states.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedCity = null; // Reset city when state changes
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a state';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // City Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        items: _selectedState != null && _citiesByState.containsKey(_selectedState)
                            ? _citiesByState[_selectedState]!.map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList()
                            : [],
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pincode
                      TextFormField(
                        controller: _pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pin_drop),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pincode';
                          }
                          if (value.length != 6) {
                            return 'Pincode must be 6 digits';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Show registered address
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Using Registered Address',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(_streetController.text),
                              Text('$_selectedCity, $_selectedState - ${_pincodeController.text}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'cash',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.pharmacy,
                    ),
                    RadioListTile<String>(
                      title: const Text('Online Payment'),
                      value: 'online',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _paymentMethod = value!;
                        });
                      },
                      activeColor: AppColors.pharmacy,
                    ),
                    const SizedBox(height: 24),

                    // Delivery Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Instructions (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: 'e.g., Call before delivery',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Place Order Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pharmacy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Place Order',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
