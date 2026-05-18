import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Purple theme for vendors)
  static const Color primary = Color(0xFF9C27B0); // Purple
  static const Color primaryDark = Color(0xFF7B1FA2);
  static const Color primaryLight = Color(0xFFE1BEE7);
  
  // Role-specific colors
  static const Color doctor = Color(0xFF2196F3); // Blue
  static const Color nurse = Color(0xFF4CAF50); // Green
  static const Color pharmacist = Color(0xFFFF9800); // Orange
  static const Color ambulance = Color(0xFFF44336); // Red
  static const Color bloodBank = Color(0xFFE91E63); // Pink
  static const Color pathology = Color(0xFF00BCD4); // Cyan
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient getRoleGradient(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'doctor':
        color = doctor;
        break;
      case 'nurse':
        color = nurse;
        break;
      case 'pharmacist':
        color = pharmacist;
        break;
      case 'ambulance':
        color = ambulance;
        break;
      case 'bloodbank':
        color = bloodBank;
        break;
      case 'pathology':
        color = pathology;
        break;
      default:
        color = primary;
    }
    
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'doctor':
        return doctor;
      case 'nurse':
        return nurse;
      case 'pharmacist':
        return pharmacist;
      case 'ambulance':
        return ambulance;
      case 'bloodbank':
        return bloodBank;
      case 'pathology':
        return pathology;
      default:
        return primary;
    }
  }
}
