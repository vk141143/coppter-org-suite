# Profile API Integration

## API Details
- **Endpoint**: `GET http://43.205.99.220:8000/api/profile/`
- **Method**: GET
- **Authentication**: Required (Bearer Token)
- **Headers**: 
  - `accept: application/json`
  - `Authorization: Bearer <token>`

## Response Structure
```json
{
  "email": "user@example.com",
  "full_name": "string",
  "phone_number": "string",
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "role": "customer",
  "is_approved": true,
  "is_active": true,
  "date_joined": "2025-12-10T19:27:11.175Z",
  "company_id": 0,
  "technician_type": "string"
}
```

## Integration Status: ✅ COMPLETED

### Files Updated:

1. **lib/core/services/auth_service.dart**
   - ✅ Updated `getUserProfile()` to use `/profile/` endpoint
   - ✅ Sends authentication token in header

2. **lib/features/user/screens/user_profile_mobile.dart**
   - ✅ Added `_loadProfile()` method to fetch profile data
   - ✅ Added loading state with CircularProgressIndicator
   - ✅ Displays all profile fields from API:
     - `full_name`
     - `email`
     - `phone_number`
     - `role` (displayed as badge)
     - `is_active` (displayed as status badge)
   - ✅ Pre-fills edit dialog with API data

3. **lib/features/user/screens/user_profile_web.dart**
   - ✅ Same updates as mobile version
   - ✅ Displays profile data in web layout
   - ✅ Shows user ID from API

## How It Works:

1. User navigates to Profile screen
2. `initState()` calls `_loadProfile()`
3. `_loadProfile()` calls `AuthService.getUserProfile()`
4. API request sent to `GET /profile/` with Bearer token
5. On success:
   - Profile data stored in `_profileData`
   - UI updated with real data
   - Loading state removed
6. On error:
   - Loading state removed
   - Shows default/empty values

## Displayed Fields:

### Mobile & Web Profile:
- **Full Name** - from `full_name`
- **Email** - from `email`
- **Phone Number** - from `phone_number`
- **Role Badge** - from `role` (CUSTOMER, DRIVER, etc.)
- **Status Badge** - from `is_active` (ACTIVE/INACTIVE)
- **User ID** - from `id` (web only)

### Additional Fields Available (not displayed yet):
- `is_approved`
- `date_joined`
- `company_id`
- `technician_type`

## Authentication Flow:

⚠️ **IMPORTANT**: The profile API requires authentication token.

### Current Flow:
```
Registration → OTP Sent → OTP Verification → Token Received → Profile API Works
```

### What's Needed:
You need to provide the **OTP Verification API** endpoint that returns the authentication token:

**Expected OTP Verification API:**
- Endpoint: `/auth/verify-otp/` or similar
- Method: POST
- Body:
```json
{
  "phone_number": "+1234567890",
  "otp": "1234",
  "user_type": "customer"
}
```
- Response should include:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { ... }
}
```

Once you provide the OTP verification endpoint, we can complete the authentication flow and the profile API will work perfectly!

## Testing (After OTP Verification is Implemented):

1. Register a new customer
2. Verify OTP (token will be saved)
3. Navigate to Profile screen
4. Profile data should load from API
5. All fields should display correctly

## Error Handling:

- If no token: Shows default values
- If API fails: Shows default values
- If network error: Shows default values
- Loading state shown while fetching

## Next Steps:

1. ✅ Profile API integrated
2. ⏳ Need OTP Verification API endpoint
3. ⏳ After OTP verification, token will be saved
4. ✅ Profile will automatically fetch and display data
