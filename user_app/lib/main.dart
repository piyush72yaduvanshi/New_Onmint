import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:location_service/location_service.dart';
import 'package:ui_components/ui_components.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/bookings/bookings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/booking/book_appointment_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/services/doctors_screen.dart';
import 'screens/services/nurses_screen.dart';
import 'screens/services/pathology_screen.dart';
import 'screens/services/ambulance_screen.dart';
import 'screens/services/bloodbank_screen.dart';

void main() {
  runApp(const OnMintUserApp());
}

class OnMintUserApp extends StatelessWidget {
  const OnMintUserApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'OnMint - User App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/services':
              return MaterialPageRoute(builder: (_) => const ServicesScreen());
            case '/bookings':
              return MaterialPageRoute(builder: (_) => const BookingsScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/notifications':
              return MaterialPageRoute(builder: (_) => const NotificationsScreen());
            case '/doctors':
              return MaterialPageRoute(builder: (_) => const DoctorsScreen());
            case '/nurses':
              return MaterialPageRoute(builder: (_) => const NursesScreen());
            case '/pathology':
              return MaterialPageRoute(builder: (_) => const PathologyScreen());
            case '/ambulance':
              return MaterialPageRoute(builder: (_) => const AmbulanceScreen());
            case '/bloodbank':
              return MaterialPageRoute(builder: (_) => const BloodbankScreen());
            case '/book-appointment':
              final doctor = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => BookAppointmentScreen(doctor: doctor),
              );
            default:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
          }
        },
      ),
    );
  }
}