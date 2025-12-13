# URL Configuration Verification

## Current Configuration

Your `app_config.dart` is correctly set to:
```dart
static const String _customerApiUrl = 'http://13.232.82.200:8000/api';
```

## The Error You're Seeing

```
ClientException: Failed to fetch, uri=http://13.232.241.195:8000/api/auth/login/customer/
```

This shows the OLD IP: `13.232.241.195` instead of the NEW IP: `13.232.82.200`

## Why This Happens

Flutter Web caches the compiled JavaScript files. Even though you changed the Dart code, the browser is still using the old cached version.

## Solution - Follow These Steps:

### Step 1: Stop the App
- Close the browser tab
- Stop the Flutter app (Ctrl+C in terminal)

### Step 2: Clear Flutter Cache
```bash
flutter clean
```
✅ Already done!

### Step 3: Clear Browser Cache
- Open your browser
- Press `Ctrl + Shift + Delete`
- Select "Cached images and files"
- Click "Clear data"

OR use Incognito/Private mode

### Step 4: Rebuild and Run
```bash
flutter pub get
flutter run -d chrome
```

### Step 5: Hard Refresh in Browser
Once the app loads:
- Press `Ctrl + Shift + R` (Windows/Linux)
- Or `Cmd + Shift + R` (Mac)

This forces the browser to reload everything without cache.

## Verify It's Working

After restarting, check the console logs. You should see:
```
🌐 Customer API: http://13.232.82.200:8000/api
📡 POST Request: http://13.232.82.200:8000/api/auth/login/customer/
```

NOT:
```
❌ http://13.232.241.195:8000/api/...
```

## Alternative: Use Chrome DevTools

1. Open Chrome DevTools (F12)
2. Go to "Application" tab
3. Click "Clear storage" on the left
4. Click "Clear site data" button
5. Refresh the page

## If Still Not Working

Check if there's a `.env` file with old URLs:
```bash
# Check if .env exists
type .env
```

If it has old URLs, update them or delete the file.

## Quick Test Command

Run this to see what URL is being used:
```bash
flutter run -d chrome --verbose
```

Look for the API URL in the output.

## Summary

The config file is correct ✅
The issue is browser/build cache ❌

**Solution**: Clear cache + rebuild + hard refresh
