# Customer Registration API Integration

## API Details
- **Endpoint**: `http://43.205.99.220:8000/api/auth/register/customer/`
- **Method**: POST
- **Content-Type**: application/json

## Request Body
```json
{
  "full_name": "string",
  "email": "user@example.com",
  "phone_number": "+29732784",
  "address": "stringstri",
  "password": "string"
}
```

## Integration Status: ✅ COMPLETED

### Files Updated:

1. **lib/core/config/app_config.dart**
   - Updated base URL from `http://13.201.134.175:8001/api` to `http://43.205.99.220:8000/api`

2. **.env**
   - Updated BASE_URL to `http://43.205.99.220:8000/api`

3. **lib/core/services/auth_service.dart**
   - `registerCustomer()` method already exists and properly configured
   - Sends POST request to `/auth/register/customer/`
   - Maps form fields to API requirements:
     - `full_name` ← Full Name field
     - `email` ← Email Address field
     - `phone_number` ← Phone Number field
     - `address` ← Address field
     - `password` ← Password field
   - Handles token storage on successful registration
   - Handles user ID storage from response

### Registration Screens Using the API:

1. **lib/features/auth/screens/register_screen.dart** (Mobile)
   - Form validation for all required fields
   - Calls `authService.registerCustomer()` on submit
   - Shows success/error messages
   - Navigates to UserDashboard on success

2. **lib/features/auth/screens/web/register_form_panel.dart** (Web)
   - Same functionality as mobile version
   - Responsive design for web
   - Calls same `authService.registerCustomer()` method

## How It Works:

1. User fills registration form with:
   - Full Name
   - Email Address
   - Phone Number
   - Address
   - Password
   - Confirm Password

2. Form validates all fields

3. On submit, `AuthService.registerCustomer()` is called

4. API request is sent to `http://43.205.99.220:8000/api/auth/register/customer/`

5. On success:
   - Token is stored in SharedPreferences
   - User ID is stored
   - User is redirected to Dashboard
   - Success message is shown

6. On error:
   - Error message is displayed to user
   - User can retry registration

## Testing:

To test the integration:
1. Run the app
2. Navigate to Registration screen
3. Fill in all required fields
4. Click "Create Account"
5. Check if API call is successful and user is registered

## Notes:

- API timeout is set to 60 seconds (configurable in .env)
- All API calls include proper headers (Content-Type, Accept)
- Error handling is implemented for network issues and API errors
- Token-based authentication is ready for subsequent API calls
