# Requirements Document

## Introduction

OnMint is a comprehensive healthcare platform that connects patients with healthcare service providers through three separate applications: Admin App for administrative management, Vendor App for healthcare service providers, and User App for patients. The platform supports multiple healthcare services including doctors, pharmacy, nursing, lab tests, ambulance services, and blood bank management.

## Glossary

- **OnMint_Platform**: The complete healthcare ecosystem consisting of three applications
- **Admin_App**: Web application for platform administrators to manage the system
- **Vendor_App**: Web application for healthcare service providers to manage their services
- **User_App**: Web application for patients to access healthcare services
- **Authentication_System**: The centralized login and registration system for all user roles
- **Patient**: End users seeking healthcare services
- **Vendor**: Healthcare service providers (doctors, pharmacists, nurses, ambulance operators, blood bank admins, pathology labs)
- **Admin**: Platform administrators managing the overall system
- **Service_Provider**: Any vendor offering healthcare services on the platform
- **Location_Service**: System component that automatically detects and manages user coordinates
- **Role_Based_Router**: System component that redirects users based on their authenticated role
- **Base_API**: Backend API service running on http://localhost:5000/api/v1
- **Mobile_Resolution**: UI optimized for mobile application dimensions in Chrome browser
- **Light_Blue_Theme**: Consistent color scheme across all applications

## Requirements

### Requirement 1: Multi-Application Architecture

**User Story:** As a platform stakeholder, I want three separate applications for different user types, so that each user group has a tailored experience.

#### Acceptance Criteria

1. THE OnMint_Platform SHALL consist of exactly three separate applications: Admin_App, Vendor_App, and User_App
2. THE Admin_App SHALL be accessible only to users with admin role
3. THE Vendor_App SHALL be accessible to users with vendor roles (doctor, pharmacist, nurse, ambulance, bloodbank, pathology)
4. THE User_App SHALL be accessible to users with patient role
5. THE OnMint_Platform SHALL maintain separate folder structures for admin_app, vendor_app, and user_app

### Requirement 2: User Authentication and Registration

**User Story:** As a user, I want to register and login with role-based access, so that I can access appropriate platform features.

#### Acceptance Criteria

1. THE Authentication_System SHALL support registration via POST {{baseUrl}}/auth/register
2. THE Authentication_System SHALL support login via POST {{baseUrl}}/auth/login
3. THE Authentication_System SHALL support patient role registration with email, password, firstName, lastName, phone, city, state, pincode, and location coordinates
4. THE Authentication_System SHALL support vendor role registration with additional fields: specialization, qualifications, experience, consultationFee, licenseNumber, and languages
5. THE Authentication_System SHALL validate all required fields during registration
6. WHEN registration is successful, THE Authentication_System SHALL return authentication tokens
7. WHEN login is successful, THE Authentication_System SHALL return user profile and authentication tokens

### Requirement 3: Role-Based Access Control

**User Story:** As a platform user, I want to be redirected to the appropriate application based on my role, so that I access relevant features.

#### Acceptance Criteria

1. WHEN a user with patient role logs in, THE Role_Based_Router SHALL redirect to User_App home page
2. WHEN a user with vendor role logs in, THE Role_Based_Router SHALL redirect to Vendor_App home page
3. WHEN a user with admin role logs in, THE Role_Based_Router SHALL redirect to Admin_App home page
4. THE Role_Based_Router SHALL prevent unauthorized access to applications not matching user role
5. IF a user attempts to access an unauthorized application, THEN THE Role_Based_Router SHALL redirect to appropriate login page

### Requirement 4: Healthcare Service Management

**User Story:** As a platform administrator, I want to support multiple healthcare services, so that patients can access comprehensive healthcare options.

#### Acceptance Criteria

1. THE OnMint_Platform SHALL support doctor consultation services
2. THE OnMint_Platform SHALL support medicine/pharmacy services
3. THE OnMint_Platform SHALL support nursing services
4. THE OnMint_Platform SHALL support lab test/pathology services
5. THE OnMint_Platform SHALL support ambulance services
6. THE OnMint_Platform SHALL support blood bank services
7. THE OnMint_Platform SHALL allow vendors to register for specific service types

### Requirement 5: Location Services

**User Story:** As a user, I want my location to be automatically detected during registration, so that I can receive location-based healthcare services.

#### Acceptance Criteria

1. THE Location_Service SHALL automatically detect user coordinates during registration
2. THE Location_Service SHALL populate location field with GeoJSON Point format containing longitude and latitude
3. WHEN location detection fails, THE Location_Service SHALL prompt user to manually enter location
4. THE Location_Service SHALL validate coordinate format before submission
5. THE Location_Service SHALL store location data for service matching and routing

