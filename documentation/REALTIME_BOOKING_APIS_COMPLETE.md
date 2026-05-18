# Real-Time Booking APIs - Complete Documentation

**Date:** April 18, 2026  
**Status:** 📋 DOCUMENTATION COMPLETE  
**Total APIs:** 21 APIs

---

## 🎯 Overview

Real-time booking system allows instant booking requests for:
- **Nurses** - Home nursing care
- **Ambulances** - Emergency transport
- **Doctors** - Urgent consultations
- **Pathology** - Lab test bookings
- **Medicine Orders** - Pharmacy delivery

**Flow:** Patient creates request → All vendors notified → First to accept gets the booking

---

## 📊 API Categories

### 1. Patient APIs (User App) - 8 APIs
### 2. Vendor APIs (Vendor App) - 10 APIs
### 3. Admin APIs (Admin App) - 3 APIs

---

## 1️⃣ PATIENT APIS (User App)

### Base URL: `{{BASE_URL}}/api/v1/realtime-bookings`

---

### 1.1 Create Real-Time Booking
**Endpoint:** `POST /create`  
**Auth:** Required (Patient)  
**Description:** Create instant booking request for any service

**Request Body:**
```json
{
  "serviceType": "nurse",  // nurse | ambulance | doctor | pathology | medicine
  "description": "Need nurse for wound dressing and IV medication administration at home.",
  "urgency": "medium",  // low | medium | high | emergency
  "preferredTime": "2026-04-11T15:00:00.000Z",
  "specialRequirements": "Experience with post-surgery wound care. Need to change dressing daily.",
  "address": "789 Park Lane, Queens, NY 11375",
  "coordinates": [-73.8448, 40.7282],  // [longitude, latitude]
  "isEmergency": false,
  "notes": "Patient had surgery 3 days ago. Wound healing well but needs professional care."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Real-time booking created successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "patient": "69dcac105ffdaf9ee718c995",
    "serviceType": "nurse",
    "description": "Need nurse for wound dressing...",
    "urgency": "medium",
    "status": "pending",
    "preferredTime": "2026-04-11T15:00:00.000Z",
    "address": "789 Park Lane, Queens, NY 11375",
    "location": {
      "type": "Point",
      "coordinates": [-73.8448, 40.7282]
    },
    "isEmergency": false,
    "createdAt": "2026-04-18T10:30:00.000Z",
    "expiresAt": "2026-04-18T10:45:00.000Z"  // 15 min expiry
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.2 Get My Real-Time Bookings
**Endpoint:** `GET /my-bookings`  
**Auth:** Required (Patient)  
**Query Params:**
- `status` - pending | accepted | completed | cancelled | expired
- `serviceType` - nurse | ambulance | doctor | pathology | medicine
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 20)

**Response:**
```json
{
  "success": true,
  "message": "Bookings fetched successfully",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "serviceType": "nurse",
      "description": "Need nurse for wound dressing...",
      "urgency": "medium",
      "status": "pending",
      "preferredTime": "2026-04-11T15:00:00.000Z",
      "address": "789 Park Lane, Queens, NY 11375",
      "acceptedBy": null,
      "createdAt": "2026-04-18T10:30:00.000Z",
      "expiresAt": "2026-04-18T10:45:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.3 Get Booking Details
**Endpoint:** `GET /:id`  
**Auth:** Required (Patient)  
**Description:** Get detailed information about a specific booking

**Response:**
```json
{
  "success": true,
  "message": "Booking details fetched successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "patient": {
      "_id": "69dcac105ffdaf9ee718c995",
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+1234567890"
    },
    "serviceType": "nurse",
    "description": "Need nurse for wound dressing...",
    "urgency": "medium",
    "status": "accepted",
    "preferredTime": "2026-04-11T15:00:00.000Z",
    "address": "789 Park Lane, Queens, NY 11375",
    "location": {
      "type": "Point",
      "coordinates": [-73.8448, 40.7282]
    },
    "acceptedBy": {
      "_id": "69dcac105ffdaf9ee718c996",
      "firstName": "Jane",
      "lastName": "Smith",
      "phone": "+1234567891",
      "rating": 4.8
    },
    "acceptedAt": "2026-04-18T10:32:00.000Z",
    "estimatedArrival": "2026-04-18T11:00:00.000Z",
    "createdAt": "2026-04-18T10:30:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.4 Cancel Booking
**Endpoint:** `PUT /:id/cancel`  
**Auth:** Required (Patient)  
**Description:** Cancel a pending or accepted booking

**Request Body:**
```json
{
  "reason": "Found alternative service"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking cancelled successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "cancelled",
    "cancellationReason": "Found alternative service",
    "cancelledAt": "2026-04-18T10:35:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.5 Rate Service Provider
**Endpoint:** `POST /:id/rate`  
**Auth:** Required (Patient)  
**Description:** Rate the service provider after completion

**Request Body:**
```json
{
  "rating": 5,
  "review": "Excellent service! Very professional and caring.",
  "tags": ["professional", "punctual", "caring"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Rating submitted successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "rating": 5,
    "review": "Excellent service!...",
    "ratedAt": "2026-04-18T12:00:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.6 Track Service Provider
**Endpoint:** `GET /:id/track`  
**Auth:** Required (Patient)  
**Description:** Get real-time location of service provider

**Response:**
```json
{
  "success": true,
  "message": "Location fetched successfully",
  "data": {
    "provider": {
      "_id": "69dcac105ffdaf9ee718c996",
      "firstName": "Jane",
      "lastName": "Smith",
      "phone": "+1234567891"
    },
    "currentLocation": {
      "type": "Point",
      "coordinates": [-73.8450, 40.7280]
    },
    "estimatedArrival": "2026-04-18T11:00:00.000Z",
    "distance": 2.5,  // km
    "status": "on_the_way"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.7 Get Nearby Providers
**Endpoint:** `GET /nearby-providers`  
**Auth:** Required (Patient)  
**Query Params:**
- `serviceType` - nurse | ambulance | doctor | pathology
- `latitude` - Current latitude
- `longitude` - Current longitude
- `radius` - Search radius in km (default: 10)

**Response:**
```json
{
  "success": true,
  "message": "Nearby providers fetched successfully",
  "data": [
    {
      "_id": "69dcac105ffdaf9ee718c996",
      "firstName": "Jane",
      "lastName": "Smith",
      "serviceType": "nurse",
      "rating": 4.8,
      "totalBookings": 150,
      "distance": 2.5,
      "isAvailable": true,
      "location": {
        "type": "Point",
        "coordinates": [-73.8450, 40.7280]
      }
    }
  ]
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 1.8 Get Booking History
**Endpoint:** `GET /history`  
**Auth:** Required (Patient)  
**Query Params:**
- `startDate` - Filter from date
- `endDate` - Filter to date
- `serviceType` - Filter by service type
- `page` - Page number
- `limit` - Items per page

**Response:**
```json
{
  "success": true,
  "message": "Booking history fetched successfully",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "serviceType": "nurse",
      "status": "completed",
      "acceptedBy": {
        "firstName": "Jane",
        "lastName": "Smith"
      },
      "completedAt": "2026-04-18T12:00:00.000Z",
      "rating": 5,
      "totalAmount": 500
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 25,
    "totalPages": 2
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

## 2️⃣ VENDOR APIS (Vendor App)

### Base URL: `{{BASE_URL}}/api/v1/realtime-bookings`

---

### 2.1 Get Available Bookings
**Endpoint:** `GET /vendor/available`  
**Auth:** Required (Vendor)  
**Description:** Get all pending bookings for vendor's service type

**Query Params:**
- `serviceType` - Filter by service type (auto-detected from vendor profile)
- `radius` - Search radius in km (default: 10)
- `urgency` - Filter by urgency level

**Response:**
```json
{
  "success": true,
  "message": "Available bookings fetched successfully",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "patient": {
        "firstName": "John",
        "lastName": "Doe",
        "phone": "+1234567890"
      },
      "serviceType": "nurse",
      "description": "Need nurse for wound dressing...",
      "urgency": "medium",
      "preferredTime": "2026-04-11T15:00:00.000Z",
      "address": "789 Park Lane, Queens, NY 11375",
      "distance": 2.5,
      "estimatedFee": 500,
      "expiresAt": "2026-04-18T10:45:00.000Z",
      "createdAt": "2026-04-18T10:30:00.000Z"
    }
  ]
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.2 Accept Booking
**Endpoint:** `POST /:id/accept`  
**Auth:** Required (Vendor)  
**Description:** Accept a pending booking (first-come-first-served)

**Request Body:**
```json
{
  "estimatedArrival": "2026-04-18T11:00:00.000Z",
  "notes": "On my way. Will reach in 30 minutes."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking accepted successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "accepted",
    "acceptedBy": "69dcac105ffdaf9ee718c996",
    "acceptedAt": "2026-04-18T10:32:00.000Z",
    "estimatedArrival": "2026-04-18T11:00:00.000Z",
    "patient": {
      "firstName": "John",
      "lastName": "Doe",
      "phone": "+1234567890",
      "address": "789 Park Lane, Queens, NY 11375"
    }
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.3 Get My Accepted Bookings
**Endpoint:** `GET /vendor/my-bookings`  
**Auth:** Required (Vendor)  
**Query Params:**
- `status` - accepted | in_progress | completed | cancelled
- `page` - Page number
- `limit` - Items per page

**Response:**
```json
{
  "success": true,
  "message": "My bookings fetched successfully",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "patient": {
        "firstName": "John",
        "lastName": "Doe",
        "phone": "+1234567890"
      },
      "serviceType": "nurse",
      "status": "accepted",
      "address": "789 Park Lane, Queens, NY 11375",
      "preferredTime": "2026-04-11T15:00:00.000Z",
      "acceptedAt": "2026-04-18T10:32:00.000Z",
      "estimatedArrival": "2026-04-18T11:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.4 Start Service
**Endpoint:** `PUT /:id/start`  
**Auth:** Required (Vendor)  
**Description:** Mark service as started

**Request Body:**
```json
{
  "notes": "Service started. Patient is cooperative."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Service started successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "in_progress",
    "startedAt": "2026-04-18T11:00:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.5 Complete Service
**Endpoint:** `PUT /:id/complete`  
**Auth:** Required (Vendor)  
**Description:** Mark service as completed

**Request Body:**
```json
{
  "notes": "Service completed successfully. Patient is doing well.",
  "serviceDetails": {
    "duration": 60,  // minutes
    "servicesProvided": ["Wound dressing", "IV medication"],
    "nextVisitRequired": true,
    "nextVisitDate": "2026-04-19T15:00:00.000Z"
  },
  "amount": 500
}
```

**Response:**
```json
{
  "success": true,
  "message": "Service completed successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "completed",
    "completedAt": "2026-04-18T12:00:00.000Z",
    "amount": 500,
    "serviceDetails": {
      "duration": 60,
      "servicesProvided": ["Wound dressing", "IV medication"]
    }
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.6 Update Location
**Endpoint:** `PUT /:id/update-location`  
**Auth:** Required (Vendor)  
**Description:** Update current location for tracking

**Request Body:**
```json
{
  "latitude": 40.7280,
  "longitude": -73.8450,
  "estimatedArrival": "2026-04-18T11:00:00.000Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "currentLocation": {
      "type": "Point",
      "coordinates": [-73.8450, 40.7280]
    },
    "estimatedArrival": "2026-04-18T11:00:00.000Z",
    "updatedAt": "2026-04-18T10:45:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.7 Reject Booking
**Endpoint:** `PUT /:id/reject`  
**Auth:** Required (Vendor)  
**Description:** Reject a booking request

**Request Body:**
```json
{
  "reason": "Not available at requested time"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking rejected successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "rejectedBy": ["69dcac105ffdaf9ee718c996"],
    "rejectionReason": "Not available at requested time"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.8 Get Booking Earnings
**Endpoint:** `GET /vendor/earnings`  
**Auth:** Required (Vendor)  
**Query Params:**
- `startDate` - Filter from date
- `endDate` - Filter to date
- `status` - completed | pending_payment | paid

**Response:**
```json
{
  "success": true,
  "message": "Earnings fetched successfully",
  "data": {
    "totalEarnings": 15000,
    "pendingPayment": 2000,
    "paidAmount": 13000,
    "bookings": [
      {
        "_id": "69e31906125306436d72ebaf",
        "completedAt": "2026-04-18T12:00:00.000Z",
        "amount": 500,
        "paymentStatus": "paid",
        "paidAt": "2026-04-18T13:00:00.000Z"
      }
    ]
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.9 Get Booking Statistics
**Endpoint:** `GET /vendor/statistics`  
**Auth:** Required (Vendor)  
**Query Params:**
- `period` - today | week | month | year

**Response:**
```json
{
  "success": true,
  "message": "Statistics fetched successfully",
  "data": {
    "totalBookings": 150,
    "completedBookings": 140,
    "cancelledBookings": 5,
    "averageRating": 4.8,
    "totalEarnings": 75000,
    "acceptanceRate": 95,
    "completionRate": 98
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 2.10 Toggle Availability
**Endpoint:** `PUT /vendor/toggle-availability`  
**Auth:** Required (Vendor)  
**Description:** Toggle online/offline status

**Request Body:**
```json
{
  "isAvailable": true,
  "location": {
    "latitude": 40.7280,
    "longitude": -73.8450
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Availability updated successfully",
  "data": {
    "isAvailable": true,
    "lastLocationUpdate": "2026-04-18T10:30:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

## 3️⃣ ADMIN APIS (Admin App)

### Base URL: `{{BASE_URL}}/api/v1/admin/realtime-bookings`

---

### 3.1 Get All Bookings
**Endpoint:** `GET /`  
**Auth:** Required (Admin)  
**Query Params:**
- `status` - pending | accepted | completed | cancelled | expired
- `serviceType` - nurse | ambulance | doctor | pathology | medicine
- `urgency` - low | medium | high | emergency
- `startDate` - Filter from date
- `endDate` - Filter to date
- `page` - Page number
- `limit` - Items per page

**Response:**
```json
{
  "success": true,
  "message": "Bookings fetched successfully",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "patient": {
        "firstName": "John",
        "lastName": "Doe"
      },
      "serviceType": "nurse",
      "status": "completed",
      "urgency": "medium",
      "acceptedBy": {
        "firstName": "Jane",
        "lastName": "Smith"
      },
      "createdAt": "2026-04-18T10:30:00.000Z",
      "completedAt": "2026-04-18T12:00:00.000Z",
      "amount": 500
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 500,
    "totalPages": 25
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 3.2 Get Booking Analytics
**Endpoint:** `GET /analytics`  
**Auth:** Required (Admin)  
**Query Params:**
- `period` - today | week | month | year
- `serviceType` - Filter by service type

**Response:**
```json
{
  "success": true,
  "message": "Analytics fetched successfully",
  "data": {
    "totalBookings": 5000,
    "pendingBookings": 50,
    "acceptedBookings": 100,
    "completedBookings": 4500,
    "cancelledBookings": 250,
    "expiredBookings": 100,
    "averageResponseTime": 120,  // seconds
    "averageCompletionTime": 3600,  // seconds
    "totalRevenue": 2500000,
    "byServiceType": {
      "nurse": 2000,
      "ambulance": 1500,
      "doctor": 1000,
      "pathology": 500
    },
    "byUrgency": {
      "low": 1000,
      "medium": 2500,
      "high": 1000,
      "emergency": 500
    }
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

### 3.3 Manage Booking
**Endpoint:** `PUT /:id/manage`  
**Auth:** Required (Admin)  
**Description:** Admin can cancel, reassign, or modify bookings

**Request Body:**
```json
{
  "action": "cancel",  // cancel | reassign | modify
  "reason": "Patient request",
  "reassignTo": "69dcac105ffdaf9ee718c997",  // For reassign action
  "modifications": {  // For modify action
    "preferredTime": "2026-04-11T16:00:00.000Z",
    "address": "New address"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Booking managed successfully",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "cancelled",
    "managedBy": "admin_id",
    "managementReason": "Patient request",
    "managedAt": "2026-04-18T10:40:00.000Z"
  }
}
```

**Frontend Status:** ❌ NOT IMPLEMENTED

---

## 📊 Implementation Status Summary

### Patient APIs (User App): 0/8 Implemented
- [ ] Create Real-Time Booking
- [ ] Get My Real-Time Bookings
- [ ] Get Booking Details
- [ ] Cancel Booking
- [ ] Rate Service Provider
- [ ] Track Service Provider
- [ ] Get Nearby Providers
- [ ] Get Booking History

### Vendor APIs (Vendor App): 0/10 Implemented
- [ ] Get Available Bookings
- [ ] Accept Booking
- [ ] Get My Accepted Bookings
- [ ] Start Service
- [ ] Complete Service
- [ ] Update Location
- [ ] Reject Booking
- [ ] Get Booking Earnings
- [ ] Get Booking Statistics
- [ ] Toggle Availability

### Admin APIs (Admin App): 0/3 Implemented
- [ ] Get All Bookings
- [ ] Get Booking Analytics
- [ ] Manage Booking

**Total: 0/21 APIs Implemented (0%)**

---

## 🔄 Real-Time Features

### WebSocket Events:
1. **new_booking** - Notify vendors of new booking
2. **booking_accepted** - Notify patient booking was accepted
3. **booking_cancelled** - Notify all parties of cancellation
4. **location_update** - Real-time location tracking
5. **service_started** - Notify patient service started
6. **service_completed** - Notify patient service completed

---

## 🚀 Next Steps

### Priority 1: User App (Patient)
1. Implement Create Real-Time Booking screen
2. Implement My Bookings screen with real-time updates
3. Implement Tracking screen with map
4. Implement Rating screen

### Priority 2: Vendor App
1. Implement Available Bookings screen
2. Implement Accept/Reject functionality
3. Implement My Bookings screen
4. Implement Location tracking
5. Implement Service completion flow

### Priority 3: Admin App
1. Implement Real-Time Bookings dashboard
2. Implement Analytics screen
3. Implement Booking management

---

**Created By:** Kiro AI Assistant  
**Date:** April 18, 2026  
**Status:** 📋 DOCUMENTATION COMPLETE - READY FOR IMPLEMENTATION
