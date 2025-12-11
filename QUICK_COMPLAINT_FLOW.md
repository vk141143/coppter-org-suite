# Quick Complaint Flow - Take a Photo Feature

## Overview
Implemented a streamlined complaint submission flow that opens a popup dialog after image selection, allowing users to quickly submit waste complaints with AI price estimation.

## New Flow

### Previous Flow
1. Click "Take a Photo" → Select Image → Navigate to Full Complaint Screen → Fill Details → Submit

### New Flow
1. Click "Take a Photo" → Select Image → **Popup Dialog Opens** → Fill Details → Get AI Estimate → Submit

## Features

### 1. Quick Complaint Dialog (`quick_complaint_dialog.dart`)
- **Animated Entry**: Fade + Slide animation on dialog open
- **Image Preview**: Shows selected image in preview section
- **Form Fields**:
  - Waste Category (Dropdown with icons)
  - Description (Multi-line text)
  - Pickup Location (with "Use Current Location" button)
- **AI Price Estimation**:
  - Animated loading state with progress indicator
  - Price reveal with scale + fade animation
  - Counter animation for price number
  - Recalculate option
- **Submit Button**:
  - Disabled until price is estimated
  - Pulse animation when enabled
  - Icon changes to checkmark when ready
- **Responsive Design**: Adapts to mobile and desktop screens

### 2. Animations Implemented

#### Entry Animations
- **Fade In**: 300ms fade from 0 to 1 opacity
- **Slide Up**: 400ms slide from bottom with ease-out curve

#### Estimation Loading
- **Circular Progress**: Spinning loader
- **Text Animation**: "AI is analyzing your waste..."
- **Gradient Background**: Blue gradient container

#### Price Reveal
- **Scale Animation**: 500ms scale from 0 to 1
- **Opacity Animation**: Synchronized with scale
- **Counter Animation**: 800ms number count-up to final price
- **Success Icon**: Check circle with green color

#### Submit Button
- **Pulse Animation**: 1000ms scale from 1.0 to 1.05 (repeating)
- **Icon Addition**: Check circle outline icon appears
- **Color**: LiftAway brand green (#0F5132)

### 3. User Experience Flow

#### Step 1: Image Selection
- User clicks "Take a Photo" quick action
- Platform-specific picker opens (file picker on web, bottom sheet on mobile)
- User selects/captures image

#### Step 2: Dialog Opens
- Animated dialog appears with fade + slide
- Image preview shown at top
- Form fields ready for input

#### Step 3: Fill Details
- Select waste category from dropdown
- Enter description
- Enter/detect pickup location
- All fields validated

#### Step 4: Get AI Estimate
- Click "Get AI Price Estimate" button
- Loading animation shows with progress indicator
- After 2 seconds, price card animates in
- Price counter animates from 0 to final amount
- Submit button starts pulsing

#### Step 5: Submit
- Click pulsing "Submit Complaint" button
- Dialog closes
- Full-screen transition animation plays
- Redirects to Track Complaint screen

### 4. Files Modified

#### `lib/web_dashboard/widgets/quick_actions_web.dart`
- Changed navigation from `RaiseComplaintScreen` to `QuickComplaintDialog`
- Shows dialog instead of pushing new route

#### `lib/features/user/screens/user_dashboard.dart`
- Updated mobile "Raise Issue" action
- Shows dialog when image is selected
- Falls back to full screen if no image

#### `lib/features/raise_complaint/widgets/quick_complaint_dialog.dart` (NEW)
- Complete dialog implementation
- All animations and form logic
- AI estimation simulation
- Responsive design

## Technical Details

### Animation Controllers
- `_slideController`: 400ms for entry slide animation
- `_fadeController`: 300ms for entry fade animation
- `_pulseController`: 1000ms repeating for submit button pulse

### Validation
- Category: Required
- Description: Required, minimum text
- Location: Required

### Price Estimation
- Simulated 2-second delay
- Returns mock data:
  - Recommended: ₹450
  - Range: ₹350 - ₹550
- Can be recalculated

### Responsive Breakpoint
- Small screen: < 600px width
- Adjusts dialog width and padding
- Maintains usability on all devices

## Benefits

✅ **Faster**: Reduced steps from 5+ to 3
✅ **Intuitive**: Clear visual feedback at each step
✅ **Engaging**: Smooth animations keep user engaged
✅ **Efficient**: No page navigation, stays in context
✅ **Professional**: Polished UI with brand colors
✅ **Accessible**: Works on web and mobile platforms

## Future Enhancements
- Real AI price estimation API integration
- Image preview with actual image display
- Multiple image support in dialog
- Save as draft functionality
- Voice input for description
