# 🚑 Ambulance Vendor API Complete Guide

**Total APIs:** 22  
**Status:** ✅ 100% Complete  
**Last Updated:** April 18, 2026

---

## 📋 Quick Reference

All 22 ambulance vendor APIs are fully implemented in both backend and frontend.

### API Categories:
1. **Profile Management** (2 APIs)
2. **Location & Availability** (2 APIs)
3. **Ride Request Management** (11 APIs)
4. **Dashboard & Analytics** (1 API)
5. **Financial** (1 API)
6. **Ratings & Reviews** (1 API)
7. **Authentication** (4 APIs)

---

## 1️⃣ Profile Management (2 APIs)

### 1.1 Get Profile
```dart
// Frontend Usage
final profile = await ambulanceService.getProfile();
```
- **Endpoint:** `GET /auth/me`
- **Returns:** Full ambulance profile with driver and vehicle details
- **Auth:** Required

### 1.2 Update Profile
```dart
// Frontend Usage
final updatedProfile = await ambulanceService.updateProfile({
  'driverName': 'John Doe',
  'vehicleNumber': 'AMB-123',
  'vehicleType': 'Advanced Life Support',
  'equipmentAvailable': ['Defibrillator', 'Oxygen Cylinder'],
});
```
- **Endpoint:** `PUT /ambulance/profile`
- **Body:** Profile fields to update
- **Returns:** Updated profile
- **Auth:** Required

---

## 2️⃣ Location & Availability (2 APIs)

### 2.1 Update Location
```dart
// Frontend Usage
await ambulanceService.updateLocation(latitude, longitude);
```
- **Endpoint:** `PUT /ambulance/location`
- **Body:** `{ latitude: double, longitude: double }`
- **Purpose:** Real-time GPS tracking
- **Auth:** Required

### 2.2 Set Availability
```dart
// Frontend Usage
await ambulanceService.setAvailability(true); // Online
await ambulanceService.setAvailability(false); // Offline
```
- **Endpoint:** `PUT /ambulance/availability`
- **Body:** `{ isAvailable: boolean }`
- **Purpose:** Toggle online/offline status
- **Auth:** Required

---

## 3️⃣ Ride Request Management (11 APIs)

### 3.1 Get All Ride Requests
```dart
// Frontend Usage
final result = await ambulanceService.getRideRequests(page: 1, limit: 20);
final rides = result['data'];
final pagination = result['pagination'];
```
- **Endpoint:** `GET /ambulance/requests?page=1&limit=20`
- **Returns:** Paginated list of all ride requests
- **Auth:** Required

### 3.2 Get Pending Requests
```dart
// Frontend Usage
final result = await ambulanceService.getPendingRequests(page: 1, limit: 20);
```
- **Endpoint:** `GET /ambulance/requests?status=pending&page=1&limit=20`
- **Returns:** Requests waiting for acceptance
- **Status:** `pending` or `requested`
- **Auth:** Required

### 3.3 Get Confirmed Requests
```dart
// Frontend Usage
final result = await ambulanceService.getConfirmedRequests(page: 1, limit: 20);
```
- **Endpoint:** `GET /ambulance/requests?status=confirmed&page=1&limit=20`
- **Returns:** Accepted rides not yet started
- **Status:** `confirmed`
- **Auth:** Required

### 3.4 Get On-The-Way Requests
```dart
// Frontend Usage
final result = await ambulanceService.getOnTheWayRequests(page: 1, limit: 20);
```
- **Endpoint:** `GET /ambulance/requests?status=on-the-way&page=1&limit=20`
- **Returns:** Rides en route to pickup location
- **Status:** `on-the-way`
- **Auth:** Required

### 3.5 Get In-Progress Requests
```dart
// Frontend Usage
final result = await ambulanceService.getInProgressRequests(page: 1, limit: 20);
```
- **Endpoint:** `GET /ambulance/requests?status=in-progress&page=1&limit=20`
- **Returns:** Rides with patient onboard
- **Status:** `in-progress`
- **Auth:** Required

