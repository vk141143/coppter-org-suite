# 2-Step OTP Login Flow - Fixed Implementation

## Problem Fixed
The app was incorrectly trying to save a token after Step 1 (request OTP), but Step 1 does NOT return a token. The token is only returned in Step 2 (verify OTP).

## Correct Flow

### Registration Flow
```
REGISTER → VERIFY REGISTRATION OTP → VERIFY LOGIN OTP → TOKEN SAVED → DASHBOARD
```

### Login Flow (Returning Users)
```
ENTER PHONE → REQUEST LOGIN OTP → VERIFY LOGIN OTP → TOKEN SAVED → DASHBOARD
```

## API Endpoints

### Step 1: Request Login OTP
**Endpoint:** `POST /api/auth/login/customer/`

**Request:**
```json
{
  "phone_number": "+1234567890"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```
**Note:** NO TOKEN returned ❌

### Step 2: Verify Login OTP
**Endpoint:** `POST /api/auth/verify-login-otp/`

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
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "customer": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890"
  }
}
```
**Note:** TOKEN IS returned ✅

## Updated Code

### CustomerApiService - New Methods

#### 1. requestLoginOtp() - Step 1
```dart
Future<Map<String, dynamic>> requestLoginOtp({
  required String phoneNumber,
}) async {
  final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/login/customer/');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'phone_number': phoneNumber,
    }),
  );
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(response.body);
    
    // NO TOKEN SAVED HERE - OTP is just sent
    return {
      'success': true,
      'message': data['message'] ?? 'OTP sent successfully',
      'phone_number': phoneNumber,
    };
  } else {
    throw Exception('Failed to send OTP');
  }
}
```

#### 2. verifyLoginOtp() - Step 2
```dart
Future<Map<String, dynamic>> verifyLoginOtp({
  required String phoneNumber,
  required String otp,
}) async {
  final url = Uri.parse('${AppConfig.customerBaseUrl}/auth/verify-login-otp/');
  
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'phone_number': phoneNumber,
      'otp_code': otp,
    }),
  );
  
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final data = jsonDecode(response.body);
    
    // TOKEN IS SAVED HERE ✅
    if (data['token'] != null) {
      await _saveToken(data['token']);
    }
    if (data['customer'] != null) {
      await _saveUserData(data['customer']);
    }
    
    return {
      'success': true,
      'message': data['message'] ?? 'Login successful',
      'token': data['token'],
      'customer': data['customer'],
    };
  } else {
    throw Exception('OTP verification failed');
  }
}
```

### UI Flow

#### Customer Login Screen
```dart
Future<void> _login() async {
  final customerService = CustomerApiService();
  
  // Step 1: Request OTP
  final response = await customerService.requestLoginOtp(
    phoneNumber: phoneController.text.trim(),
  );
  
  // Navigate to OTP screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OTPScreen(
        phoneNumber: phoneController.text.trim(),
        userType: 'Customer',
        isRegistration: false, // Important: false for login
      ),
    ),
  );
}
```

#### OTP Screen
```dart
Future<void> _handleVerifyOTP() async {
  final customerService = CustomerApiService();
  
  if (widget.isRegistration) {
    // Registration flow: verify registration OTP then login
    response = await customerService.verifyOTPAndLogin(
      phoneNumber: widget.phoneNumber,
      otp: otp,
    );
  } else {
    // Login flow: verify login OTP (token returned here)
    response = await customerService.verifyLoginOtp(
      phoneNumber: widget.phoneNumber,
      otp: otp,
    );
  }
  
  // Token is now saved, navigate to dashboard
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const UserDashboard()),
    (route) => false,
  );
}
```

## Key Differences

### ❌ OLD (Incorrect)
```dart
// Step 1: Request OTP
loginCustomer(phoneNumber) {
  // Tried to save token here - WRONG!
  // Step 1 doesn't return token
}
```

### ✅ NEW (Correct)
```dart
// Step 1: Request OTP
requestLoginOtp(phoneNumber) {
  // Only sends OTP, no token saved
}

// Step 2: Verify OTP
verifyLoginOtp(phoneNumber, otp) {
  // Token is returned and saved here ✅
}
```

## Debug Logs

### Correct Login Flow Logs:
```
🔐 Step 1: Request OTP
📡 POST Request: http://13.232.82.200:8000/api/auth/login/customer/
📤 Payload: {"phone_number": "+1234567890"}
📥 Response status: 200
📥 Response body: {"success": true, "message": "OTP sent"}

🔐 Step 2: Verify OTP and Get Token
📡 POST Request: http://13.232.82.200:8000/api/auth/verify-login-otp/
📤 Payload: {"phone_number": "+1234567890", "otp_code": "123456"}
📥 Response status: 200
📥 Response body: {"success": true, "token": "eyJ...", "customer": {...}}
💾 Token saved successfully
💾 Customer data saved successfully
```

## Testing Checklist

- [ ] Enter phone number on login screen
- [ ] Click "Send OTP"
- [ ] Check console: "Step 1: Request OTP"
- [ ] Verify NO token saved after Step 1
- [ ] Receive OTP on phone
- [ ] Enter OTP on OTP screen
- [ ] Check console: "Step 2: Verify OTP and Get Token"
- [ ] Verify token IS saved after Step 2
- [ ] User redirected to dashboard
- [ ] Token persists after app restart

## Summary

✅ **Step 1** (`requestLoginOtp`): Sends phone number → OTP sent (NO token)
✅ **Step 2** (`verifyLoginOtp`): Sends phone + OTP → Token returned and saved
✅ **Token saved ONLY in Step 2**
✅ **"NO TOKEN FOUND" error fixed**

The flow now correctly matches your backend's 2-step OTP authentication!
