# Customer Registration Flow - UPDATED

## API Response Structure

### Registration API Response:
```json
{
    "success": true,
    "message": "Customer registered successfully. OTP sent to mobile number.",
    "user_id": "c290e3cb-66ce-4c55-a8e5-7ff95d90cd63",
    "phone_number": "+1234567890",
    "user_data": {
        "id": "c290e3cb-66ce-4c55-a8e5-7ff95d90cd63",
        "full_name": "vishnu vardhn",
        "email": "test@email.com",
        "phone_number": "+1234567890",
        "address": "HSR Layout, Bangalore",
        "is_verified": false,
        "is_active": true
    }
}
```

## Updated Registration Flow

### Step 1: User Registration
1. User fills registration form:
   - Full Name
   - Email Address
   - Phone Number
   - Address
   - Password
   - Confirm Password

2. App sends POST request to: `http://43.205.99.220:8000/api/auth/register/customer/`

3. Backend responds with:
   - `success: true`
   - `message: "Customer registered successfully. OTP sent to mobile number."`
   - `user_id`
   - `phone_number`
   - `user_data` object

### Step 2: OTP Verification
4. App automatically navigates to OTP Screen
5. User enters OTP received on phone
6. App verifies OTP (needs OTP verification endpoint)
7. On successful OTP verification, user is logged in

## Files Updated

### 1. `lib/core/services/auth_service.dart`
- ✅ Updated `registerCustomer()` to handle new response structure
- ✅ Stores `user_id` from response
- ✅ No longer expects `token` in registration response

### 2. `lib/features/auth/screens/register_screen.dart`
- ✅ Updated `_handleRegister()` to check for `success` field
- ✅ Navigates to OTP screen instead of dashboard
- ✅ Shows API message to user

### 3. `lib/features/auth/screens/web/register_form_panel.dart`
- ✅ Same updates as mobile registration screen
- ✅ Consistent flow across mobile and web

## Current Flow:

```
Registration Form
      ↓
   Submit
      ↓
API Call: POST /auth/register/customer/
      ↓
Response: { success: true, user_id: "...", message: "OTP sent..." }
      ↓
Navigate to OTP Screen
      ↓
User enters OTP
      ↓
OTP Verification (needs implementation)
      ↓
Login Success → Dashboard
```

## Next Steps (If OTP Verification API is Available):

You'll need to provide the OTP verification endpoint:
- Endpoint: `/auth/verify-otp/` or similar
- Method: POST
- Body: `{ phone_number: "...", otp: "...", user_type: "customer" }`
- Response: Should include authentication token

Then update `lib/core/services/auth_service.dart` with the correct OTP verification endpoint.

## Testing:

1. Run the app with hot restart
2. Go to Registration screen
3. Fill in all fields
4. Click "Create Account"
5. You should see:
   - Success message: "Customer registered successfully. OTP sent to mobile number."
   - Navigation to OTP screen
   - Phone number pre-filled in OTP screen

## Console Output (Expected):

```
🌐 API Base URL: http://43.205.99.220:8000/api
📡 POST Request: http://43.205.99.220:8000/api/auth/register/customer/
📦 Request Body: {"full_name":"...","email":"...","phone_number":"...","address":"...","password":"..."}
✅ Response: {"success":true,"message":"Customer registered successfully..."}
```
