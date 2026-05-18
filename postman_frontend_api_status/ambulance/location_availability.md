# Location & Availability APIs - Status

## 1. Update Location
**Endpoint:** `PUT /ambulance/location`  
**Postman:** Location & Availability → Update Location  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.updateLocation(latitude, longitude)`
- **Location:** `vendor_app/lib/screens/ambulance/ambulance_home_screen.dart`
- **Used In:** Background location updates
- **Tested:** Yes
- **Notes:** Updates ambulance's current GPS location for real-time tracking and nearby search

**Request Body:**
```json
{
  "latitude": 34.0522,
  "longitude": -118.2437
}
```

---

## 2. Set Available
**Endpoint:** `PUT /ambulance/availability`  
**Postman:** Location & Availability → Set Available  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.setAvailability(true)`
- **Location:** `vendor_app/lib/screens/ambulance/ambulance_home_screen.dart`
- **Used In:** Availability toggle switch on dashboard
- **Tested:** Yes
- **Notes:** Sets ambulance as available to accept new ride requests

**Request Body:**
```json
{
  "isAvailable": true
}
```

**UI Implementation:**
- Toggle switch on home screen
- Shows "Available for Rides" status
- Green indicator when available

---

## 3. Set Unavailable
**Endpoint:** `PUT /ambulance/availability`  
**Postman:** Location & Availability → Set Unavailable  
**Status:** ✅ **Working**

**Frontend Integration:**
- **Service Method:** `AmbulanceApiService.setAvailability(false)`
- **Location:** `vendor_app/lib/screens/ambulance/ambulance_home_screen.dart`
- **Used In:** Availability toggle switch on dashboard
- **Tested:** Yes
- **Notes:** Sets ambulance as unavailable (off-duty, maintenance, or busy)

**Request Body:**
```json
{
  "isAvailable": false
}
```

**UI Implementation:**
- Same toggle switch as "Set Available"
- Shows "Offline" status
- Red indicator when unavailable

---

## Summary
**Total APIs:** 3  
**✅ Working:** 3  
**⚠️ Partial:** 0  
**❌ Not Working:** 0  
**⏳ Pending:** 0

**Overall Status:** ✅ All location & availability APIs are working
