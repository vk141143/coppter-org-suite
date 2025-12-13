# Token Separation Implementation Guide

## Problem
Customer endpoints were receiving 401 "Invalid authentication credentials" because the system was storing and using admin tokens for customer API calls.

## Solution
Implemented role-based token separation with automatic token detection and validation.

---

## Changes Made

### 1. Token Storage (lib/core/utils/token_storage.dart)
**Separated token storage by role:**
- `customer_token` - For customer authentication
- `admin_token` - For admin authentication  
- `driver_token` - For driver authentication

**Key Methods:**
```dart
// Save token with role detection
TokenStorage.saveToken(token, role: 'customer')

// Get token for specific role
TokenStorage.getToken(forRole: 'customer')

// Validate token matches expected role
TokenStorage.validateTokenRole('customer')

// Clear tokens (all or specific role)
TokenStorage.clearToken(role: 'customer')
```

### 2. API Helper (lib/core/services/api_helper.dart)
**NEW FILE** - Auto-detects correct token based on endpoint:

```dart
// Automatically uses customer token
ApiHelper.post('/customer/issue', body: {...})

// Automatically uses admin token
ApiHelper.get('/admin/categories/')

// Automatically uses driver token
ApiHelper.post('/driver/accept-job', body: {...})
```

**Features:**
- Auto-detects role from endpoint path
- Validates token role matches endpoint requirements
- Throws error if wrong token type is used
- Supports GET, POST, PATCH, DELETE methods

### 3. Auth Service (lib/core/services/auth_service.dart)
**Updated to use role-specific token storage:**
- Saves tokens with role parameter
- Gets tokens for specific roles
- Validates token role matches login type

### 4. Category Service (lib/core/services/category_service.dart)
**Migrated to use ApiHelper:**
- Removed manual token handling
- Uses ApiHelper for all requests
- Automatic token selection based on endpoint

### 5. Web Pricing Estimator (lib/features/raise_complaint/widgets/web_pricing_estimator.dart)
**Updated to use ApiHelper:**
- Validates customer token exists before API call
- Uses ApiHelper.post() for customer/issue endpoint
- Automatic customer token injection

### 6. Raise Complaint Screen (lib/features/raise_complaint/screens/raise_complaint_web.dart)
**Added customer access validation:**
- Validates customer token on screen load
- Redirects if no valid customer token
- Shows error message for authentication issues

---

## How It Works

### Token Storage Flow
```
Login as Customer → JWT contains role: "customer" → Saved to customer_token
Login as Admin → JWT contains role: "admin" → Saved to admin_token
Login as Driver → JWT contains role: "driver" → Saved to driver_token
```

### API Request Flow
```
1. ApiHelper receives endpoint: "/customer/issue"
2. Detects role from path: "customer"
3. Gets token: TokenStorage.getToken(forRole: 'customer')
4. Validates token role matches endpoint
5. Adds Authorization header: "Bearer <customer_token>"
6. Makes request
```

### Validation Flow
```
1. Screen loads (e.g., RaiseComplaintWeb)
2. Calls ApiHelper.hasValidToken('customer')
3. If no valid customer token → Show error + redirect
4. If valid customer token → Allow access
```

---

## Usage Examples

### Making API Calls

**Customer Endpoint:**
```dart
// Old way (WRONG)
final token = await TokenStorage.getToken();
final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

// New way (CORRECT)
final response = await ApiHelper.post('/customer/issue', body: {...});
```

**Admin Endpoint:**
```dart
// Automatically uses admin token
final response = await ApiHelper.get('/admin/categories/');
```

### Validating Access

**In Screen initState:**
```dart
@override
void initState() {
  super.initState();
  _validateCustomerAccess();
}

Future<void> _validateCustomerAccess() async {
  final hasToken = await ApiHelper.hasValidToken('customer');
  if (!hasToken) {
    // Show error and redirect
  }
}
```

### Checking Current Role

```dart
final role = await ApiHelper.getCurrentRole();
print('Current user role: $role'); // customer, admin, or driver
```

---

## Migration Guide

### For Existing API Calls

**Step 1:** Replace manual token retrieval
```dart
// Before
final token = await TokenStorage.getToken();

// After
// No need - ApiHelper handles it
```

**Step 2:** Replace http calls with ApiHelper
```dart
// Before
final response = await http.post(
  Uri.parse('http://13.233.195.173:8000/api/customer/issue'),
  headers: {'Authorization': 'Bearer $token'},
  body: jsonEncode(data),
);

// After
final response = await ApiHelper.post('/customer/issue', body: data);
```

**Step 3:** Add role validation to screens
```dart
@override
void initState() {
  super.initState();
  _validateAccess(); // Add this
}

Future<void> _validateAccess() async {
  final hasToken = await ApiHelper.hasValidToken('customer'); // or 'admin', 'driver'
  if (!hasToken) {
    // Handle unauthorized access
  }
}
```

---

## Error Handling

### Common Errors

**1. "Invalid token: Customer endpoint requires customer token, but got admin token"**
- **Cause:** Admin token being used for customer endpoint
- **Fix:** Login as customer, not admin

**2. "Customer authentication required"**
- **Cause:** No customer token found
- **Fix:** Login as customer first

**3. "401 Invalid authentication credentials"**
- **Cause:** Token expired or invalid
- **Fix:** Re-login to get fresh token

---

## Testing

### Verify Token Separation
```dart
// Login as customer
await authService.login(phone, 'customer');
await authService.verifyOTP(phone, otp, endpoint, userType: 'customer');

// Check customer token exists
final customerToken = await TokenStorage.getToken(forRole: 'customer');
print('Customer token: ${customerToken?.substring(0, 20)}...');

// Login as admin (different session)
await authService.login(phone, 'admin');
await authService.verifyOTP(phone, otp, endpoint, userType: 'admin');

// Check admin token exists
final adminToken = await TokenStorage.getToken(forRole: 'admin');
print('Admin token: ${adminToken?.substring(0, 20)}...');

// Verify they're different
assert(customerToken != adminToken);
```

### Verify Auto-Detection
```dart
// Should use customer token
final response1 = await ApiHelper.post('/customer/issue', body: {...});

// Should use admin token
final response2 = await ApiHelper.get('/admin/categories/');

// Should throw error if wrong token
try {
  // If logged in as admin, this should fail
  await ApiHelper.post('/customer/issue', body: {...});
} catch (e) {
  print('Expected error: $e');
}
```

---

## Benefits

1. **Automatic Token Selection** - No manual token management
2. **Role Validation** - Prevents wrong token usage
3. **Cleaner Code** - Less boilerplate
4. **Type Safety** - Compile-time endpoint validation
5. **Error Prevention** - Catches token mismatches early
6. **Maintainability** - Centralized token logic

---

## Next Steps

1. Migrate all remaining API calls to use ApiHelper
2. Add role validation to all protected screens
3. Test all user flows (customer, admin, driver)
4. Update backend to return correct token roles
5. Add token refresh logic if needed

---

## Notes

- Backend bug: Customer login returns admin token - needs backend fix
- JWT token role field is source of truth
- Tokens are stored in SharedPreferences (web) or secure storage (mobile)
- Token validation happens on every API call
- No token refresh implemented yet - add if needed
