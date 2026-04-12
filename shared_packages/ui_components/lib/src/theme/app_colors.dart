import 'package:flutter/material.dart';

/// App color scheme for OnMint healthcare platform
class AppColors {
  // Primary light blue theme colors
  static const Color primary = Color(0xFF2196F3); // Light Blue
  static const Color primaryLight = Color(0xFF64B5F6); // Lighter Blue
  static const Color primaryDark = Color(0xFF1976D2); // Darker Blue
  
  // Secondary colors
  static const Color secondary = Color(0xFF03DAC6); // Teal
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00695C);
  
  // Background colors
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBackground = Color(0xFFFAFAFA);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121); // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textHint = Color(0xFF9E9E9E); // Light Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White
  
  // Status colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Healthcare specific colors
  static const Color doctor = Color(0xFF1976D2); // Blue
  static const Color nurse = Color(0xFF9C27B0); // Purple
  static const Color pharmacist = Color(0xFF4CAF50); // Green
  static const Color ambulance = Color(0xFFF44336); // Red
  static const Color bloodbank = Color(0xFFE91E63); // Pink
  static const Color pathology = Color(0xFF795548); // Brown
  static const Color patient = Color(0xFF607D8B); // Blue Grey
  static const Color admin = Color(0xFF424242); // Dark Grey
  
  // Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0A000000);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Get role-specific color
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
        return bloodbank;
      case 'pathology':
        return pathology;
      case 'patient':
        return patient;
      case 'admin':
        return admin;
      default:
        return primary;
    }
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'approved':
        return success;
      case 'warning':
      case 'pending':
        return warning;
      case 'error':
      case 'failed':
      case 'rejected':
        return error;
      case 'info':
      case 'in_progress':
        return info;
      default:
        return textSecondary;
    }
  }
}