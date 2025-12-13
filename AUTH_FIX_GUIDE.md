# Complete Authentication Fix Guide

## Problems Fixed

### 1. ❌ No valid customer token found
**Cause:** Token wasn't being saved properly after OTP verification
**Fix:** Updated `customer_api_service.dart` to:
- Save token using `TokenStorage.saveToken(token, role: 'customer')`
- Verify token was saved successfully
- Throw error if token is null or save fails

### 2. ❌ Customer authentication required
**Cause:** Token retrieval wasn't checking the correct storage location
**Fix:** Updated `debug_token_helper.dart` to:
- Check both SharedPreferences AND localStorage
- Validate token role matches 'customer'
- Return clear validation status

### 3. ❌ Could not find generator for route "/login"
**Cause:** Routes weren't defined in MaterialApp
**Fix:** Updated `main.dart` to:
- Add `routes` map with all screen routes
- Add `/login` route pointing to LoginScreen
- Use `pushNamedAndRemoveUntil` for proper navigation

## Complete Flow

### Login Flow
```
1. User enters phone → OTP sent
2. User enters OTP → Backend verifies
3. Backend returns JWT token with role: "customer"
4. Frontend saves token:
   - TokenStorage.saveToken(token, role: 'customer')
   - Saves to customer_token key
   - Saves to customer_role key
   - Clears admin/driver tokens
5. User redirected to dashboard
```

### Token Storage
```dart
// After OTP verification
final token = response['access_token'] ?? response['token'];
await TokenStorage.saveToken(token, role: 'customer');

// This saves:
localStorage['customer_token'] = token
localStorage['customer_role'] = 'customer'

// And clears:
localStorage['admin_token'] = null
localStorage['admin_role'] = null
```

### Token Retrieval
```dart
// Get customer token
final token = await TokenStorage.getToken(forRole: 'customer');

// Auto-detect role
final role = await TokenStorage.getUserRole();
// Returns: 'customer' if customer_token exists
//          'admin' if admin_token exists
//          null if no tokens
```

### Protected API Calls
```dart
// Before making API call
final token = await TokenStorage.getToken(forRole: 'customer');
if (token == null || token.isEmpty) {
  throw Exception('Customer authentication required');
}

// Make API call
final response = await http.post(
  url,
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(data),
);
```

### Screen Protection
```dart
@override
void initState() {
  super.initState();
  _validateCustomerAccess();
}

Future<void> _validateCustomerAccess() async {
  final hasToken = await DebugTokenHelper.hasValidCustomerToken();
  if (!hasToken) {
    // Clear all tokens
    await DebugTokenHelper.clearAllTokens();
    
    // Redirect to login
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
```

## Files Modified

### 1. main.dart
- Added routes map
- Added `/login` route
- Added error handling for initial screen

### 2. debug_token_helper.dart
- Added localStorage support
- Added `hasValidCustomerToken()` method
- Improved token validation
- Better error messages

### 3. customer_api_service.dart
- Added token save verification
- Throws error if token is null
- Better logging

### 4. raise_complaint_web.dart
- Uses `hasValidCustomerToken()` for validation
- Clears tokens before redirect
- Uses `pushNamedAndRemoveUntil` for navigation

### 5. token_storage.dart (already fixed)
- Separate keys for each role
- Auto-clears other roles when saving
- Auto-detects role from existing tokens

## How to Test

### 1. Clear All Tokens
```dart
// In browser console
localStorage.clear()

// Or in app
await DebugTokenHelper.clearAllTokens();
```

### 2. Login as Customer
```
1. Go to login screen
2. Select "Customer"
3. Enter phone: +449848609217
4. Enter OTP (from backend)
5. Check console for:
   ✅ Customer token saved and verified
   ✅ Valid customer token found
```

### 3. Check Token Status
```dart
// Add this to any screen
await DebugTokenHelper.printTokenStatus();

// Output:
========== TOKEN STATUS ==========
Customer Token: EXISTS (eyJhbGciOiJIUzI1NiIs...)
Admin Token: NULL
Driver Token: NULL
Detected Role: customer
Active Token Role: customer
Token Valid: true
==================================
```

### 4. Test Protected Screen
```
1. Navigate to "Book Pickup"
2. Should see:
   ✅ Customer authentication validated
3. Fill form and submit
4. Should work without authentication errors
```

## Common Issues

### Issue: Token not saving
**Solution:**
1. Check backend response has `access_token` or `token` field
2. Check token is not null or empty
3. Check console for "Token save failed!" message

### Issue: Wrong role detected
**Solution:**
1. Clear all tokens: `localStorage.clear()`
2. Login again as customer
3. Check JWT payload has `role: "customer"`

### Issue: Navigation error
**Solution:**
1. Use `Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false)`
2. Don't use `pushReplacementNamed` without routes defined
3. Check main.dart has routes map

### Issue: API returns 401
**Solution:**
1. Check token is being sent: `Authorization: Bearer <token>`
2. Check token role matches endpoint (customer token for customer endpoints)
3. Check token hasn't expired

## Backend Requirements

Your FastAPI backend must:

1. **Return JWT token with role**
```python
# In OTP verification endpoint
token_data = {
    "user_id": user.id,
    "role": "customer",  # MUST include role
    "exp": datetime.utcnow() + timedelta(days=7)
}
token = jwt.encode(token_data, SECRET_KEY, algorithm="HS256")
return {"access_token": token, "user": user_data}
```

2. **Validate token role in protected endpoints**
```python
# In customer endpoints
def get_current_customer(token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    if payload.get("role") != "customer":
        raise HTTPException(401, "Customer authentication required")
    return payload
```

3. **Return proper error messages**
```python
# If authentication fails
raise HTTPException(
    status_code=401,
    detail="Customer authentication required"
)
```

## Verification Checklist

- [ ] Token is saved after OTP verification
- [ ] Token role is 'customer'
- [ ] Token is retrieved correctly
- [ ] Protected APIs include Authorization header
- [ ] Navigation to /login works
- [ ] Screen validation redirects to login if no token
- [ ] Book Pickup works without authentication errors
- [ ] Console shows "✅ Customer authentication validated"

## Quick Fix Commands

```dart
// 1. Clear everything
await DebugTokenHelper.clearAllTokens();

// 2. Check status
await DebugTokenHelper.printTokenStatus();

// 3. Validate customer access
final isValid = await DebugTokenHelper.hasValidCustomerToken();
print('Customer token valid: $isValid');

// 4. Get token
final token = await TokenStorage.getToken(forRole: 'customer');
print('Token: ${token?.substring(0, 20)}...');

// 5. Get role
final role = await TokenStorage.getUserRole();
print('Role: $role');
```

## Success Indicators

When everything works, you should see:

```
📡 POST Request: http://13.233.195.173:8000/api/auth/verify-login-otp/
📥 Response status: 200
🔑 Token received: eyJhbGciOiJIUzI1NiIs...
💾 Customer token saved with role
✅ Customer token saved and verified

========== TOKEN STATUS ==========
Customer Token: EXISTS (eyJhbGciOiJIUzI1NiIs...)
Admin Token: NULL
Driver Token: NULL
Detected Role: customer
Active Token Role: customer
Token Valid: true
==================================

✅ Valid customer token found
✅ Customer authentication validated

📡 POST Request: http://13.233.195.173:8000/api/customer/issue
🔑 Customer Token: eyJhbGciOiJIUzI1NiIs...
📥 Response status: 200
✅ Booking successful
```
