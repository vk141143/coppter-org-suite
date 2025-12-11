# Platform-Based Image Picker Implementation

## Overview
Implemented a unified image picker that behaves differently on web and mobile platforms for the "Take a Photo" quick action.

## Files Created

### 1. `lib/core/utils/image_selector.dart`
- Helper class with platform detection
- **Web**: Opens file picker automatically
- **Mobile**: Shows bottom sheet with Camera/Gallery options
- Returns `XFile?` for selected image
- Includes error handling and image compression (max 1920x1080, 85% quality)

## Files Modified

### 1. `pubspec.yaml`
- Updated `image_picker` to `^1.0.8`
- Added `image_picker_for_web: ^3.0.2`
- Added `permission_handler: ^11.0.1`

### 2. `lib/features/user/screens/raise_complaint_screen.dart`
- Added optional `XFile? image` parameter
- Passes image to both mobile and web versions

### 3. `lib/features/raise_complaint/screens/raise_complaint_mobile.dart`
- Added optional `XFile? image` parameter
- Automatically adds passed image to `_selectedImages` list in `initState()`

### 4. `lib/features/raise_complaint/screens/raise_complaint_web.dart`
- Added optional `XFile? image` parameter
- Automatically adds passed image to `_selectedImages` list in `initState()`

### 5. `lib/web_dashboard/widgets/quick_actions_web.dart`
- Updated "Take a Photo" button to use `ImageSelector.pickImage()`
- Navigates to `RaiseComplaintScreen` with selected image
- Added import for `image_selector.dart`

### 6. `lib/features/user/screens/user_dashboard.dart`
- Updated "Raise Issue" quick action to use `ImageSelector.pickImage()`
- Navigates to `RaiseComplaintScreen` with or without image
- Added import for `image_selector.dart`

## User Flow

### Web Platform
1. User clicks "Take a Photo" → File picker opens
2. User selects image file (jpeg/png/heic/webp)
3. Image is passed to `RaiseComplaintScreen`
4. Image appears in the upload section automatically

### Mobile Platform
1. User clicks "Raise Issue" or "Take a Photo"
2. Bottom sheet appears with options:
   - Take Photo (Camera)
   - Choose from Gallery
   - Cancel
3. User selects option
4. Image is captured/selected
5. Image is passed to `RaiseComplaintScreen`
6. Image appears in the upload section automatically

## Features
✅ Platform detection (web vs mobile)
✅ File picker for web
✅ Bottom sheet with camera/gallery options for mobile
✅ Image compression (1920x1080, 85% quality)
✅ Error handling
✅ Smooth navigation flow
✅ LiftAway brand colors in bottom sheet
✅ Context-aware navigation (checks if mounted)

## Dependencies Required
Run `flutter pub get` to install:
- `image_picker: ^1.0.8`
- `image_picker_for_web: ^3.0.2`
- `permission_handler: ^11.0.1`

## Notes
- No permission handling code added (handled automatically by `image_picker`)
- Image validation happens at picker level
- Works seamlessly on Android, iOS, and Web
- Maintains existing functionality when no image is selected
