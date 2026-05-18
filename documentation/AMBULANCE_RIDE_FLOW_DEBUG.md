# 🚑 Ambulance Ride Flow - Complete Guide & Debugging

**Last Updated:** April 18, 2026

This document explains the complete ambulance ride flow, common issues, and how to debug them.

---

## 🔄 Complete Ride Flow

### 1. Patient Creates Emergency Request

**Patient App:**
```dart
await patientService.triggerEmergency(
  location: {'type': 'Point', 'coordinates': [lng, lat]},
  type: 'ambulance',
);
```

**Backend Process:**
1. Finds nearest available ambulance within 50km
2. If none found, searches ANY available ambulance
3. Creates booking with:
   - `status: 'requested'`
   - `provider: ambulance_id` (assigned immediately)
   - `isEmergency: true`
4. Sends notification to assigned ambulance

**Database State:**
```json
{
  "_id": "booking_id",
  "patient": "patient_id",
  "provider": "ambulance_id",
  "serviceType": "ambulance",
  "status": "requested",
  "isEmergency": true,
  "location": {...},
  "createdAt": "2026-04-18T12:00:00.000Z"
}
```

---

### 2. Ambulance Sees Request

**Vendor App:**
```dart
final result = await ambulanceService.getRideRequests(
  status: 'pending', // or null for all
  page: 1,
  limit: 20,
);
```

**Backend Query:**
```javascript
{
  provider: ambulance_id,
  serviceType: 'ambulance',
  status: 'requested' // if status filter applied
}
```

**Expected Result:**
- Ambulance should see the booking in their list
- Status shows as "Pending" or "Requested"
- Emergency badge displayed

---

### 3. Ambulance Accepts Request

**Vendor App:**
```dart
await ambulanceService.acceptRideRequest(booking_id);
```

**Backend Process:**
1. Validates ambulance is available
2. Checks booking status is `'requested'`
3. Checks provider matches ambulance_id
4. Updates booking:
   - `status: 'requested'` → `'accepted'` or `'confirmed'`
   - `acceptedAt: new Date()`
5. Calculates ETA

**Database State After Accept:**
```json
{
  "_id": "booking_id",
  "status": "accepted",
  "acceptedAt": "2026-04-18T12:01:00.000Z",
  "eta": 15
}
```

---

### 4. Ambulance Starts Ride

**Vendor App:**
```dart
await ambulanceService.startRide(booking_id);
```

**Status Change:** `accepted` → `on-the-way`

---

### 5. Ambulance Arrives at Pickup

**Vendor App:**
```dart
await ambulanceService.arriveAtPickup(booking_id);
```

**Status Change:** `on-the-way` → `in-progress`

---

### 6. Ambulance Completes Ride

**Vendor App:**
```dart
await ambulanceService.completeRide(booking_id);
```

**Status Change:** `in-progress` → `completed`

**Side Effects:**
- Increments ambulance `totalRides` counter
- Booking marked as complete
- Payment processed (if applicable)

---

## ❌ Common Issues & Solutions

### Issue 1: 500 Error on Accept

**Error Message:**
```
"Booking not found, already accepted by another provider, or not available"
```

**Possible Causes:**

#### A. Booking Already Accepted
**Check:**
```javascript
// In MongoDB or backend logs
db.bookings.findOne({_id: "booking_id"})
// Check status field
```

**Solution:**
- If status is already `'accepted'` or `'confirmed'`, skip accept step
- Go directly to "Start Ride"

#### B. Provider ID Mismatch
**Check:**
```javascript
// Compare IDs
booking.provider.toString() === ambulance_id.toString()
```

**Solution:**
- Ensure ambulance is logged in with correct account
- Check token is valid and contains correct user ID
- Verify booking was assigned to this ambulance

#### C. Booking Status Not 'requested'
**Check:**
```javascript
booking.status === 'requested'
```

**Solution:**
- If status is `'cancelled'`, booking cannot be accepted
- If status is `'completed'`, ride is already done
- Refresh the ride list to get current status

---

### Issue 2: Booking Not Showing in List

**Possible Causes:**

#### A. Wrong Status Filter
**Check:**
```dart
// Try without status filter first
final result = await ambulanceService.getRideRequests();
```

**Solution:**
- Use `status: null` or no status parameter to see all bookings
- Check if booking exists with different status

#### B. Provider Not Assigned
**Check:**
```javascript
booking.provider === ambulance_id
```

**Solution:**
- Emergency bookings should auto-assign provider
- If provider is null, booking is for "any available" provider
- Only assigned bookings show in provider's list

#### C. Service Type Mismatch
**Check:**
```javascript
booking.serviceType === 'ambulance'
```

**Solution:**
- Ensure booking is for ambulance service
- Check if accidentally created as different service type

---

### Issue 3: Status Not Updating

**Possible Causes:**

