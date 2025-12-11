# How to Fix the API URL Issue

## Problem
The app is still using the old API URL (`http://13.201.134.175:8001/api`) even though we updated it to (`http://43.205.99.220:8000/api`).

## Solution

### Option 1: Full Restart (Recommended)
1. **Stop the app completely** (don't use hot restart)
2. In your terminal/command prompt, press `Ctrl+C` to stop the running app
3. Clear Flutter build cache:
   ```bash
   flutter clean
   ```
4. Rebuild and run:
   ```bash
   flutter run -d chrome
   ```
   or
   ```bash
   flutter run
   ```

### Option 2: Quick Fix (If Option 1 doesn't work)
Since the hardcoded value in `app_config.dart` is already correct, you can temporarily disable the `.env` loading:

In `lib/core/config/app_config.dart`, change:
```dart
static String get baseUrl {
  // Try to load from .env first, fallback to hardcoded value
  final url = dotenv.env['BASE_URL']?.isNotEmpty == true 
      ? dotenv.env['BASE_URL']! 
      : _hardcodedBaseUrl;
  if (kDebugMode) {
    print('🌐 API Base URL: $url');
  }
  return url;
}
```

To:
```dart
static String get baseUrl {
  // Use hardcoded value directly
  if (kDebugMode) {
    print('🌐 API Base URL: $_hardcodedBaseUrl');
  }
  return _hardcodedBaseUrl;
}
```

Then do a hot restart.

### Option 3: Clear Browser Cache (For Web)
If running on web browser:
1. Open browser DevTools (F12)
2. Right-click on the refresh button
3. Select "Empty Cache and Hard Reload"
4. Or clear all browser data for localhost

## Verification
After restart, check the console. You should see:
```
🌐 API Base URL: http://43.205.99.220:8000/api
📡 POST Request: http://43.205.99.220:8000/api/auth/register/customer/
```

## Files Updated
✅ `.env` - Updated to new URL
✅ `.env.example` - Updated to new URL  
✅ `lib/core/config/app_config.dart` - Hardcoded URL updated
✅ `lib/core/services/auth_service.dart` - Already configured correctly

## Test Registration
After the app restarts with the correct URL:
1. Go to Registration screen
2. Fill in the form
3. Click "Create Account"
4. The API call should now go to: `http://43.205.99.220:8000/api/auth/register/customer/`
