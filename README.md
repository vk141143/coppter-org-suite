<<<<<<< HEAD
# LiftAway - Waste Management App

**Fast. Simple. Reliable Waste Removal.**

A premium Flutter application for waste collection management with modern UI design, Material 3 theming, and support for both light and dark themes.

## Features

### 🎯 User App (Customer)
- **Onboarding & Authentication**
  - 3-screen onboarding with smooth animations
  - Login with email/phone and OTP verification
  - Registration with form validation
  - Forgot password functionality

- **Dashboard**
  - Personalized greeting and user info
  - Quick action buttons (Raise Complaint, Track Pickup, My Complaints)
  - Waste category horizontal scroller with icons
  - Recent complaints preview

- **Complaint Management**
  - Raise complaints with category selection (12 waste categories)
  - Image upload functionality
  - Location picker integration
  - Track complaint status with timeline UI
  - Complaint history with filtering

- **Profile Management**
  - View and edit profile information
  - Theme toggle (Light/Dark)
  - Notification settings
  - Logout functionality

### 🚛 Driver App
- **Dashboard**
  - Earnings tracking and statistics
  - Online/Offline status toggle
  - Today's assigned jobs
  - Performance metrics

- **Job Management**
  - Job details with customer information
  - Accept/Reject job functionality
  - Pickup progress tracking with timeline
  - Photo upload for completion verification
  - Live location mock UI

- **Profile**
  - Driver information and vehicle details
  - Job history and earnings
  - Settings and preferences

### 👨‍💼 Admin Dashboard
- **Analytics Dashboard**
  - Key performance metrics
  - Interactive charts and graphs
  - Category distribution analysis
  - Regional heatmap visualization

- **Complaint Management**
  - View all complaints with filtering
  - Assign drivers to complaints
  - Update complaint status
  - Detailed complaint information

- **Driver Management**
  - Driver approval/rejection system
  - Performance tracking
  - Area assignment
  - Driver statistics

- **User Management**
  - User search and filtering
  - View user details and complaint history
  - User status management (Active/Suspended)

## 🎨 Design Features

- **Modern UI Design**
  - Material 3 design system
  - Rounded corners (12-16px)
  - Soft shadows and glassmorphism effects
  - Gradient app bars and backgrounds

- **Responsive Design**
  - Adaptive layouts for different screen sizes
  - Mobile-friendly admin dashboard
  - Consistent spacing and typography

- **Animations & Transitions**
  - Hero animations between screens
  - Page transitions (fade, slide)
  - Shimmer loading effects
  - Animated buttons and interactions

- **Theme Support**
  - Complete light and dark theme implementation
  - Dynamic theme switching
  - Consistent color schemes
  - Theme persistence using SharedPreferences

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   └── utils/
├── features/
│   ├── auth/
│   │   └── screens/
│   ├── user/
│   │   └── screens/
│   ├── driver/
│   │   └── screens/
│   └── admin/
│       └── screens/
└── shared/
    ├── models/
    └── widgets/
```

## 📱 Screens Included

### Authentication
- Onboarding Screen (3 pages)
- Login Screen
- Registration Screen
- OTP Verification Screen
- Forgot Password Screen

### User App
- User Dashboard
- Raise Complaint Screen
- Track Complaint Screen
- Complaint History Screen
- User Profile Screen

### Driver App
- Driver Dashboard
- Job Details Screen
- Pickup In Progress Screen
- Driver Profile Screen

### Admin App
- Admin Dashboard
- Complaint Management Screen
- Driver Management Screen
- User Management Screen
- Analytics Screen

## 🛠️ Dependencies

- `provider` - State management
- `shared_preferences` - Local storage
- `flutter_svg` - SVG support
- `lottie` - Animations
- `shimmer` - Loading effects
- `fl_chart` - Charts and graphs
- `image_picker` - Image selection
- `google_maps_flutter` - Maps integration
- `geolocator` - Location services
- `smooth_page_indicator` - Page indicators
- `animations` - Advanced animations

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd waste-management-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Key Features Implemented

- ✅ Complete UI for all three user types (Customer, Driver, Admin)
- ✅ Material 3 design system
- ✅ Light and Dark theme support
- ✅ Responsive layouts
- ✅ Animated transitions and loading states
- ✅ Form validation and error handling
- ✅ Image upload functionality
- ✅ Charts and analytics visualization
- ✅ Search and filtering capabilities
- ✅ Status management and tracking
- ✅ Professional, modern UI design

## 📝 Notes

- This is a UI-only implementation with mock data
- No backend integration is included
- All data is simulated for demonstration purposes
- The app includes comprehensive navigation between all screens
- Theme switching is persistent across app restarts

## 🎨 LiftAway Brand Colors

- **Primary**: Deep Forest Green (#0F5132)
- **Secondary**: Sage Green (#D1E7DD)
- **Accent**: Soft Beige (#FAF7F2)
- **Text**: Dark Charcoal (#1F1F1F)
- **CTA Buttons**: Gradient Green
- **Alerts**: Orange (#FF6F00)

## 📱 Supported Platforms

- Android
- iOS
- Web (with responsive design)

---

Built with ❤️ by LiftAway Team using Flutter and Material 3 Design System
=======
# Welcome to your Lovable project

## Project info

**URL**: https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID

## How can I edit this code?

There are several ways of editing your application.

**Use Lovable**

Simply visit the [Lovable Project](https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID) and start prompting.

Changes made via Lovable will be committed automatically to this repo.

**Use your preferred IDE**

If you want to work locally using your own IDE, you can clone this repo and push changes. Pushed changes will also be reflected in Lovable.

The only requirement is having Node.js & npm installed - [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

Follow these steps:

```sh
# Step 1: Clone the repository using the project's Git URL.
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the project directory.
cd <YOUR_PROJECT_NAME>

# Step 3: Install the necessary dependencies.
npm i

# Step 4: Start the development server with auto-reloading and an instant preview.
npm run dev
```

**Edit a file directly in GitHub**

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

**Use GitHub Codespaces**

- Navigate to the main page of your repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

## What technologies are used for this project?

This project is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS

## How can I deploy this project?

Simply open [Lovable](https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID) and click on Share -> Publish.

## Can I connect a custom domain to my Lovable project?

Yes, you can!

To connect a domain, navigate to Project > Settings > Domains and click Connect Domain.

Read more here: [Setting up a custom domain](https://docs.lovable.dev/features/custom-domain#custom-domain)
>>>>>>> 7c56de421ed0b9dde8a792f753db65a75c02f496
