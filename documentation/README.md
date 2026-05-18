# 📚 OnMint Healthcare API Documentation

Welcome to the OnMint Healthcare Platform API documentation. This folder contains comprehensive guides for all APIs across the platform.

---

## 📁 Documentation Files

| File | Description | Status |
|------|-------------|--------|
| `API_IMPLEMENTATION_STATUS.md` | Complete API tracking across all modules | ✅ Active |
| `AMBULANCE_VENDOR_API_GUIDE.md` | Detailed guide for all 22 ambulance APIs | ✅ Complete |
| `INSTANT_BOOKING_QUICK_START.md` | Quick start guide for emergency booking | ✅ Complete |

---

## 🎯 Quick Stats

### Overall Platform:
- **Total APIs:** 177
- **Backend Complete:** 177/177 (100%)
- **Frontend Complete:** 153/177 (86%)

### By Module:
| Module | APIs | Backend | Frontend | Status |
|--------|------|---------|----------|--------|
| Patient | 25 | ✅ 100% | ✅ 100% | Complete |
| Ambulance Vendor | 22 | ✅ 100% | ✅ 100% | Complete |
| Doctor Vendor | 18 | ✅ 100% | ⚠️ 83% | In Progress |
| Nurse Vendor | 15 | ✅ 100% | ⚠️ 80% | In Progress |
| Pharmacist Vendor | 20 | ✅ 100% | ⚠️ 80% | In Progress |
| Pathology Vendor | 16 | ✅ 100% | ⚠️ 81% | In Progress |
| Blood Bank Vendor | 14 | ✅ 100% | ⚠️ 71% | In Progress |
| Admin | 35 | ✅ 100% | ⚠️ 80% | In Progress |
| Authentication | 12 | ✅ 100% | ✅ 100% | Complete |

---

## 🚀 Recently Completed

### April 18, 2026:
- ✅ **All 22 Ambulance Vendor APIs** - Complete implementation
- ✅ **Emergency Booking Rate Limit Fix** - Increased from 5/hour to 100/15min
- ✅ **Instant Booking Feature** - Simplified 2-field emergency booking
- ✅ **Dashboard Location Fix** - Real GPS instead of hardcoded Mumbai
- ✅ **Blood Bank Search & Booking** - Full implementation

---

## 📖 How to Use This Documentation

### For Developers:
1. Check `API_IMPLEMENTATION_STATUS.md` to see which APIs are available
2. Read module-specific guides (e.g., `AMBULANCE_VENDOR_API_GUIDE.md`)
3. Use the code examples provided in each guide
4. Refer to backend files for detailed implementation

### For Project Managers:
1. Review `API_IMPLEMENTATION_STATUS.md` for progress tracking
2. Check completion percentages by module
3. Identify pending work items
4. Plan sprint priorities based on completion status

### For QA/Testing:
1. Use the API guides to understand expected behavior
2. Test all endpoints listed in each module
3. Verify status transitions (e.g., ride status flow)
4. Check error handling and edge cases

---

## 🔗 Quick Links

### Backend:
- **Base URL (Dev):** `http://localhost:5000/api/v1`
- **Base URL (Prod):** `https://api.onmint.healthcare/api/v1`
- **Controllers:** `Ourdeals_Healthcare/src/controller/`
- **Routes:** `Ourdeals_Healthcare/src/routes/`
- **Services:** `Ourdeals_Healthcare/src/services/`

### Frontend:
- **API Services:** `New_Onmint/shared_packages/api_client/lib/src/services/`
- **User App:** `New_Onmint/user_app/`
- **Vendor App:** `New_Onmint/vendor_app/`
- **Admin App:** `New_Onmint/admin_app/`

---

## 🛠️ Tech Stack

### Backend:
- Node.js + Express.js
- MongoDB + Mongoose
- JWT Authentication
- AWS S3 (File Storage)
- AWS SNS (Notifications)
- Socket.io (Real-time)

### Frontend:
- Flutter (Dart)
- Provider (State Management)
- Dio (HTTP Client)
- Geolocator (GPS)
- Shared Packages Architecture

---

## 📝 API Naming Conventions

### Endpoints:
- **GET** - Retrieve data (e.g., `/ambulance/requests`)
- **POST** - Create or trigger action (e.g., `/ambulance/requests/:id/accept`)
- **PUT** - Update data (e.g., `/ambulance/profile`)
- **DELETE** - Remove data (e.g., `/patient/documents/:id`)

### Status Codes:
- **200** - Success
- **201** - Created
- **400** - Bad Request
- **401** - Unauthorized
- **403** - Forbidden
- **404** - Not Found
- **429** - Too Many Requests
- **500** - Server Error

---

## 🔐 Authentication

All protected endpoints require JWT token in header:
```
Authorization: Bearer <access_token>
```

### Token Refresh:
When access token expires, use refresh token:
```dart
final tokens = await apiService.refreshToken(refreshToken);
```

---

## 📊 Response Format

### Success Response:
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Error details"
}
```

### Paginated Response:
```json
{
  "success": true,
  "message": "Data fetched",
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

## 🧪 Testing

### Start Backend:
```bash
cd Ourdeals_Healthcare
npm install
npm start
```

### Start Frontend:
```bash
# User App
cd New_Onmint/user_app
flutter run -d chrome

# Vendor App
cd New_Onmint/vendor_app
flutter run -d chrome

# Admin App
cd New_Onmint/admin_app
flutter run -d chrome
```

### Test Credentials:

**Patient:**
- Email: `patient12@example.com`
- Password: `password123`

**Ambulance:**
- Email: `quickresponse.amulance25@healthcare.com`
- Password: `password123`

**Doctor:**
- Email: `doctor@example.com`
- Password: `password123`

**Admin:**
- Email: `admin@onmint.com`
- Password: `admin123`

---

## 📞 Support

For questions or issues:
- **Email:** dev@onmint.healthcare
- **Slack:** #api-support
- **GitHub Issues:** [Create Issue](https://github.com/onmint/healthcare/issues)

---

## 📅 Update Schedule

This documentation is updated:
- ✅ After each API implementation
- ✅ After major feature releases
- ✅ When API contracts change
- ✅ Monthly comprehensive review

**Last Updated:** April 18, 2026  
**Next Review:** May 1, 2026

---

## ✅ Completion Milestones

- [x] Authentication APIs (12/12) - 100%
- [x] Patient APIs (25/25) - 100%
- [x] Ambulance Vendor APIs (22/22) - 100%
- [ ] Doctor Vendor APIs (15/18) - 83%
- [ ] Nurse Vendor APIs (12/15) - 80%
- [ ] Pharmacist Vendor APIs (16/20) - 80%
- [ ] Pathology Vendor APIs (13/16) - 81%
- [ ] Blood Bank Vendor APIs (10/14) - 71%
- [ ] Admin APIs (28/35) - 80%

---

**Version:** 1.0  
**Maintained By:** OnMint Development Team  
**License:** Proprietary
