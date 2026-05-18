import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import '../config/app_config.dart';
import '../config/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Wait for splash screen duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check if we're in development mode
      if (AppConfig.developmentMode) {
        // Clear any existing auth data for testing if configured
        if (AppConfig.forceLogoutOnStart) {
          await authProvider.forceLogout();
        }
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // PRODUCTION AUTHENTICATION FLOW
      if (authProvider.isAuthenticated && authProvider.isAdmin) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Clear any invalid cached data
        if (authProvider.isAuthenticated && !authProvider.isAdmin) {
          await authProvider.logout();
        }
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
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
                  Icons.admin_panel_settings,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'OnMint Admin',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Platform Administration',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 48),
              
              const LoadingWidget(
                color: Colors.white,
              ),
              
              const SizedBox(height: 24),
              
              // Development mode indicator
              if (AppConfig.developmentMode)
                const Text(
                  'Development Mode',
                  style: TextStyle(
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
