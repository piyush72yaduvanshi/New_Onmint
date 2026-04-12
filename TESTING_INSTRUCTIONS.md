# Testing Instructions for OnMint User Registration

## What I Fixed

1. **Added Console Logging**: The app now logs detailed information about API requests and responses to help debug issues.

2. **Created Mock Service**: Since there's no backend server running, I created a mock service that simulates the backend API responses.

3. **Enhanced Error Handling**: Better error messages are now shown to users when registration fails.

## How to Test Registration

### 1. Open Browser Console
- Open Chrome DevTools (F12)
- Go to the Console tab
- You'll see detailed logs about the registration process

### 2. Test Successful Registration
Use the registration data you provided:
- **Email**: `patient.rahul1@gmail.com`
- **Password**: `Secure@Pass123`
- **First Name**: `Rahul`
- **Last Name**: `Gupta`
- **Phone**: `9987471122`
- **City**: `Lucknow`
- **State**: `Uttar Pradesh`
- **Pincode**: `226001`

### 3. What You'll See in Console
Look for these log messages:
```
🚀 Attempting registration with data: {...}
🔐 Starting registration process...
📝 Registration data: {...}
🎭 Using mock service for registration
🎭 Mock Service: Handling registration request
✅ Mock Service: Registration successful
📊 Registration result: Success=true, StatusCode=201
✅ Registration successful
🎉 Registration successful, navigating to home
```

### 4. Test Error Cases
Try these to test error handling:
- **Email already exists**: Use `test@example.com` as email
- **Missing fields**: Leave any required field empty
- **Invalid phone**: Use less than 10 digits

### 5. Expected Behavior
- **Success**: App should navigate to home screen
- **Error**: Detailed error message should appear in a snackbar

## Mock Service Features

The mock service simulates:
- ✅ Field validation
- ✅ Email uniqueness check
- ✅ Realistic response delays
- ✅ JWT token generation
- ✅ User data creation

## Switching to Real Backend

When you have a backend server:
1. Set `mockMode = false` in `shared_packages/api_client/lib/src/api_config.dart`
2. Update `baseUrl` to your actual backend URL
3. The app will automatically use the real API

## Console Commands

While the app is running, you can use:
- `r` - Hot reload
- `R` - Hot restart
- `c` - Clear console
- `q` - Quit app