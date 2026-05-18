class ApiConfig {
  static const String _baseUrlDev = 'http://localhost:5000/api/v1';
  static const String _baseUrlProd = 'https://your-production-api.com/api/v1';
  
  // Environment flag - set this based on your build configuration
  static const bool _isProduction = false; // Change to true for production builds
  
  static String get baseUrl => _isProduction ? _baseUrlProd : _baseUrlDev;
  
  // Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // API endpoints
  static const String authEndpoint = '/auth';
  static const String patientEndpoint = '/patient';
  static const String doctorEndpoint = '/doctor';
  static const String adminEndpoint = '/admin';
  static const String pharmacistEndpoint = '/pharmacist';
  static const String nurseEndpoint = '/nurse';
  static const String ambulanceEndpoint = '/ambulance';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}