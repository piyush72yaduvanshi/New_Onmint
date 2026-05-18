import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:api_client/api_client.dart';

import 'config/app_config.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(const OnMintAdminApp());
}

class OnMintAdminApp extends StatelessWidget {
  const OnMintAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = OnMintApiClient();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        Provider.value(value: apiClient),
      ],
      child: MaterialApp(
        title: 'OnMint - Admin App',
        theme: AppConfig.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}