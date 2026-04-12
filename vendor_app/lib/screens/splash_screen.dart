import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import '../config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Vendor Splash Screen: Initializing app...');
      
      // Initialize authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      print('🔍 Vendor Auth Status: isAuthenticated=${authProvider.isAuthenticated}');
      print('🔍 Vendor Auth Status: isVendor=${authProvider.isVendor}');
      print('🔍 Current User: ${authProvider.currentUser?.email ?? 'None'}');
      print('🔍 Current Token: ${authProvider.currentToken != null ? 'Present' : 'None'}');

      // Wait for splash screen duration
      await Future.delayed(const Duration(seconds: 2));

      // Check if we're in development mode
      if (AppConfig.developmentMode) {
        print('🔧 VENDOR DEVELOPMENT MODE: Always navigating to login for testing');
        if (mounted) {
          // Clear any existing auth data for testing if configured
          if (AppConfig.forceLogoutOnStart) {
            await authProvider.forceLogout();
          }
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      // PRODUCTION AUTHENTICATION FLOW
      if (mounted) {
        if (authProvider.isAuthenticated && authProvider.isVendor) {
          print('✅ Vendor is authenticated and is vendor, navigating to home');
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          print('❌ Vendor not authenticated or not vendor, navigating to login');
          // Clear any invalid cached data
          if (authProvider.isAuthenticated && !authProvider.isVendor) {
            print('🧹 Clearing cached data for non-vendor user');
            await authProvider.logout();
          }
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      print('💥 Vendor Splash Screen initialization error: $e');
      // Handle initialization error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.business,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'OnMint Vendor',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Healthcare Service Provider',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 48),
              
              const LoadingWidget(
                color: Colors.white,
                showMessage: false,
              ),
              
              const SizedBox(height: 24),
              
              // Development mode indicator
              Text(
                AppConfig.developmentMode 
                    ? 'Development Mode: Always Login'
                    : 'Production Mode',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}