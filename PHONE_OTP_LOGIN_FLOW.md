# Phone Number + OTP Login Flow

## Updated Flow

The customer login now uses **Phone Number + OTP** instead of email/password.

## Complete Flow

### Registration → OTP → Login
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
│  Login API      │ 🔐 Step 2
│  (phone_number) │
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

## API Endpoints

### 1. Register Customer
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
  "message": "Registration successful. OTP sent."
}
```

### 2. Verify OTP
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

### 3. Login (Get Token)
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

## Code Changes

### CustomerApiService

#### loginCustomer() - Updated
```dart
Future<Map<String, dynamic>> loginCustomer({
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
  
  // ... saves token and customer data
}
```

#### verifyOTPAndLogin() - Simplified
```dart
Future<Map<String, dynamic>> verifyOTPAndLogin({
  required String phoneNumber,
  required String otp,
}) async {
  // Step 1: Verify OTP
  await verifyOTP(phoneNumber: phoneNumber, otp: otp);
  
  // Step 2: Login with phone number to get token
  final loginResponse = await loginCustomer(phoneNumber: phoneNumber);
  
  return loginResponse;
}
```

### OTP Screen - Simplified

No longer needs email/password parameters:

```dart
final response = await customerService.verifyOTPAndLogin(
  phoneNumber: widget.phoneNumber,
  otp: otp,
);
```

### Register Screen - Simplified

No longer passes email/password to OTP screen:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => OTPScreen(
      phoneNumber: _phoneController.text.trim(),
      userType: 'Customer',
      isRegistration: true,
    ),
  ),
);
```

## Debug Logs

When registering and verifying OTP:

```
📡 POST Request: http://13.232.82.200:8000/api/auth/register/customer/
📥 Response status: 201
✅ Registration successful

🔐 Step 1: Verifying OTP...
📡 POST Request: http://13.232.82.200:8000/api/auth/verify-register-otp/
📤 Request body: {"phone_number":"+1234567890","otp_code":"123456"}
📥 Response status: 200
✅ OTP verified successfully

🔐 Step 2: Logging in to get token...
📡 POST Request: http://13.232.82.200:8000/api/auth/login/customer/
📤 Login payload: {"phone_number": "+1234567890"}
📥 Response status: 200
💾 Token saved successfully
💾 Customer data saved successfully
✅ Login successful, token saved
```

## User Experience

1. User registers with full details
2. Receives OTP on phone
3. Enters OTP
4. **Automatically logged in** with phone number
5. Token saved
6. Redirected to dashboard

## Key Points

- ✅ Login uses **phone_number** only (no email/password)
- ✅ Token is obtained after OTP verification
- ✅ Token saved using SharedPreferences
- ✅ Works on Flutter Web
- ✅ Clean error messages
- ✅ Automatic navigation to dashboard

## Testing

1. Full restart the app
2. Register a new customer
3. Enter OTP received on phone
4. Check console for the debug logs above
5. Verify you're on the dashboard
6. Check that token is saved (stays logged in after app restart)

## Summary

The flow is now simplified:
- **Registration**: Collects all user data
- **OTP Verification**: Confirms phone number
- **Login**: Uses phone number to get authentication token
- **Dashboard**: User is logged in with token saved

No email/password needed for login - just phone number + OTP!