### Requirement 6: Vendor Registration System

**User Story:** As a healthcare service provider, I want to register with my professional details, so that I can offer services on the platform.

#### Acceptance Criteria

1. THE Authentication_System SHALL support doctor registration with specialization, qualifications, experience, consultationFee, licenseNumber, and languages
2. THE Authentication_System SHALL support pharmacist registration with pharmacy license and operating hours
3. THE Authentication_System SHALL support nurse registration with nursing credentials and service areas
4. THE Authentication_System SHALL support ambulance operator registration with vehicle details and coverage area
5. THE Authentication_System SHALL support blood bank admin registration with blood bank license and inventory capacity
6. THE Authentication_System SHALL support pathology lab registration with lab accreditation and test capabilities
7. THE Authentication_System SHALL validate professional credentials for each vendor type

### Requirement 7: API Configuration Management

**User Story:** As a developer, I want centralized API configuration, so that I can easily manage backend endpoints across all applications.

#### Acceptance Criteria

1. THE OnMint_Platform SHALL maintain a base URL configuration file
2. THE Base_API SHALL be configured to http://localhost:5000/api/v1
3. THE OnMint_Platform SHALL use consistent API endpoints across all three applications
4. THE OnMint_Platform SHALL support environment-specific API configuration
5. WHEN API configuration changes, THE OnMint_Platform SHALL update all applications consistently

### Requirement 8: Mobile-Optimized User Interface

**User Story:** As a user, I want a mobile-optimized interface, so that I can easily use the platform on mobile devices.

#### Acceptance Criteria

1. THE OnMint_Platform SHALL optimize UI for Mobile_Resolution in Chrome browser
2. THE OnMint_Platform SHALL implement responsive design for mobile application dimensions
3. THE OnMint_Platform SHALL ensure touch-friendly interface elements
4. THE OnMint_Platform SHALL maintain consistent Light_Blue_Theme across all applications
5. THE OnMint_Platform SHALL provide smooth navigation optimized for mobile interaction

### Requirement 9: Theme and Branding Consistency

**User Story:** As a platform user, I want consistent visual design across all applications, so that I have a cohesive user experience.

#### Acceptance Criteria

1. THE OnMint_Platform SHALL implement Light_Blue_Theme as the primary color scheme
2. THE Admin_App SHALL maintain consistent branding with Vendor_App and User_App
3. THE OnMint_Platform SHALL use consistent typography and spacing across all applications
4. THE OnMint_Platform SHALL maintain visual hierarchy and design patterns
5. THE OnMint_Platform SHALL ensure accessibility compliance with color contrast requirements

### Requirement 10: Application Routing and Navigation

**User Story:** As a user, I want intuitive navigation within my designated application, so that I can efficiently access platform features.

#### Acceptance Criteria

1. THE Admin_App SHALL provide navigation for user management, vendor approval, and system monitoring
2. THE Vendor_App SHALL provide navigation for service management, appointment handling, and profile updates
3. THE User_App SHALL provide navigation for service discovery, appointment booking, and health records
4. THE OnMint_Platform SHALL implement breadcrumb navigation for complex workflows
5. THE OnMint_Platform SHALL provide clear visual indicators for current page and navigation state

### Requirement 11: Data Validation and Security

**User Story:** As a platform administrator, I want robust data validation and security measures, so that user data is protected and system integrity is maintained.

#### Acceptance Criteria

1. THE Authentication_System SHALL validate email format and uniqueness during registration
2. THE Authentication_System SHALL enforce password complexity requirements (minimum 8 characters, uppercase, lowercase, number, special character)
3. THE Authentication_System SHALL validate phone number format and length
4. THE Authentication_System SHALL validate pincode format for Indian postal codes
5. THE Authentication_System SHALL sanitize all user inputs to prevent injection attacks
6. THE Authentication_System SHALL implement rate limiting for registration and login attempts

### Requirement 12: Error Handling and User Feedback

**User Story:** As a user, I want clear error messages and feedback, so that I can understand and resolve issues quickly.

#### Acceptance Criteria

1. WHEN registration fails, THE Authentication_System SHALL return specific error messages for each validation failure
2. WHEN login fails, THE Authentication_System SHALL return appropriate error message without revealing sensitive information
3. WHEN network errors occur, THE OnMint_Platform SHALL display user-friendly error messages with retry options
4. THE OnMint_Platform SHALL provide loading indicators during API calls
5. THE OnMint_Platform SHALL display success confirmations for completed actions