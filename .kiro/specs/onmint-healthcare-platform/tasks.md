# Implementation Plan: OnMint Healthcare Platform Authentication System

## Overview

This implementation plan creates a comprehensive healthcare platform with three separate Flutter applications (Admin, Vendor, User) sharing common packages and a centralized authentication system. The platform supports multiple healthcare services with role-based access control, native mobile UI with Material Design, and secure JWT-based authentication using Flutter secure storage.

## Tasks

- [x] 1. Set up Flutter project structure and shared packages
  - Create three separate Flutter projects: admin_app, vendor_app, user_app
  - Set up shared Flutter packages: auth_service, api_client, location_service, ui_components
  - Configure pubspec.yaml files with required dependencies (http, flutter_secure_storage, provider, geolocator)
  - Implement Material Design theme with light blue color scheme
  - _Requirements: 1.1, 1.5, 7.1, 7.2, 8.1, 9.1_

- [ ] 2. Implement shared Flutter packages and services
  - [x] 2.1 Create API client package
    - Implement HTTP client with base URL configuration (http://localhost:5000/api/v1)
    - Create request/response interceptors for JWT authentication
    - Add error handling and retry mechanisms with connectivity monitoring
    - _Requirements: 7.2, 7.3, 7.4_

  - [ ]* 2.2 Write property test for API configuration consistency
    - **Property 9: API Configuration Consistency**
    - **Validates: Requirements 7.3, 7.5**

  - [x] 2.3 Create authentication service package
    - Implement JWT token storage using flutter_secure_storage
    - Add Provider-based authentication state management
    - Create role-based access control utilities
    - _Requirements: 2.1, 2.2, 3.4, 3.5_

  - [ ]* 2.4 Write property test for authentication service
    - **Property 5: Authentication Response Format**
    - **Validates: Requirements 2.6, 2.7**

  - [x] 2.5 Implement location service package
    - Create Geolocator integration for coordinate detection
    - Add location permission handling with permission_handler
    - Implement GeoJSON Point format conversion and manual entry fallback
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 2.6 Write property tests for location service
    - **Property 7: Location Data Format**
    - **Validates: Requirements 5.2, 5.4, 5.5**
    - **Property 8: Location Service Fallback**
    - **Validates: Requirements 5.3**

- [ ] 3. Create shared UI components package and validation
  - [x] 3.1 Implement Flutter form validation utilities
    - Create Dart validators for email format validation
    - Add password complexity validation (8+ chars, uppercase, lowercase, number, special char)
    - Implement phone number and pincode validation for Indian format
    - Add input sanitization functions
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [ ]* 3.2 Write property tests for input validation
    - **Property 14: Input Validation and Sanitization**
    - **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**

  - [ ] 3.3 Create reusable Flutter UI components
    - Implement Material Design form widgets with light blue theme
    - Create loading indicators using CircularProgressIndicator and flutter_spinkit
    - Add error message displays with SnackBar and AlertDialog
    - Implement responsive navigation components with state indicators
    - _Requirements: 8.2, 8.3, 10.5, 12.4, 12.5_

  - [ ]* 3.4 Write property tests for UI components
    - **Property 10: Responsive Design Adaptation**
    - **Validates: Requirements 8.2**
    - **Property 13: Navigation State Indication**
    - **Validates: Requirements 10.4, 10.5**

- [ ] 4. Checkpoint - Ensure shared Flutter packages are working
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Flutter authentication system core
  - [ ] 5.1 Create registration screens with role selection
    - Build Flutter registration forms using Material Design widgets
    - Implement patient registration (email, password, firstName, lastName, phone, city, state, pincode)
    - Add vendor registration fields (specialization, qualifications, experience, consultationFee, licenseNumber, languages)
    - Integrate Geolocator service for coordinate detection
    - _Requirements: 2.3, 2.4, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

  - [ ]* 5.2 Write property tests for registration validation
    - **Property 3: Registration Field Validation**
    - **Validates: Requirements 2.3, 2.4, 2.5**
    - **Property 4: Vendor-Specific Registration**
    - **Validates: Requirements 6.7**

  - [ ] 5.3 Create login screens and authentication flow
    - Implement Flutter login forms with TextFormField widgets
    - Add authentication API integration using HTTP client
    - Create secure token storage using flutter_secure_storage
    - Implement rate limiting for login attempts
    - _Requirements: 2.1, 2.2, 11.6_

  - [ ]* 5.4 Write property test for rate limiting
    - **Property 15: Rate Limiting Protection**
    - **Validates: Requirements 11.6**

  - [ ] 5.5 Implement role-based Flutter navigation system
    - Create role detection from JWT token using Provider
    - Add automatic navigation based on user role (patient → User_App, vendor → Vendor_App, admin → Admin_App)
    - Implement unauthorized access prevention with route guards
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 5.6 Write property tests for role-based access
    - **Property 1: Role-Based Access Control**
    - **Validates: Requirements 1.2, 1.3, 1.4, 3.4, 3.5**
    - **Property 2: Role-Based Routing**
    - **Validates: Requirements 3.1, 3.2, 3.3**

- [ ] 6. Create Flutter error handling and user feedback system
  - [ ] 6.1 Implement comprehensive Flutter error handling
    - Create specific error messages for validation failures using SnackBar
    - Add network error handling with retry mechanisms using AlertDialog
    - Implement security-conscious error messaging for authentication
    - _Requirements: 12.1, 12.2, 12.3_

  - [ ]* 6.2 Write property tests for error handling
    - **Property 16: Error Message Specificity**
    - **Validates: Requirements 12.1, 12.2**
    - **Property 17: User Feedback During Operations**
    - **Validates: Requirements 12.3, 12.4, 12.5**

- [ ] 7. Build Admin Flutter App with authentication integration
  - [ ] 7.1 Create Admin App Flutter project structure and navigation
    - Set up admin_app Flutter project with main.dart, screens/, widgets/, services/
    - Implement admin-specific navigation using Flutter Navigator 2.0 (user management, vendor approval, system monitoring)
    - Add role verification for admin access only using Provider
    - _Requirements: 1.2, 10.1_

  - [ ] 7.2 Integrate authentication system
    - Connect admin app to shared authentication service package
    - Implement login/logout functionality with Flutter secure storage
    - Add session persistence and token validation
    - _Requirements: 2.1, 2.2, 3.2_

  - [ ]* 7.3 Write Flutter integration tests for Admin App
    - Test admin role access control using flutter_test
    - Test navigation and authentication integration
    - _Requirements: 1.2, 3.2_

- [ ] 8. Build Vendor Flutter App with authentication integration
  - [ ] 8.1 Create Vendor App Flutter project structure and navigation
    - Set up vendor_app Flutter project with main.dart, screens/, widgets/, services/
    - Implement vendor-specific navigation using Flutter Navigator 2.0 (service management, appointments, profile)
    - Add role verification for vendor roles (doctor, pharmacist, nurse, ambulance, bloodbank, pathology)
    - _Requirements: 1.3, 10.2_

  - [ ] 8.2 Integrate authentication and service management
    - Connect vendor app to shared authentication service package
    - Implement vendor registration with professional fields using Flutter forms
    - Add service type selection and validation
    - _Requirements: 2.4, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [ ]* 8.3 Write property test for service type support
    - **Property 6: Service Type Support**
    - **Validates: Requirements 4.7**

  - [ ]* 8.4 Write Flutter integration tests for Vendor App
    - Test vendor role access control using flutter_test
    - Test service registration functionality
    - _Requirements: 1.3, 4.7_

- [ ] 9. Build User Flutter App with authentication integration
  - [x] 9.1 Create User App Flutter project structure and navigation
    - Set up user_app Flutter project with main.dart, screens/, widgets/, services/
    - Implement patient-specific navigation using Flutter Navigator 2.0 (service discovery, appointments, health records)
    - Add role verification for patient access only using Provider
    - _Requirements: 1.4, 10.3_

  - [ ] 9.2 Integrate authentication and patient services
    - Connect user app to shared authentication service package
    - Implement patient registration with location services using Geolocator
    - Add service provider search and discovery interface
    - _Requirements: 2.3, 5.1, 5.5_

  - [ ]* 9.3 Write Flutter integration tests for User App
    - Test patient role access control using flutter_test
    - Test location service integration
    - _Requirements: 1.4, 5.5_

- [ ] 10. Implement Material Design theme consistency and accessibility
  - [ ] 10.1 Apply light blue Material Design theme across all Flutter applications
    - Implement consistent ThemeData with light blue color scheme using ColorScheme
    - Apply theme to all forms, buttons, and navigation elements
    - Ensure visual hierarchy and design pattern consistency across apps
    - _Requirements: 8.4, 9.1, 9.2, 9.3, 9.4_

  - [ ]* 10.2 Write property tests for theme consistency
    - **Property 11: Theme Consistency**
    - **Validates: Requirements 8.4, 9.2, 9.3**
    - **Property 12: Accessibility Compliance**
    - **Validates: Requirements 9.5**

  - [ ] 10.3 Optimize for mobile devices
    - Ensure all applications work properly on Android and iOS devices
    - Test touch interactions and responsive breakpoints using MediaQuery
    - Validate loading states and error displays on mobile using flutter_driver
    - _Requirements: 8.1, 8.2, 8.3, 8.5_

- [ ] 11. Final Flutter integration and testing
  - [ ] 11.1 Wire all Flutter applications together
    - Connect all three Flutter applications to shared backend API
    - Test cross-application authentication flow using shared packages
    - Verify role-based routing between applications
    - _Requirements: 7.3, 7.5_

  - [ ]* 11.2 Write comprehensive Flutter integration tests
    - Test complete authentication flow across all applications using integration_test
    - Test API configuration consistency
    - Test error handling and recovery mechanisms
    - _Requirements: 7.3, 12.1, 12.2, 12.3_

  - [ ] 11.3 Performance and security validation
    - Test rate limiting implementation
    - Validate input sanitization across all Flutter forms
    - Check JWT token security and session management with flutter_secure_storage
    - _Requirements: 11.5, 11.6_

- [ ] 12. Final checkpoint - Complete Flutter system validation
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The implementation uses Flutter (Dart) with Material Design for native mobile experience
- All applications share common Flutter packages and maintain consistent theming
- Property tests validate universal correctness properties across all user roles
- Integration tests ensure proper authentication flow between Flutter applications
- Security measures include input validation, rate limiting, and flutter_secure_storage for tokens
- Testing uses flutter_test, integration_test, and check package for property-based testing