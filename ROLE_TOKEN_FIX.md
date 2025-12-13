# Role + Token Mix-up Fix

## Problem
App always loaded `role: admin` even when logging in as customer because:
1. Old `user_role` key was shared across all user types
2. Role wasn't cleared when switching between user types
3. Token storage didn't clear other roles when saving new token

## Solution

### 1. Separate Token + Role Keys

**Before:**
```
auth_token → single token for all users
user_role → single role for all users
```

**After:**
```
customer_token → customer JWT token
customer_role → "customer"
admin_token → admin JWT token
admin_role → "admin"
driver_token → driver JWT token
driver_role → "driver"
```

### 2. Auto-Clear on Login

When saving a customer token:
```dart
// Clear admin/driver tokens and roles
await TokenStorageImpl.clearToken(_adminTokenKey);
await TokenStorageImpl.clearToken(_driverTokenKey);
await TokenStorageImpl.clearToken(_adminRoleKey);
await TokenStorageImpl.clearToken(_driverRoleKey);

// Save customer token and role
await TokenStorageImpl.saveToken(_customerTokenKey, token);
await TokenStorageImpl.saveToken(_customerRoleKey, 'customer');
```

### 3. Auto-Detect Role

**New getUserRole() logic:**
```dart
static Future<String?> getUserRole() async {
  // Check which token exists
  final adminToken = await TokenStorageImpl.getToken(_adminTokenKey);
  if (adminToken != null && adminToken.isNotEmpty) {
    return 'admin';
  }
  
  final customerToken = await TokenStorageImpl.getToken(_customerTokenKey);
  if (customerToken != null && customerToken.isNotEmpty) {
    return 'customer';
  }
  
  final driverToken = await TokenStorageImpl.getToken(_driverTokenKey);
  if (driverToken != null && driverToken.isNotEmpty) {
    return 'driver';
  }
  
  return null;
}
```

### 4. Auto-Detect Token

**New getToken() logic:**
```dart
static Future<String?> getToken({String? forRole}) async {
  if (forRole == 'customer') {
    return await TokenStorageImpl.getToken(_customerTokenKey);
  } else if (forRole == 'admin') {
    return await TokenStorageImpl.getToken(_adminTokenKey);
  } else if (forRole == 'driver') {
    return await TokenStorageImpl.getToken(_driverTokenKey);
  } else {
    // Auto-detect: check which token exists
    final adminToken = await TokenStorageImpl.getToken(_adminTokenKey);
    if (adminToken != null && adminToken.isNotEmpty) {
      return adminToken;
    }
    
    final customerToken = await TokenStorageImpl.getToken(_customerTokenKey);
    if (customerToken != null && customerToken.isNotEmpty) {
      return customerToken;
    }
    
    final driverToken = await TokenStorageImpl.getToken(_driverTokenKey);
    if (driverToken != null && driverToken.isNotEmpty) {
      return driverToken;
    }
  }
  return null;
}
```

### 5. Removed Old Keys

**Removed from all services:**
- `user_role` key (replaced with customer_role, admin_role, driver_role)
- Shared token storage (replaced with role-specific tokens)

**Updated files:**
- `lib/core/utils/token_storage.dart` - Separate keys + auto-detection
- `lib/core/services/auth_service.dart` - Removed old role storage
- `lib/core/services/customer_api_service.dart` - Removed user_role writes
- `lib/core/services/api_helper.dart` - Uses new getUserRole()

### 6. Reduced Logging

**Before:**
```
🔍 Role from storage: admin  (even when no admin token exists)
```

**After:**
```
🔍 Active role: customer  (only when customer token exists)
```

## How It Works Now

### Customer Login Flow
```
1. User clicks "Login as Customer"
2. Enter phone + OTP
3. Backend returns JWT with role: "customer"
4. TokenStorage.saveToken(token, role: 'customer')
   → Clears admin_token, admin_role, driver_token, driver_role
   → Saves customer_token, customer_role
5. getUserRole() returns "customer"
6. API calls use customer_token
```

### Admin Login Flow
```
1. User clicks "Login as Admin"
2. Enter phone + OTP
3. Backend returns JWT with role: "admin"
4. TokenStorage.saveToken(token, role: 'admin')
   → Clears customer_token, customer_role, driver_token, driver_role
   → Saves admin_token, admin_role
5. getUserRole() returns "admin"
6. API calls use admin_token
```

### Role Detection Priority
```
1. Check admin_token exists → role = "admin"
2. Else check customer_token exists → role = "customer"
3. Else check driver_token exists → role = "driver"
4. Else return null
```

## Testing

### Verify Customer Login
```dart
// Login as customer
await authService.login(phone, 'customer');
await authService.verifyOTP(phone, otp, endpoint, userType: 'customer');

// Check role
final role = await TokenStorage.getUserRole();
assert(role == 'customer');

// Check token
final token = await TokenStorage.getToken();
final payload = TokenStorage.decodeJWT(token!);
assert(payload['role'] == 'customer');

// Verify admin token cleared
final adminToken = await TokenStorage.getToken(forRole: 'admin');
assert(adminToken == null);
```

### Verify Admin Login
```dart
// Login as admin
await authService.login(phone, 'admin');
await authService.verifyOTP(phone, otp, endpoint, userType: 'admin');

// Check role
final role = await TokenStorage.getUserRole();
assert(role == 'admin');

// Check token
final token = await TokenStorage.getToken();
final payload = TokenStorage.decodeJWT(token!);
assert(payload['role'] == 'admin');

// Verify customer token cleared
final customerToken = await TokenStorage.getToken(forRole: 'customer');
assert(customerToken == null);
```

## Benefits

1. ✅ No more role mix-ups
2. ✅ Automatic role detection
3. ✅ Automatic token selection
4. ✅ Clean separation between user types
5. ✅ No manual role management needed
6. ✅ Reduced logging noise

## Migration Notes

- Old `user_role` key is no longer used
- Old `auth_token` key is no longer used
- Existing users will need to re-login
- All tokens are now role-specific
- Role is auto-detected from existing tokens
