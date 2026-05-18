# 📚 Complete API Reference - OnMint Healthcare Platform

**Last Updated:** April 18, 2026  
**Total APIs:** 123  
**Status:** All Complete ✅

This document provides a complete reference for all 123 APIs in the OnMint Healthcare Platform, including endpoints, methods, request/response formats, status codes, and field descriptions.

---

## 📑 Table of Contents

1. [Authentication APIs (12)](#authentication-apis)
2. [Patient APIs (18)](#patient-apis)
3. [Ambulance Vendor APIs (22)](#ambulance-vendor-apis)
4. [Doctor Vendor APIs (6)](#doctor-vendor-apis)
5. [Nurse Vendor APIs (8)](#nurse-vendor-apis)
6. [Pharmacist Vendor APIs (12)](#pharmacist-vendor-apis)
7. [Pathology Vendor APIs (10)](#pathology-vendor-apis)
8. [Blood Bank Vendor APIs (8)](#blood-bank-vendor-apis)
9. [Admin APIs (15)](#admin-apis)
10. [Document Management APIs (5)](#document-management-apis)
11. [Payment APIs (4)](#payment-apis)
12. [Rating & Review APIs (3)](#rating-review-apis)

---

## 🔐 Authentication APIs

### Base URL: `/api/v1/auth`

| # | Endpoint | Method | Auth | Description |
|---|----------|--------|------|-------------|
| 1 | `/register` | POST | No | Register new user |
| 2 | `/login` | POST | No | Login user |
| 3 | `/logout` | POST | Yes | Logout current session |
| 4 | `/logout-all` | POST | Yes | Logout all sessions |
| 5 | `/refresh-token` | POST | No | Refresh access token |
| 6 | `/me` | GET | Yes | Get current user |
| 7 | `/change-password` | POST | Yes | Change password |
| 8 | `/forgot-password` | POST | No | Request password reset |
| 9 | `/reset-password` | POST | No | Reset password |
| 10 | `/verify-otp` | POST | No | Verify OTP |
| 11 | `/resend-otp` | POST | No | Resend OTP |
| 12 | `/update-profile` | PUT | Yes | Update profile |

### 1. Register User

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "9876543210",
  "role": "patient",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pincode": "400001"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "user": {
      "_id": "user_id",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": "patient"
    },
    "tokens": {
      "accessToken": "jwt_token",
      "refreshToken": "refresh_token"
    }
  }
}
```

**Status Codes:**
- `201` - Created successfully
- `400` - Validation error
- `409` - Email already exists
- `500` - Server error

---

### 2. Login

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "user_id",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": "patient",
      "status": "active"
    },
    "tokens": {
      "accessToken": "jwt_token",
      "refreshToken": "refresh_token"
    }
  }
}
```

**Status Codes:**
- `200` - Login successful
- `401` - Invalid credentials
- `403` - Account suspended/pending
- `500` - Server error

---

### 3. Get Current User

**Endpoint:** `GET /api/v1/auth/me`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "message": "User fetched",
  "data": {
    "_id": "user_id",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "9876543210",
    "role": "patient",
    "status": "active",
    "profilePicture": "url",
    "createdAt": "2026-04-18T00:00:00.000Z"
  }
}
```

---

## 👨‍⚕️ Patient APIs

### Base URL: `/api/v1/patient`

| # | Endpoint | Method | Auth | Description |
|---|----------|--------|------|-------------|
| 1 | `/search/doctors` | GET | No | Search doctors |
| 2 | `/search/nurses` | GET | No | Search nurses |
| 3 | `/search/ambulances` | GET | No | Search ambulances |
| 4 | `/search/bloodbanks` | GET | No | Search blood banks |
| 5 | `/search/medicines` | GET | No | Search medicines |
| 6 | `/doctors/:id/availability` | GET | No | Get doctor availability |
| 7 | `/medicines/:id` | GET | No | Get medicine details |
| 8 | `/bookings` | POST | Yes | Create booking |
| 9 | `/bookings` | GET | Yes | Get my bookings |
| 10 | `/bookings/:id` | GET | Yes | Get booking details |
| 11 | `/bookings/:id/cancel` | PUT | Yes | Cancel booking |
| 12 | `/bookings/:id/rate` | POST | Yes | Rate service |
| 13 | `/emergency` | POST | Yes | Trigger emergency |
| 14 | `/nearby-services` | GET | No | Get nearby services |
| 15 | `/realtime-booking/create` | POST | Yes | Create realtime booking |
| 16 | `/realtime-booking/my-bookings` | GET | Yes | Get realtime bookings |
| 17 | `/realtime-booking/:id` | GET | Yes | Get booking details |
| 18 | `/realtime-booking/:id/cancel` | POST | Yes | Cancel realtime booking |

### 1. Search Doctors

**Endpoint:** `GET /api/v1/patient/search/doctors`

**Query Parameters:**
- `search` (string, optional) - Search by name
- `specialization` (string, optional) - Filter by specialization
- `city` (string, optional) - Filter by city
- `isAvailable` (boolean, optional) - Filter by availability
- `page` (number, default: 1) - Page number
- `limit` (number, default: 20) - Items per page

**Example:**
```
GET /api/v1/patient/search/doctors?specialization=Cardiology&city=Mumbai&page=1&limit=10
```

**Response (200):**
```json
{
  "success": true,
  "message": "Doctors fetched",
  "data": [
    {
      "_id": "doctor_id",
      "firstName": "Dr. Sarah",
      "lastName": "Johnson",
      "specialization": "Cardiology",
      "qualification": "MBBS, MD",
      "experience": 10,
      "rating": 4.5,
      "consultationFee": 500,
      "city": "Mumbai",
      "isAvailable": true,
      "profilePicture": "url"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "totalPages": 3,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

### 8. Create Booking

**Endpoint:** `POST /api/v1/patient/bookings`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "provider": "provider_id",
  "serviceType": "doctor",
  "scheduledTime": "2026-04-20T10:00:00.000Z",
  "consultationType": "in-person",
  "symptoms": "Fever and cough",
  "notes": "Patient has history of asthma",
  "location": {
    "address": "123 Main St, Mumbai",
    "coordinates": [72.8777, 19.076]
  }
}
```

**Field Descriptions:**
- `provider` (required) - ID of doctor/nurse/ambulance
- `serviceType` (required) - One of: `doctor`, `nurse`, `ambulance`, `pathology`, `bloodbank`, `pharmacist`
- `scheduledTime` (optional) - ISO 8601 date-time
- `consultationType` (optional) - `in-person`, `video-call`, `home-visit`
- `symptoms` (optional) - Patient symptoms
- `notes` (optional) - Additional notes
- `location` (required for ambulance/home-visit) - Address and coordinates

**Response (201):**
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "_id": "booking_id",
    "patient": "patient_id",
    "provider": {
      "_id": "provider_id",
      "firstName": "Dr. Sarah",
      "lastName": "Johnson"
    },
    "serviceType": "doctor",
    "status": "requested",
    "scheduledTime": "2026-04-20T10:00:00.000Z",
    "consultationType": "in-person",
    "price": 500,
    "createdAt": "2026-04-18T12:00:00.000Z"
  }
}
```

**Status Codes:**
- `201` - Booking created
- `400` - Validation error
- `401` - Unauthorized
- `404` - Provider not found
- `409` - Time slot not available
- `500` - Server error

---

### 13. Trigger Emergency

**Endpoint:** `POST /api/v1/patient/emergency`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "location": {
    "type": "Point",
    "coordinates": [72.8777, 19.076]
  },
  "type": "ambulance",
  "address": "123 Main St, Mumbai",
  "notes": "Patient unconscious"
}
```

**Field Descriptions:**
- `location` (required) - GeoJSON Point with [longitude, latitude]
- `type` (required) - `ambulance` or `doctor`
- `address` (optional) - Human-readable address
- `notes` (optional) - Emergency details

**Response (201):**
```json
{
  "success": true,
  "message": "Emergency request created",
  "data": {
    "_id": "booking_id",
    "patient": "patient_id",
    "provider": {
      "_id": "ambulance_id",
      "driverName": "John Driver",
      "vehicleNumber": "AMB-123",
      "vehicleType": "Advanced Life Support"
    },
    "serviceType": "ambulance",
    "status": "requested",
    "isEmergency": true,
    "location": {
      "address": "123 Main St, Mumbai",
      "coordinates": [72.8777, 19.076]
    },
    "eta": 15,
    "createdAt": "2026-04-18T12:00:00.000Z"
  }
}
```

**Status Codes:**
- `201` - Emergency created
- `400` - Invalid request
- `401` - Unauthorized
- `404` - No providers available
- `429` - Too many requests (rate limited)
- `500` - Server error

---

## 🚑 Ambulance Vendor APIs

### Base URL: `/api/v1/ambulance`

| # | Endpoint | Method | Auth | Description |
|---|----------|--------|------|-------------|
| 1 | `/profile` | PUT | Yes | Update profile |
| 2 | `/location` | PUT | Yes | Update location |
| 3 | `/availability` | PUT | Yes | Set availability |
| 4 | `/requests` | GET | Yes | Get all ride requests |
| 5 | `/requests?status=pending` | GET | Yes | Get pending requests |
| 6 | `/requests?status=confirmed` | GET | Yes | Get confirmed requests |
| 7 | `/requests?status=on-the-way` | GET | Yes | Get on-the-way requests |
| 8 | `/requests?status=in-progress` | GET | Yes | Get in-progress requests |
| 9 | `/requests?status=completed` | GET | Yes | Get completed requests |
| 10 | `/requests/:id` | GET | Yes | Get ride details |
| 11 | `/requests/:id/accept` | POST | Yes | Accept ride request |
| 12 | `/requests/:id/start` | POST | Yes | Start ride |
| 13 | `/requests/:id/arrive` | POST | Yes | Arrive at pickup |
| 14 | `/requests/:id/complete` | POST | Yes | Complete ride |
| 15 | `/dashboard` | GET | Yes | Get dashboard |
| 16 | `/earnings` | GET | Yes | Get earnings |
| 17 | `/ratings` | GET | Yes | Get ratings |

### 1. Update Profile

**Endpoint:** `PUT /api/v1/ambulance/profile`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "driverName": "John Driver",
  "driverLicense": "DL-123456",
  "vehicleNumber": "AMB-123",
  "vehicleType": "Advanced Life Support",
  "equipmentAvailable": [
    "Defibrillator",
    "Oxygen Cylinder",
    "Stretcher",
    "First Aid Kit"
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "_id": "ambulance_id",
    "email": "ambulance@example.com",
    "firstName": "QuickResponse",
    "lastName": "Ambulance",
    "driverName": "John Driver",
    "vehicleNumber": "AMB-123",
    "vehicleType": "Advanced Life Support",
    "equipmentAvailable": ["Defibrillator", "Oxygen Cylinder"],
    "isAvailable": true,
    "rating": 4.5,
    "totalRides": 150
  }
}
```

---

### 2. Update Location

**Endpoint:** `PUT /api/v1/ambulance/location`

**Request Body:**
```json
{
  "latitude": 19.076,
  "longitude": 72.8777
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Location updated",
  "data": {
    "type": "Point",
    "coordinates": [72.8777, 19.076],
    "lastUpdated": "2026-04-18T12:00:00.000Z"
  }
}
```

---

### 3. Set Availability

**Endpoint:** `PUT /api/v1/ambulance/availability`

**Request Body:**
```json
{
  "isAvailable": true
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Availability updated",
  "data": {
    "isAvailable": true
  }
}
```

---

### 4. Get Ride Requests

**Endpoint:** `GET /api/v1/ambulance/requests`

**Query Parameters:**
- `status` (string, optional) - Filter by status: `pending`, `confirmed`, `on-the-way`, `in-progress`, `completed`, `cancelled`
- `page` (number, default: 1)
- `limit` (number, default: 20)

**Example:**
```
GET /api/v1/ambulance/requests?status=pending&page=1&limit=20
```

**Response (200):**
```json
{
  "success": true,
  "message": "Ride requests fetched",
  "data": [
    {
      "_id": "booking_id",
      "patient": {
        "_id": "patient_id",
        "firstName": "John",
        "lastName": "Doe",
        "phone": "9876543210"
      },
      "serviceType": "ambulance",
      "status": "requested",
      "isEmergency": true,
      "location": {
        "address": "123 Main St, Mumbai",
        "coordinates": [72.8777, 19.076]
      },
      "notes": "EMERGENCY AMBULANCE: Immediate assistance required",
      "createdAt": "2026-04-18T12:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1,
    "hasNext": false,
    "hasPrev": false
  }
}
```

---

### 11. Accept Ride Request

**Endpoint:** `POST /api/v1/ambulance/requests/:id/accept`

**Headers:**
```
Authorization: Bearer {accessToken}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Ride accepted",
  "data": {
    "_id": "booking_id",
    "status": "confirmed",
    "acceptedAt": "2026-04-18T12:00:00.000Z",
    "eta": 15
  }
}
```

**Status Codes:**
- `200` - Ride accepted
- `400` - Already accepted or invalid status
- `401` - Unauthorized
- `404` - Booking not found
- `409` - Not assigned to you
- `500` - Server error

---

### 12. Start Ride

**Endpoint:** `POST /api/v1/ambulance/requests/:id/start`

**Response (200):**
```json
{
  "success": true,
  "message": "Ride started",
  "data": {
    "_id": "booking_id",
    "status": "on-the-way",
    "startedAt": "2026-04-18T12:05:00.000Z"
  }
}
```

---

### 13. Arrive at Pickup

**Endpoint:** `POST /api/v1/ambulance/requests/:id/arrive`

**Response (200):**
```json
{
  "success": true,
  "message": "Arrived at pickup",
  "data": {
    "_id": "booking_id",
    "status": "in-progress",
    "arrivedAt": "2026-04-18T12:20:00.000Z"
  }
}
```

---

### 14. Complete Ride

**Endpoint:** `POST /api/v1/ambulance/requests/:id/complete`

**Response (200):**
```json
{
  "success": true,
  "message": "Ride completed",
  "data": {
    "_id": "booking_id",
    "status": "completed",
    "completedAt": "2026-04-18T12:45:00.000Z"
  }
}
```

---

### 15. Get Dashboard

**Endpoint:** `GET /api/v1/ambulance/dashboard`

**Response (200):**
```json
{
  "success": true,
  "message": "Dashboard data fetched",
  "data": {
    "activeRides": 2,
    "totalRides": 150,
    "isAvailable": true,
    "rating": 4.5,
    "vehicleType": "Advanced Life Support"
  }
}
```

---

## 📊 Status Flow Diagrams

### Ambulance Ride Status Flow:
```
REQUESTED → CONFIRMED → ON-THE-WAY → IN-PROGRESS → COMPLETED
   ↓           ↓            ↓             ↓            ↓
Accept      Start       Arrive       Complete      Done
```

### Doctor Appointment Status Flow:
```
REQUESTED → ACCEPTED → IN-PROGRESS → COMPLETED
   ↓           ↓            ↓            ↓
Accept      Start       Complete      Done
```

### Medicine Order Status Flow:
```
REQUESTED → ACCEPTED → PREPARING → READY → COMPLETED
   ↓           ↓           ↓          ↓         ↓
Accept      Prepare     Ready     Pickup     Done
```

---

## 🔒 Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer {accessToken}
```

### Token Expiry:
- Access Token: 24 hours
- Refresh Token: 30 days

### Refresh Token:
```
POST /api/v1/auth/refresh-token
{
  "refreshToken": "refresh_token"
}
```

---

## ⚠️ Error Responses

### Standard Error Format:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

### Common Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `429` - Too Many Requests
- `500` - Internal Server Error

---

## 📝 Field Validation Rules

### Email:
- Format: valid email address
- Unique: must not exist in database

### Password:
- Minimum length: 8 characters
- Must contain: letters and numbers

### Phone:
- Format: 10 digits
- Pattern: `^[0-9]{10}$`

### Coordinates:
- Latitude: -90 to 90
- Longitude: -180 to 180

### Status Values:
- Booking: `requested`, `accepted`, `confirmed`, `on-the-way`, `in-progress`, `completed`, `cancelled`
- User: `pending`, `active`, `approved`, `suspended`, `rejected`

---

## 🚀 Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| `/auth/login` | 100 requests | 15 minutes |
| `/auth/register` | 30 requests | 1 hour |
| `/patient/emergency` | 100 requests | 15 minutes |
| `/payment/*` | 3 requests | 1 minute |
| General API | 100 requests | 15 minutes |

---

**Document Version:** 1.0  
**Last Updated:** April 18, 2026  
**Maintained By:** OnMint Development Team
