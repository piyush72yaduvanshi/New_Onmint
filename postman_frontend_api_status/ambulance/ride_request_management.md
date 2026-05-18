# Ride Request Management APIs - Status

## 1. Get All Ride Requests
**Endpoint:** `GET /ambulance/requests?page=1&limit=20`  
**Postman:** Ride Request Management → Get All Ride Requests  
**Status:** ✅ **Working - FIXED**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getRideRequests(page, limit, status)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Ride requests list screen
- **Tested:** Yes

**ISSUE WAS FIXED:**
- ✅ Now filters to show only 'requested' status bookings in 'all' view
- ✅ Default view changed from 'all' to 'pending'
- ✅ No more 400 errors when clicking accept

**Fix Applied:**
```dart
// Only show 'requested' status in 'all' view
if (_selectedStatus == 'all') {
  rides = rides.where((ride) {
    final status = ride['status'] ?? '';
    return status == 'requested'; // Only pending bookings
  }).toList();
}
```

**Backend Response Example:**
```json
{
  "success": true,
  "message": "Ride requests fetched",
  "data": [{
    "_id": "69e31906125306436d72ebaf",
    "patient": {
      "_id": "69da7f75d64e65d3354a2136",
      "firstName": "John",
      "lastName": "Doe",
      "phone": "9876543219"
    },
    "status": "requested",  // Only 'requested' shown in default view
    "isEmergency": true,
    "notes": "EMERGENCY AMBULANCE: Immediate assistance required"
  }],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

---

## 2. Get Pending Requests
**Endpoint:** `GET /ambulance/requests?status=pending&page=1&limit=20`  
**Postman:** Ride Request Management → Get Pending Requests  
**Status:** ✅ **Working - FIXED**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getPendingRequests(page, limit)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Filter dropdown - "Pending" option (DEFAULT VIEW)
- **Tested:** Yes

**FIX APPLIED:**
- ✅ Frontend now maps 'pending' → 'requested' when calling backend
- ✅ This is now the default view when opening ride requests
- ✅ Only shows bookings that can be accepted

**Status Mapping:**
```dart
case 'pending':
  backendStatus = 'requested'; // Backend uses 'requested' for pending
  break;
```

---

## 3. Get Confirmed Requests
**Endpoint:** `GET /ambulance/requests?status=confirmed&page=1&limit=20`  
**Postman:** Ride Request Management → Get Confirmed Requests  
**Status:** ✅ **Working - FIXED**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getConfirmedRequests(page, limit)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Filter dropdown - "Confirmed" option
- **Tested:** Yes

**FIX APPLIED:**
- ✅ Frontend now maps 'confirmed' → 'accepted' when calling backend
- ✅ Shows bookings that have been accepted and are ready to start

**Status Mapping:**
```dart
case 'confirmed':
  backendStatus = 'accepted'; // Backend uses 'accepted' for confirmed
  break;
```

---

## 4. Get On-The-Way Requests
**Endpoint:** `GET /ambulance/requests?status=on-the-way&page=1&limit=20`  
**Postman:** Ride Request Management → Get On-The-Way Requests  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getOnTheWayRequests(page, limit)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Filter dropdown - "On The Way" option
- **Tested:** Yes
- **Notes:** Status matches between backend and frontend

---

## 5. Get In-Progress Requests
**Endpoint:** `GET /ambulance/requests?status=in-progress&page=1&limit=20`  
**Postman:** Ride Request Management → Get In-Progress Requests  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getInProgressRequests(page, limit)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Filter dropdown - "In Progress" option
- **Tested:** Yes
- **Notes:** Status matches between backend and frontend

---

## 6. Get Completed Requests
**Endpoint:** `GET /ambulance/requests?status=completed&page=1&limit=20`  
**Postman:** Ride Request Management → Get Completed Requests  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getCompletedRequests(page, limit)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_requests_screen.dart`
- **Used In:** Filter dropdown - "Completed" option
- **Tested:** Yes
- **Notes:** Status matches between backend and frontend