### 3.6 Get Completed Requests
```dart
// Frontend Usage
final result = await ambulanceService.getCompletedRequests(page: 1, limit: 20);
```
- **Endpoint:** `GET /ambulance/requests?status=completed&page=1&limit=20`
- **Returns:** Finished rides
- **Status:** `completed`
- **Auth:** Required

### 3.7 Get Ride Details
```dart
// Frontend Usage
final rideDetails = await ambulanceService.getRideDetails(requestId);
```
- **Endpoint:** `GET /ambulance/requests/:id`
- **Returns:** Detailed information about a single ride
- **Auth:** Required

### 3.8 Accept Ride Request
```dart
// Frontend Usage
await ambulanceService.acceptRideRequest(requestId);
```
- **Endpoint:** `POST /ambulance/requests/:id/accept`
- **Action:** Confirms availability and accepts the ride
- **Status Change:** `pending` → `confirmed`
- **Auth:** Required

### 3.9 Start Ride
```dart
// Frontend Usage
await ambulanceService.startRide(requestId);
```
- **Endpoint:** `POST /ambulance/requests/:id/start`
- **Action:** Begin journey to pickup location
- **Status Change:** `confirmed` → `on-the-way`
- **Auth:** Required

### 3.10 Arrive at Pickup
```dart
// Frontend Usage
await ambulanceService.arriveAtPickup(requestId);
```
- **Endpoint:** `POST /ambulance/requests/:id/arrive`
- **Action:** Mark arrival at patient location
- **Status Change:** `on-the-way` → `in-progress`
- **Auth:** Required

### 3.11 Complete Ride
```dart
// Frontend Usage
await ambulanceService.completeRide(requestId);
```
- **Endpoint:** `POST /ambulance/requests/:id/complete`
- **Action:** Finish the ride and update stats
- **Status Change:** `in-progress` → `completed`
- **Side Effect:** Increments `totalRides` counter
- **Auth:** Required

---

## 4️⃣ Dashboard & Analytics (1 API)

### 4.1 Get Dashboard
```dart
// Frontend Usage
final dashboard = await ambulanceService.getDashboard();
print('Active Rides: ${dashboard.activeRides}');
print('Total Rides: ${dashboard.totalRides}');
print('Rating: ${dashboard.rating}');
```
- **Endpoint:** `GET /ambulance/dashboard`
- **Returns:** 
  - `activeRides`: Current ongoing rides
  - `totalRides`: Lifetime ride count
  - `isAvailable`: Online/offline status
  - `rating`: Average rating
  - `vehicleType`: Vehicle category
- **Auth:** Required

---

## 5️⃣ Financial (1 API)

### 5.1 Get Earnings
```dart
// Frontend Usage
final earnings = await ambulanceService.getEarnings(
  startDate: '2026-04-01',
  endDate: '2026-04-30',
  page: 1,
  limit: 20,
);
print('Total Earnings: ${earnings['totalEarnings']}');
```
- **Endpoint:** `GET /ambulance/earnings`
- **Query Params:** `startDate`, `endDate`, `page`, `limit`
- **Returns:** 
  - `data`: List of earning records
  - `pagination`: Page info
  - `totalEarnings`: Sum of earnings
- **Auth:** Required

---

## 6️⃣ Ratings & Reviews (1 API)

### 6.1 Get Ratings
```dart
// Frontend Usage
final ratings = await ambulanceService.getRatings(page: 1, limit: 20);
print('Average Rating: ${ratings['averageRating']}');
print('Total Ratings: ${ratings['totalRatings']}');
```
- **Endpoint:** `GET /ambulance/ratings`
- **Query Params:** `page`, `limit`
- **Returns:**
  - `data`: List of rating records
  - `pagination`: Page info
  - `averageRating`: Overall rating
  - `totalRatings`: Number of ratings
- **Auth:** Required

---

## 7️⃣ Authentication (4 APIs)

