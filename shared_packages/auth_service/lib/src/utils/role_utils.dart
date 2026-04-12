/// Utility functions for role-based operations
class RoleUtils {
  /// All available user roles
  static const List<String> allRoles = [
    'patient',
    'doctor',
    'pharmacist',
    'nurse',
    'ambulance',
    'bloodbank',
    'pathology',
    'admin',
  ];

  /// Vendor roles (healthcare service providers)
  static const List<String> vendorRoles = [
    'doctor',
    'pharmacist',
    'nurse',
    'ambulance',
    'bloodbank',
    'pathology',
  ];

  /// Check if role is a vendor role
  static bool isVendorRole(String role) {
    return vendorRoles.contains(role.toLowerCase());
  }

  /// Check if role is patient
  static bool isPatientRole(String role) {
    return role.toLowerCase() == 'patient';
  }

  /// Check if role is admin
  static bool isAdminRole(String role) {
    return role.toLowerCase() == 'admin';
  }

  /// Get app route based on user role
  static String getAppRoute(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return '/user-app';
      case 'admin':
        return '/admin-app';
      default:
        if (isVendorRole(role)) {
          return '/vendor-app';
        }
        return '/login';
    }
  }

  /// Get role display name
  static String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Doctor';
      case 'pharmacist':
        return 'Pharmacist';
      case 'nurse':
        return 'Nurse';
      case 'ambulance':
        return 'Ambulance Service';
      case 'bloodbank':
        return 'Blood Bank';
      case 'pathology':
        return 'Pathology Lab';
      case 'admin':
        return 'Administrator';
      default:
        return role.toUpperCase();
    }
  }

  /// Get role description
  static String getRoleDescription(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'Access healthcare services and book appointments';
      case 'doctor':
        return 'Provide medical consultations and manage appointments';
      case 'pharmacist':
        return 'Manage medicine inventory and fulfill prescriptions';
      case 'nurse':
        return 'Provide nursing care and home visit services';
      case 'ambulance':
        return 'Provide emergency transportation services';
      case 'bloodbank':
        return 'Manage blood inventory and donation services';
      case 'pathology':
        return 'Conduct lab tests and provide diagnostic reports';
      case 'admin':
        return 'Manage platform users and system administration';
      default:
        return 'Healthcare service provider';
    }
  }

  /// Validate role
  static bool isValidRole(String role) {
    return allRoles.contains(role.toLowerCase());
  }
}