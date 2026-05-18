import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00BCD4); // Cyan
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF4DD0E1);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF009688); // Teal
  static const Color secondaryDark = Color(0xFF00796B);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Service Colors
  static const Color doctor = Color(0xFF2196F3);
  static const Color nurse = Color(0xFF9C27B0);
  static const Color ambulance = Color(0xFFF44336);
  static const Color pharmacy = Color(0xFF4CAF50);
  static const Color bloodbank = Color(0xFFE91E63);
  static const Color pathology = Color(0xFF00BCD4);
  static const Color pharmacist = Color(0xFF4CAF50);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
  );
  
  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
  );
}
