import 'package:connectivity_plus/connectivity_plus.dart';
import '../api_error.dart';

/// Connectivity interceptor for checking network status
class ConnectivityInterceptor {
  final Connectivity _connectivity = Connectivity();

  /// Check network connectivity before making requests
  Future<void> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        throw ApiException.network(
          'No internet connection. Please check your network settings.',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      
      // If connectivity check fails, proceed anyway
      // This prevents blocking requests when connectivity plugin has issues
      print('Connectivity check failed: $e');
    }
  }

  /// Get connectivity stream for monitoring network changes
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Check if currently connected
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      // Return true if check fails to avoid blocking
      return true;
    }
  }
}