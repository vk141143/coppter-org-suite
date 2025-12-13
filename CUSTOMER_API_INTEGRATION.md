# Customer Backend API Integration Guide

## Overview
Complete integration of customer backend API (`http://13.232.82.200:8000/api`) into the Flutter app.

## Files Created

### 1. Core Service
**File:** `lib/core/services/customer_api_service.dart`

Production-ready service class with:
- JWT token management (stored in SharedPreferences)
- Error handling for 400, 401, 500 status codes
- Three main functions:
  - `registerCustomer()` - POST `/auth/register/customer/`
  - `loginCustomer()` - POST `/auth/login/customer/`
  - `getCustomerProfile()` - GET `/customer/profile/`

### 2. Validators
**File:** `lib/core/utils/customer_validators.dart`

Form validation rules:
- Email validation (regex pattern)
- Password validation (min 6 characters)
- Name validation (min 2 characters)
- Phone validation (min 10 digits)
- **Address validation (min 10 characters)** ✓

### 3. UI Screens

#### Register Screen
**File:** `lib/features/auth/screens/register_screen.dart` (Updated)
- Complete registration form with validation
- Calls `CustomerApiService.registerCustomer()`
- Navigates to login after successful registration
- Shows error messages via SnackBar

#### Login Screen
**File:** `lib/features/auth/screens/customer_email_login_screen.dart`
- Email/password login form
- Calls `CustomerApiService.loginCustomer()`
- **Navigates to UserDashboard after successful login** ✓
- JWT token automatically stored

#### Profile Screen
**File:** `lib/features/user/screens/customer_profile_fetch_screen.dart`
- Fetches and displays customer profile
- Auto-includes JWT token in Authorization header
- Handles 401 errors (redirects to login)
- Logout functionality

## Usage Examples

### 1. Register a Customer
```dart
import 'package:your_app/core/services/customer_api_service.dart';

final customerService = CustomerApiService();

try {
  final response = await customerService.registerCustomer(
    name: 'John Doe',
    email: 'john@example.com',
    phone: '1234567890',
    password: 'password123',
    address: '123 Main Street, City, State',
  );
  
  if (response['success'] == true) {
    print('Registration successful!');
    // Token is automatically saved
  }
} catch (e) {
  print('Error: $e');
}
```

### 2. Login a Customer
```dart
try {
  final response = await customerService.loginCustomer(
    email: 'john@example.com',
    password: 'password123',
  );
  
  if (response['success'] == true) {
    // Navigate to dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserDashboard()),
    );
  }
} catch (e) {
  print('Login failed: $e');
}
```

### 3. Get Customer Profile
```dart
try {
  final profile = await customerService.getCustomerProfile();
  
  print('Name: ${profile['name']}');
  print('Email: ${profile['email']}');
  print('Phone: ${profile['phone']}');
  print('Address: ${profile['address']}');
} catch (e) {
  if (e.toString().contains('Unauthorized')) {
    // Redirect to login
  }
}
```

## JWT Token Management

### How Tokens are Stored
- Tokens are saved in `SharedPreferences` with key `customer_token`
- Automatically saved after successful login/registration
- Automatically included in API requests via `Authorization: Bearer <token>` header

### Token Lifecycle
```dart
// Check if user is logged in
final isLoggedIn = await customerService.isLoggedIn();

// Logout (clears token)
await customerService.logout();
```

## Error Handling

### 400 - Validation Error
```dart
try {
  await customerService.registerCustomer(...);
} catch (e) {
  // Shows: "Invalid input data" or backend message
}
```

### 401 - Unauthorized
```dart
try {
  await customerService.getCustomerProfile();
} catch (e) {
  // Shows: "Unauthorized. Please login again"
  // Token is automatically cleared
  // Redirect user to login screen
}
```

### 500 - Server Error
```dart
try {
  await customerService.loginCustomer(...);
} catch (e) {
  // Shows: "Server error. Please try again later"
}
```

## Navigation Flow

### After Successful Login
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const UserDashboard()),
);
```

### After Session Expires (401)
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const CustomerEmailLoginScreen()),
);
```

## Integration Steps

### 1. Add to Your App
Navigate from existing screens:
```dart
// From main login screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CustomerEmailLoginScreen(),
  ),
);

// From dashboard to profile
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const CustomerProfileFetchScreen(),
  ),
);
```

### 2. Update Existing Register Screen
The existing `register_screen.dart` has been updated to use `CustomerApiService` instead of the old `AuthService` for customer registration.

### 3. Test the Integration
```dart
// Test registration
final service = CustomerApiService();
await service.registerCustomer(
  name: 'Test User',
  email: 'test@example.com',
  phone: '1234567890',
  password: 'test123',
  address: '123 Test Street, Test City',
);

// Test login
await service.loginCustomer(
  email: 'test@example.com',
  password: 'test123',
);

// Test profile fetch
final profile = await service.getCustomerProfile();
print(profile);
```

## API Endpoints Used

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/register/customer/` | Register new customer |
| POST | `/auth/login/customer/` | Login with email/password |
| GET | `/customer/profile/` | Get customer profile (requires JWT) |

## Base URL Configuration
The base URL is configured in `lib/core/config/app_config.dart`:
```dart
static const String _customerApiUrl = 'http://13.232.82.200:8000/api';
```

## Production Ready Features
✅ Complete error handling (400, 401, 500)  
✅ JWT token storage and management  
✅ Form validation (address min 10 chars)  
✅ Navigation flow after login  
✅ Session expiry handling  
✅ Clean, maintainable code  
✅ Debug logging for development  
✅ User data caching in SharedPreferences  

## Next Steps
1. Test with your backend API
2. Customize error messages if needed
3. Add additional endpoints as required
4. Implement refresh token logic if needed
