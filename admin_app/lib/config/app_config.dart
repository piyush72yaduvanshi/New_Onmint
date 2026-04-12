/// Application configuration for Admin App
class AppConfig {
  /// Development mode - always show login screen for testing
  /// Set to false for production to enable normal authentication flow
  static const bool developmentMode = true;  // Set to true to always show login first
  
  /// Force logout on app start (for testing)
  static const bool forceLogoutOnStart = true;  // Set to true to clear cached auth
  
  /// Show debug information in console
  static const bool showDebugLogs = true;
}