---

## 7. Accept Ride Request
**Endpoint:** `POST /ambulance/requests/:id/accept`  
**Postman:** Ride Request Management → Accept Ride Request  
**Status:** ✅ **Working - FIXED**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.acceptRideRequest(requestId)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- **Used In:** "Accept" button on ride details screen
- **Tested:** Yes

**FIX APPLIED:**
- ✅ Accept button now only shows for 'requested' status bookings
- ✅ No more 400 errors from trying to accept already-accepted bookings
- ✅ Default view filters out non-requested bookings

**Backend Validation:**
```javascript
if (booking.status !== 'requested') {
  return res.status(400).json(errorResponse(`Booking is already ${booking.status}`));
}
```

**Frontend Fix:**
```dart
// Only show accept button for 'requested' status
if (_ride!['status'] == 'requested') ...[
  ElevatedButton(
    onPressed: _acceptRide,
    child: Text('Accept'),
  ),
]
```

**Success Response:**
```json
{
  "success": true,
  "message": "Ride accepted",
  "data": {
    "_id": "69e31906125306436d72ebaf",
    "status": "accepted",
    "acceptedAt": "2026-04-19T10:30:00.000Z"
  }
}
```

**Error Response (if already accepted):**
```json
{
  "success": false,
  "message": "Booking is already accepted",
  "errors": null
}
```

---

## 8. Start Ride (En Route)
**Endpoint:** `POST /ambulance/requests/:id/start`  
**Postman:** Ride Request Management → Start Ride (En Route)  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.startRide(requestId)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- **Used In:** "Start Ride" button (shown when status is 'accepted')
- **Tested:** Yes
- **Notes:** Marks ride as started - ambulance is now en route to pickup location. Also starts location tracking.

---

## 9. Arrive at Pickup
**Endpoint:** `POST /ambulance/requests/:id/arrive`  
**Postman:** Ride Request Management → Arrive at Pickup  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.arriveAtPickup(requestId)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- **Used In:** "Mark as Arrived" button (shown when status is 'on_the_way')
- **Tested:** Yes
- **Notes:** Marks arrival at pickup location - patient is being loaded into ambulance

---

## 10. Complete Ride
**Endpoint:** `POST /ambulance/requests/:id/complete`  
**Postman:** Ride Request Management → Complete Ride  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.completeRide(requestId)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- **Used In:** "Complete Ride" button (shown when status is 'arrived')
- **Tested:** Yes
- **Notes:** Marks ride as completed - patient delivered to destination. Stops location tracking.

---

## 11. Get Ride Details
**Endpoint:** `GET /ambulance/requests/:id`  
**Postman:** Not in collection but exists in backend  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.getRideDetails(requestId)`
- **Location:** `vendor_app/lib/screens/ambulance/ride_details_screen.dart`
- **Used In:** Ride details screen
- **Tested:** Yes
- **Notes:** Fetches single ride request details with patient information

---

## Summary
**Total APIs:** 11  
**✅ Working:** 11 (100%)  
**⚠️ Partial:** 0  
**❌ Not Working:** 0  
**⏳ Pending:** 0

**ALL ISSUES FIXED:**
1. ✅ Status Mismatch - Fixed with status mapping
2. ✅ Filter Issue - Default view now shows only 'requested' bookings
3. ✅ Accept Button - Only shows for 'requested' status bookings
4. ✅ 400 Errors - Eliminated by proper filtering

**Status Mapping Applied:**
| Frontend | Backend | Description |
|----------|---------|-------------|
| pending | requested | New bookings awaiting acceptance |
| confirmed | accepted | Bookings accepted, ready to start |
| on-the-way | on-the-way | En route to pickup |
| in-progress | in-progress | Patient loaded, heading to destination |
| completed | completed | Ride completed |

**All ride request management APIs are now 100% working!**
