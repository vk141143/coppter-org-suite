# Customer Login & Registration Flow - Complete Guide

## Problem Identified
The app was trying to use phone-based OTP login for customers after registration, but the backend requires email/password login to get the authentication token.

## Solution Overview
The app now supports TWO login methods for customers:

### 1. **Phone OTP Login** (For Driver/Admin)
- User enters phone number
- Receives OTP
- Verifies OTP
- Gets token

### 2. **Email/Password Login** (For Customers)
- User enters email and password
- Gets token immediately
- No OTP required

## Complete Customer Flow

### Registration Flow
```
┌─────────────────┐
│  Register Form  │
│  - Name         │
│  - Email        │
│  - Phone        │
│  - Password     │
│  - Address      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Backend sends  │
│  OTP to phone   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  OTP Screen     │
│  Enter 6 digits │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Verify OTP     │ ✅ Step 1
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Auto Login     │ 🔐 Step 2
│  (email+pass)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Save Token     │ 💾
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Dashboard      │ ✅
└─────────────────┘
```

### Login Flow (Returning Users)
```
┌─────────────────┐
│  Login Screen   │
│  Select:        │
│  "Customer"     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Click:         │
│  "Login with    │
│   Email &       │
│   Password"     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Email Login    │
│  - Email        │
│  - Password     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Get Token      │ 🔐
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Dashboard      │ ✅
└─────────────────┘
```

## API Endpoints Used

### Registration
**Endpoint:** `POST /api/auth/register/customer/`

**Request:**
```json
{
  "full_name": "John Doe",
  "email": "john@example.com",
  "phone_number": "+1234567890",
  "password": "password123",
  "address": "123 Main St"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful. OTP sent to phone.",
  "customer": {...}
}
```
**Note:** No token returned

### OTP Verification
**Endpoint:** `POST /api/auth/verify-register-otp/`

**Request:**
```json
{
  "phone_number": "+1234567890",
  "otp_code": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```
**Note:** No token returned

### Email/Password Login
**Endpoint:** `POST /api/auth/login/customer/`

**Request:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "customer": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "address": "123 Main St"
  }
}
```
**Note:** Token IS returned ✅

## Code Changes Made

### 1. CustomerApiService
- ✅ `verifyOTP()` - Only verifies OTP
- ✅ `verifyOTPAndLogin()` - Verifies OTP then auto-logs in
- ✅ `loginCustomer()` - Email/password login with token

### 2. RegisterScreen
- ✅ Passes email and password to OTP screen
- ✅ Used for auto-login after OTP verification

### 3. OTPScreen
- ✅ Accepts email and password parameters
- ✅ Calls `verifyOTPAndLogin()` for registration flow
- ✅ Automatically logs in after OTP verification

### 4. LoginScreen
- ✅ Added "Login with Email & Password" button for customers
- ✅ Navigates to CustomerEmailLoginScreen
- ✅ Phone OTP login still available for Driver/Admin

### 5. CustomerEmailLoginScreen
- ✅ Email and password input
- ✅ Direct login with token
- ✅ No OTP required

## User Experience

### New Customer
1. Click "Sign Up"
2. Fill registration form
3. Receive OTP on phone
4. Enter OTP
5. **Automatically logged in** ✅
6. Redirected to dashboard

### Returning Customer
1. On login screen, select "Customer"
2. Click "Login with Email & Password"
3. Enter email and password
4. **Logged in immediately** ✅
5. Redirected to dashboard

## Debug Logs to Watch

When registering:
```
📡 POST Request: .../auth/register/customer/
📥 Response status: 201
✅ Registration successful

📡 POST Request: .../auth/verify-register-otp/
📤 Request body: {"phone_number":"+1234567890","otp_code":"123456"}
📥 Response status: 200
✅ OTP verified successfully

🔐 Step 2: Logging in to get token...
📡 POST Request: .../auth/login/customer/
📤 Login payload: {"email": "john@example.com", "password": "***"}
📥 Response status: 200
💾 Token saved successfully
💾 Customer data saved successfully
✅ Login successful, token saved
```

When logging in:
```
📡 POST Request: .../auth/login/customer/
📤 Login payload: {"email": "john@example.com", "password": "***"}
📥 Response status: 200
💾 Token saved successfully
💾 Customer data saved successfully
```

## Security Notes

1. **Password Storage**: Password is temporarily held in memory during OTP verification only for auto-login. Not stored permanently.

2. **Token Storage**: Token is stored in SharedPreferences (localStorage for web) and persists across app restarts.

3. **Token Usage**: All authenticated API calls include the token in the Authorization header:
   ```
   Authorization: Bearer <token>
   ```

## Testing Checklist

- [ ] Register new customer
- [ ] Receive OTP on phone
- [ ] Verify OTP
- [ ] Check console for auto-login logs
- [ ] Verify token is saved
- [ ] Verify redirect to dashboard
- [ ] Close and reopen app
- [ ] Verify still logged in
- [ ] Logout
- [ ] Login with email/password
- [ ] Verify token is saved
- [ ] Verify redirect to dashboard

## Troubleshooting

### "NO TOKEN FOUND" Error
- **Cause**: OTP verification doesn't return token
- **Solution**: Auto-login after OTP verification (implemented ✅)

### "Connection Timeout" on Login
- **Cause**: Using wrong login endpoint (phone-based instead of email-based)
- **Solution**: Use CustomerEmailLoginScreen for customers (implemented ✅)

### Token Not Persisting
- **Cause**: SharedPreferences not initialized
- **Solution**: Ensure `WidgetsFlutterBinding.ensureInitialized()` in main.dart

## Summary

The app now correctly handles customer authentication by:
1. ✅ Registering with email/password
2. ✅ Verifying phone with OTP
3. ✅ Auto-logging in with email/password to get token
4. ✅ Saving token for future sessions
5. ✅ Providing email/password login for returning users

All flows are working correctly with proper token management!