#### A. Frontend Not Refreshing
**Solution:**
```dart
// Add pull-to-refresh
RefreshIndicator(
  onRefresh: _loadRides,
  child: ListView(...),
)
```

#### B. Backend Status Validation Failed
**Check Backend Logs:**
```
Status transition not allowed: requested → completed
```

**Solution:**
- Follow correct status flow
- Cannot skip statuses (e.g., requested → completed)

---

## 🔍 Debugging Steps

### Step 1: Check Booking Exists
```bash
# In MongoDB
db.bookings.findOne({_id: ObjectId("booking_id")})
```

**Expected:**
```json
{
  "_id": "booking_id",
  "patient": "patient_id",
  "provider": "ambulance_id",
  "serviceType": "ambulance",
  "status": "requested",
  "isEmergency": true
}
```

---

### Step 2: Verify Provider Assignment
```bash
# Check if provider matches logged-in ambulance
booking.provider.toString() === ambulance_id.toString()
```

**If Mismatch:**
- Booking assigned to different ambulance
- Cannot accept this booking
- Should not appear in your list

---

### Step 3: Check Current Status
```bash
# Get current booking status
db.bookings.findOne({_id: ObjectId("booking_id")}, {status: 1})
```

**Status Meanings:**
- `requested` - Can be accepted
- `accepted/confirmed` - Already accepted, can start
- `on-the-way` - In transit, can arrive
- `in-progress` - Patient onboard, can complete
- `completed` - Ride finished
- `cancelled` - Ride cancelled

---

### Step 4: Test Accept API Directly
```bash
# Using curl or Postman
POST http://localhost:5000/api/v1/ambulance/requests/{booking_id}/accept
Headers:
  Authorization: Bearer {ambulance_token}
```

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "Ride accepted",
  "data": {
    "_id": "booking_id",
    "status": "accepted",
    "acceptedAt": "2026-04-18T12:01:00.000Z"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Booking not found, already accepted by another provider, or not available"
}
```

---

### Step 5: Check Backend Logs
```bash
# In backend console
=== ACCEPT RIDE REQUEST ===
Booking ID: booking_id
Ambulance ID: ambulance_id
Current Status: requested
Provider Match: true
```

---

## 🛠️ Fix for Current Issue

Based on your error, here's what to check:

### 1. Get Booking Details
```javascript
// In MongoDB or backend
db.bookings.findOne({_id: ObjectId("69e31906125306436d72ebaf")})
```

### 2. Check Status
```javascript
// If status is NOT 'requested', that's the issue
if (booking.status !== 'requested') {
  console.log('Booking already processed:', booking.status);
}
```

### 3. Verify Provider
```javascript
// Check if provider matches
console.log('Booking Provider:', booking.provider);
console.log('Ambulance ID:', ambulance_id);
console.log('Match:', booking.provider.toString() === ambulance_id.toString());
```

### 4. Solution Options

**Option A: If Already Accepted**
```dart
// Skip accept, go to start
if (booking['status'] == 'accepted' || booking['status'] == 'confirmed') {
  await ambulanceService.startRide(booking_id);
}
```

**Option B: If Provider Mismatch**
```dart
// This booking is not for you
// Should not appear in your list
// Check getRideRequests filter
```

**Option C: If Status is Wrong**
```dart
// Refresh the list
await _loadRides();
// Check current status
print('Current Status: ${booking['status']}');
```

---

## 📱 Frontend Implementation

### Proper Error Handling
```dart
Future<void> _acceptRide(String bookingId) async {
  try {
    await _ambulanceService.acceptRideRequest(bookingId);
    
    // Success - refresh list
    await _loadRides();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ride accepted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Check error type
    if (e.toString().contains('already accepted')) {
      // Booking already accepted - refresh to get current status
      await _loadRides();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking already accepted. Refreshing...'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (e.toString().contains('not assigned')) {
      // Not your booking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This booking is not assigned to you'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Other error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## ✅ Verification Checklist

Before accepting a ride, verify:

- [ ] Booking exists in database
- [ ] Booking status is `'requested'`
- [ ] Provider ID matches ambulance ID
- [ ] Ambulance is available (`isAvailable: true`)
- [ ] Ambulance account is approved
- [ ] No conflicting active rides
- [ ] Token is valid and not expired

---

## 🎯 Quick Fix Summary

**If you're getting 500 error on accept:**

1. **Check booking status** - If not `'requested'`, it's already processed
2. **Verify provider** - Ensure booking is assigned to you
3. **Refresh list** - Get latest booking data
4. **Check logs** - Backend logs show exact error
5. **Test directly** - Use Postman to test API

**Most Common Cause:**
- Booking was already accepted (status changed)
- Solution: Refresh the list and proceed to next step (Start Ride)

---

**Document Version:** 1.0  
**Last Updated:** April 18, 2026  
**Maintained By:** OnMint Development Team
