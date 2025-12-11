# Token Storage Verification Guide

## How to Verify Token in Browser Console (Web)

### Method 1: Check localStorage directly
```javascript
// Open Chrome DevTools (F12) → Console tab
localStorage.getItem('auth_token')
```

### Method 2: View in Application tab
1. Open Chrome DevTools (F12)
2. Go to **Application** tab
3. Expand **Local Storage** in left sidebar
4. Click on your domain (e.g., `http://localhost:port`)
5. Look for key: `auth_token`

### Method 3: List all localStorage items
```javascript
// See all stored items
Object.keys(localStorage).forEach(key => {
  console.log(key + ': ' + localStorage.getItem(key));
});
```

## Expected Console Logs After Login

When you log in successfully, you should see:
```
📡 POST Request: http://43.205.99.220:8001/api/auth/verify-login/admin
📥 Response status: 200
📥 Response body: {"token":"eyJ..."}
💾 Saving token: eyJ...
🌐 Web: Token saved to localStorage
✅ TOKEN SAVED SUCCESSFULLY (XXX chars)
💾 Saved user role: admin
🔐 Verifying OTP for admin at /auth/verify-login/admin
✅ OTP verified successfully
🔍 Token check after verification: Token exists (XXX chars)
```

## Expected Console Logs When Accessing Categories

When you navigate to Categories screen:
```
📡 GET Request: http://43.205.99.220:8001/api/admin/categories/
🌐 Web: Token retrieved from localStorage
🔑 Token retrieved: eyJ... (XXX chars)
📥 Response status: 200
```

## Troubleshooting

### If you see "NO TOKEN FOUND - USER NOT LOGGED IN"
1. Check browser console for login errors
2. Verify OTP was entered correctly
3. Check if API returned a token in response
4. Clear browser cache and try again

### If you get 403 Forbidden
1. Token might be expired
2. Token format might be wrong (should be JWT)
3. Backend might not recognize the token
4. Try logging out and logging in again

### Clear token manually (for testing)
```javascript
// In browser console
localStorage.removeItem('auth_token');
localStorage.removeItem('user_role');
```

## API Request Examples

### GET Request with Token
```dart
final token = await TokenStorage.getToken();
if (token == null) {
  throw Exception('User not authenticated');
}

final response = await http.get(
  Uri.parse('$baseUrl/admin/categories/'),
  headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
);

if (response.statusCode == 403) {
  // Token invalid or expired - redirect to login
  await TokenStorage.clearToken();
  // Navigate to login screen
}
```

### POST Request with Token
```dart
final token = await TokenStorage.getToken();
if (token == null) {
  throw Exception('User not authenticated');
}

final response = await http.post(
  Uri.parse('$baseUrl/admin/categories/'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'name': 'New Category',
    'image_url': 'https://example.com/image.png',
  }),
);

if (response.statusCode == 403) {
  // Token invalid or expired
  await TokenStorage.clearToken();
  // Navigate to login screen
}
```

## Platform-Specific Notes

### Web (Chrome/Edge/Firefox)
- Uses `dart:html` localStorage
- Token persists across browser sessions
- Can be viewed in DevTools
- Cleared when browser cache is cleared

### Android
- Uses SharedPreferences
- Token persists across app restarts
- Stored in app's private storage
- Cleared when app data is cleared

### iOS
- Uses SharedPreferences (NSUserDefaults)
- Token persists across app restarts
- Stored in app's sandbox
- Cleared when app is deleted

## Security Notes

1. **Never log full tokens in production** - Only log first 20 chars
2. **Use HTTPS in production** - Tokens sent over HTTP can be intercepted
3. **Implement token refresh** - Tokens should expire and be refreshed
4. **Clear token on logout** - Always call `TokenStorage.clearToken()`
5. **Handle 401/403 responses** - Redirect to login when token is invalid