### 7.1 Change Password
```dart
// Frontend Usage
await ambulanceService.changePassword(
  currentPassword: 'oldPass123',
  newPassword: 'newPass456',
);
```
- **Endpoint:** `POST /auth/change-password`
- **Body:** `{ currentPassword, newPassword }`
- **Auth:** Required

### 7.2 Logout Current Session
```dart
// Frontend Usage
await ambulanceService.logout();
```
- **Endpoint:** `POST /auth/logout`
- **Action:** Invalidates current device token
- **Auth:** Required

### 7.3 Logout All Sessions
```dart
// Frontend Usage
await ambulanceService.logoutAll();
```
- **Endpoint:** `POST /auth/logout-all`
- **Action:** Invalidates all device tokens
- **Auth:** Required

### 7.4 Refresh Token
```dart
// Frontend Usage
final tokens = await ambulanceService.refreshToken(refreshToken);
final newAccessToken = tokens['accessToken'];
```
- **Endpoint:** `POST /auth/refresh-token`
- **Body:** `{ refreshToken }`
- **Returns:** New access and refresh tokens
- **Auth:** Not required (uses refresh token)

---

## 🔄 Ride Status Flow

```
1. PENDING/REQUESTED
   ↓ (Accept Ride)
2. CONFIRMED
   ↓ (Start Ride)
3. ON-THE-WAY
   ↓ (Arrive at Pickup)
4. IN-PROGRESS
   ↓ (Complete Ride)
5. COMPLETED
```

---

## 📱 Frontend Implementation Files

### Service Layer:
- `New_Onmint/shared_packages/api_client/lib/src/services/ambulance_api_service.dart`

### UI Screens:
- `New_Onmint/vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- `New_Onmint/vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- `New_Onmint/vendor_app/lib/screens/ambulance/ambulance_home_screen.dart`
- `New_Onmint/vendor_app/lib/screens/home/dashboards/ambulance_dashboard.dart`

---

## 🔧 Backend Implementation Files

### Controller:
- `Ourdeals_Healthcare/src/controller/ambulance.controller.js`

### Routes:
- `Ourdeals_Healthcare/src/routes/ambulance.routes.js`

### Services:
- `Ourdeals_Healthcare/src/services/booking.service.js`
- `Ourdeals_Healthcare/src/services/location.service.js`

---

## 🧪 Testing

### Test All APIs:
```bash
# Start backend
cd Ourdeals_Healthcare
npm start

# Run vendor app
cd New_Onmint/vendor_app
flutter run -d chrome
```

### Test Credentials:
- **Email:** `quickresponse.amulance25@healthcare.com`
- **Password:** `password123`
- **Role:** `ambulance`

---

## ✅ Verification Checklist

- [x] All 22 APIs implemented in backend
- [x] All 22 APIs implemented in frontend service
- [x] All status filters working (pending, confirmed, on-the-way, in-progress, completed)
- [x] Real-time location updates
- [x] Availability toggle
- [x] Dashboard with statistics
- [x] Earnings tracking
- [x] Ratings & reviews
- [x] Authentication & security
- [x] Error handling
- [x] Loading states
- [x] Pagination support

---

## 📊 API Response Examples

### Get Ride Requests Response:
```json
{
  "success": true,
  "message": "Ride requests fetched",
  "data": [
    {
      "_id": "69e31906125306436d72ebaf",
      "patient": {
        "_id": "69da7f75d64e65d3354a2136",
        "firstName": "John",
        "lastName": "Doe",
        "phone": "9876543219"
      },
      "provider": {
        "_id": "69e31888125306436d72eb8f",
        "firstName": "QuickResponse",
        "driverName": "Michael Rodriguez",
        "vehicleNumber": "AMB-WA-101"
      },
      "serviceType": "ambulance",
      "status": "requested",
      "location": {
        "address": "Emergency location",
        "coordinates": [25.454, 78.6086]
      },
      "isEmergency": true,
      "createdAt": "2026-04-18T05:39:18.737Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1,
    "hasNext": false,
    "hasPrev": false
  }
}
```

---

**Document Version:** 1.0  
**Status:** Complete ✅  
**Maintained By:** Development Team
