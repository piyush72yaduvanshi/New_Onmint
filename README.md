# OnMint Healthcare Platform

A comprehensive healthcare platform built with Flutter, consisting of three separate applications for different user types.

## Applications

### 1. User App (Patients)
- **Port**: 3000
- **Target Users**: Patients seeking healthcare services
- **Features**: Service booking, appointment management, health records

### 2. Vendor App (Healthcare Providers)
- **Port**: 3001
- **Target Users**: Doctors, Pharmacists, Nurses, Ambulance services, Blood banks, Pathology labs
- **Features**: Service management, appointment handling, patient communication

### 3. Admin App (Platform Administration)
- **Port**: 3002
- **Target Users**: Platform administrators
- **Features**: User management, system monitoring, platform configuration

## Quick Start

### Prerequisites
- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.0.0)
- Chrome browser (for web development)

### Running the Applications

#### User App (Port 3000)
```bash
cd user_app
flutter run -d chrome --web-port 3000
```

#### Vendor App (Port 3001)
```bash
cd vendor_app
flutter run -d chrome --web-port 3001
```

#### Admin App (Port 3002)
```bash
cd admin_app
flutter run -d chrome --web-port 3002
```

### Running All Apps Simultaneously

You can run all three apps at the same time in separate terminal windows:

**Terminal 1 (User App):**
```bash
cd user_app && flutter run -d chrome --web-port 3000
```

**Terminal 2 (Vendor App):**
```bash
cd vendor_app && flutter run -d chrome --web-port 3001
```

**Terminal 3 (Admin App):**
```bash
cd admin_app && flutter run -d chrome --web-port 3002
```

## Project Structure

```
onmint-healthcare-platform/
├── user_app/                 # Patient application
├── vendor_app/               # Healthcare provider application
├── admin_app/                # Platform administration application
├── shared_packages/          # Shared Flutter packages
│   ├── auth_service/         # Authentication service
│   ├── api_client/           # API client with interceptors
│   ├── location_service/     # Location services
│   └── ui_components/        # Shared UI components and theme
└── README.md
```

## Shared Packages

### auth_service
- JWT token management
- User authentication and registration
- Role-based access control
- Secure token storage

### api_client
- HTTP client with interceptors
- Authentication header injection
- Connectivity monitoring
- Error handling

### location_service
- GPS location detection
- Address geocoding
- Location permissions

### ui_components
- Consistent Material Design theme (Light Blue)
- Custom widgets (buttons, text fields, role selector)
- Form validators
- UI utilities and helpers

## User Roles

The platform supports the following user roles:

- **Patient**: Access healthcare services
- **Doctor**: Provide medical consultations
- **Pharmacist**: Manage pharmacy services
- **Nurse**: Provide nursing care
- **Ambulance**: Emergency medical transport
- **Blood Bank**: Blood donation services
- **Pathology**: Laboratory services
- **Admin**: Platform administration

## Authentication Flow

1. **Registration**: Users select their role and provide required information
2. **Login**: Email/password authentication with JWT tokens
3. **Role Validation**: Backend validates user role and permissions
4. **Token Management**: Automatic token refresh and secure storage
5. **Route Protection**: Role-based navigation and screen access

## API Integration

- **Base URL**: `http://localhost:5000/api/v1`
- **Authentication**: JWT Bearer tokens
- **Endpoints**: RESTful API with role-based access control

## Development

### Installing Dependencies

Run this command in each app directory and shared package:

```bash
flutter pub get
```

### Code Generation

For packages that use code generation (like auth_service):

```bash
cd shared_packages/auth_service
flutter pub run build_runner build
```

### Testing

Run tests for each application:

```bash
# User App
cd user_app && flutter test

# Vendor App
cd vendor_app && flutter test

# Admin App
cd admin_app && flutter test
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   - Make sure no other applications are running on ports 3000, 3001, or 3002
   - Use different ports if needed: `flutter run -d chrome --web-port 3003`

2. **Package Dependencies**
   - Run `flutter pub get` in each app directory
   - Run `flutter pub get` in each shared package directory

3. **Build Errors**
   - Run `flutter clean` in the problematic app directory
   - Delete `pubspec.lock` and run `flutter pub get` again

4. **Chrome Not Found**
   - Make sure Chrome is installed and in your PATH
   - Use `flutter devices` to see available devices

### Asset Errors

If you encounter asset-related errors, the asset directories have been created but are empty. You can:

1. Add actual image/icon files to the respective `assets/` directories
2. Update `pubspec.yaml` to reference specific assets
3. Remove asset references if not needed

## Features

### User App Features
- Service discovery and booking
- Appointment management
- Health record access
- Location-based provider search
- Real-time notifications

### Vendor App Features
- Service management
- Appointment scheduling
- Patient communication
- Revenue tracking
- Profile management

### Admin App Features
- User management
- Platform analytics
- System configuration
- Content management
- Support tools

## Technology Stack

- **Frontend**: Flutter (Web)
- **State Management**: Provider
- **Storage**: Flutter Secure Storage, SharedPreferences
- **Network**: HTTP with custom interceptors
- **Location**: Geolocator
- **UI**: Material Design 3 with custom theme
- **Authentication**: JWT tokens

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is proprietary software for OnMint Healthcare Platform.