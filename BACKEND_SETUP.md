# Backend Configuration for OnMint Healthcare Platform

## Current Configuration

The Flutter app is now configured to make **REAL API calls** to your backend server.

### API Configuration
- **Base URL**: `http://localhost:5000/api/v1`
- **Mock Mode**: `false` (disabled)
- **Endpoints**:
  - Registration: `POST /auth/register`
  - Login: `POST /auth/login`
  - Logout: `POST /auth/logout`

## Registration Payload Format

The app sends this exact JSON structure to your backend:

```json
{
  "email": "patient.rahul1@gmail.com",
  "password": "Secure@Pass123",
  "firstName": "Rahul",
  "lastName": "Gupta",
  "phone": "9987471122",
  "city": "Lucknow",
  "state": "Uttar Pradesh",
  "pincode": "226001",
  "role": "patient",
  "location": {
    "type": "Point",
    "coordinates": [77.2090, 28.6139]
  }
}
```

## Login Payload Format

```json
{
  "email": "patient.rahul1@gmail.com",
  "password": "Secure@Pass123"
}
```

## Expected Backend Response Format

### Successful Registration Response (201)
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "user_id_here",
      "email": "patient.rahul1@gmail.com",
      "firstName": "Rahul",
      "lastName": "Gupta",
      "phone": "9987471122",
      "role": "patient",
      "city": "Lucknow",
      "state": "Uttar Pradesh",
      "pincode": "226001",
      "location": {
        "type": "Point",
        "coordinates": [77.2090, 28.6139]
      },
      "isActive": true,
      "isVerified": false,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    },
    "token": "jwt_token_here"
  }
}
```

### Successful Login Response (200)
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user_id_here",
      "email": "patient.rahul1@gmail.com",
      "firstName": "Rahul",
      "lastName": "Gupta",
      "role": "patient",
      // ... other user fields
    },
    "token": "jwt_token_here"
  }
}
```

### Error Response (400/401/409/500)
```json
{
  "success": false,
  "error": {
    "code": "EMAIL_EXISTS",
    "message": "Email already exists",
    "field": "email"  // optional, for field-specific errors
  }
}
```

## Console Logging

The app now logs detailed information:

```
🌐 API Request: POST http://localhost:5000/api/v1/auth/register
📤 Request Body: {...}
📋 Request Headers: {...}
📥 Response Status: 201
📥 Response Body: {...}
```

## Changing Backend URL

To use a different backend URL, update this file:
`shared_packages/api_client/lib/src/api_config.dart`

```dart
static const String baseUrl = 'https://your-backend-url.com/api/v1';
```

## CORS Configuration

Your backend needs to allow CORS for web requests. Add these headers:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

## Testing

1. **Start your backend server** on `http://localhost:5000`
2. **Open browser console** (F12 → Console)
3. **Try registration** with the test data
4. **Check console logs** for detailed API call information
5. **Verify database** to see if data was saved

## Troubleshooting

- **404 Error**: Backend server not running or wrong URL
- **CORS Error**: Backend doesn't allow cross-origin requests
- **500 Error**: Backend server error, check backend logs
- **Network Error**: Connection issues or firewall blocking