# Backend API Integration Guide

## Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env` and update with your values:
```bash
cp .env.example .env
```

Edit `.env`:
```
BASE_URL=https://your-backend-url.com/api/v1
MAPBOX_ACCESS_TOKEN=pk.your_token_here
```

## Service Layer Structure

```
lib/core/
├── config/
│   └── app_config.dart          # Environment variable loader
└── services/
    ├── api_service.dart         # Base HTTP client
    ├── auth_service.dart        # Authentication APIs
    ├── waste_service.dart       # Waste management APIs
    ├── driver_service.dart      # Driver APIs
    └── admin_service.dart       # Admin APIs
```

## Usage Examples

### Authentication

```dart
import 'package:waste_management_app/core/services/auth_service.dart';

final authService = AuthService();

// Login
try {
  final response = await authService.login('+1234567890', 'Customer');
  print('Login successful: ${response['user']['name']}');
} catch (e) {
  print('Login failed: $e');
}

// Verify OTP
try {
  final response = await authService.verifyOTP('+1234567890', '123456', 'Customer');
  print('OTP verified, token saved');
} catch (e) {
  print('OTP verification failed: $e');
}

// Get Profile
try {
  final profile = await authService.getUserProfile();
  print('User: ${profile['name']}');
} catch (e) {
  print('Failed to fetch profile: $e');
}

// Logout
await authService.logout();
```

### Waste Management

```dart
import 'package:waste_management_app/core/services/waste_service.dart';

final wasteService = WasteService();

// Submit Waste Request
try {
  final response = await wasteService.submitWasteRequest(
    latitude: 37.7749,
    longitude: -122.4194,
    wasteType: 'Plastic',
    description: 'Large plastic waste',
    imageUrl: 'https://example.com/image.jpg',
  );
  print('Request submitted: ${response['id']}');
} catch (e) {
  print('Failed to submit: $e');
}

// Get My Complaints
try {
  final complaints = await wasteService.getMyComplaints(status: 'pending');
  print('Found ${complaints.length} complaints');
} catch (e) {
  print('Failed to fetch complaints: $e');
}

// Get Nearby Bins
try {
  final bins = await wasteService.getNearbyBins(
    latitude: 37.7749,
    longitude: -122.4194,
    radius: 5.0,
  );
  print('Found ${bins.length} bins nearby');
} catch (e) {
  print('Failed to fetch bins: $e');
}

// Upload Image
try {
  final imageUrl = await wasteService.uploadImage('/path/to/image.jpg');
  print('Image uploaded: $imageUrl');
} catch (e) {
  print('Upload failed: $e');
}

// Track Vehicle
try {
  final tracking = await wasteService.trackWasteVehicle('complaint_id_123');
  print('Driver location: ${tracking['driver_location']}');
} catch (e) {
  print('Tracking failed: $e');
}
```

### Driver Operations

```dart
import 'package:waste_management_app/core/services/driver_service.dart';

final driverService = DriverService();

// Get Assigned Jobs
try {
  final jobs = await driverService.getAssignedJobs();
  print('You have ${jobs.length} jobs');
} catch (e) {
  print('Failed to fetch jobs: $e');
}

// Accept Job
try {
  await driverService.acceptJob('job_id_123');
  print('Job accepted');
} catch (e) {
  print('Failed to accept: $e');
}

// Start Job
try {
  await driverService.startJob('job_id_123');
  print('Job started');
} catch (e) {
  print('Failed to start: $e');
}

// Complete Job
try {
  await driverService.completeJob('job_id_123', 'proof_image_url');
  print('Job completed');
} catch (e) {
  print('Failed to complete: $e');
}

// Update Location
try {
  await driverService.updateLocation(37.7749, -122.4194);
  print('Location updated');
} catch (e) {
  print('Failed to update location: $e');
}

// Toggle Online Status
try {
  await driverService.toggleOnlineStatus(true);
  print('Now online');
} catch (e) {
  print('Failed to toggle status: $e');
}

// Get Earnings
try {
  final earnings = await driverService.getEarnings(period: 'monthly');
  print('Total earnings: ${earnings['total']}');
} catch (e) {
  print('Failed to fetch earnings: $e');
}
```

### Admin Operations

```dart
import 'package:waste_management_app/core/services/admin_service.dart';

final adminService = AdminService();

// Get Dashboard Stats
try {
  final stats = await adminService.getDashboardStats();
  print('Total complaints: ${stats['total_complaints']}');
} catch (e) {
  print('Failed to fetch stats: $e');
}

// Get All Complaints
try {
  final complaints = await adminService.getAllComplaints(
    status: 'pending',
    category: 'Plastic',
  );
  print('Found ${complaints.length} complaints');
} catch (e) {
  print('Failed to fetch complaints: $e');
}

// Assign Driver
try {
  await adminService.assignDriver('complaint_id_123', 'driver_id_456');
  print('Driver assigned');
} catch (e) {
  print('Failed to assign: $e');
}

// Update Complaint Status
try {
  await adminService.updateComplaintStatus('complaint_id_123', 'in_progress');
  print('Status updated');
} catch (e) {
  print('Failed to update: $e');
}

// Get All Drivers
try {
  final drivers = await adminService.getAllDrivers(status: 'active');
  print('Found ${drivers.length} drivers');
} catch (e) {
  print('Failed to fetch drivers: $e');
}

// Approve Driver
try {
  await adminService.approveDriver('driver_id_456');
  print('Driver approved');
} catch (e) {
  print('Failed to approve: $e');
}

// Get Analytics
try {
  final analytics = await adminService.getAnalytics(period: 'weekly');
  print('Analytics: $analytics');
} catch (e) {
  print('Failed to fetch analytics: $e');
}
```

## Error Handling Pattern

```dart
import 'package:flutter/material.dart';
import 'package:waste_management_app/core/services/waste_service.dart';

class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final wasteService = WasteService();
  bool isLoading = false;

  Future<void> submitRequest() async {
    setState(() => isLoading = true);

    try {
      final response = await wasteService.submitWasteRequest(
        latitude: 37.7749,
        longitude: -122.4194,
        wasteType: 'Plastic',
        description: 'Test',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: isLoading ? null : submitRequest,
          child: isLoading
              ? CircularProgressIndicator()
              : Text('Submit Request'),
        ),
      ),
    );
  }
}
```

## API Endpoints Expected by Backend

### Authentication
- `POST /auth/login` - Login with phone
- `POST /auth/verify-otp` - Verify OTP
- `POST /auth/register` - Register new user
- `POST /auth/logout` - Logout
- `GET /auth/profile` - Get user profile
- `PUT /auth/profile` - Update profile
- `POST /auth/forgot-password` - Request password reset
- `POST /auth/reset-password` - Reset password

### Waste Management
- `POST /waste/request` - Submit waste request
- `GET /waste/complaints` - Get user complaints
- `GET /waste/complaints/:id` - Get complaint details
- `GET /waste/bins/nearby` - Get nearby bins
- `GET /waste/track/:id` - Track vehicle
- `POST /waste/upload-image` - Upload image
- `GET /waste/categories` - Get waste categories
- `POST /waste/complaints/:id/cancel` - Cancel complaint
- `POST /waste/complaints/:id/rate` - Rate service

### Driver
- `GET /driver/jobs` - Get assigned jobs
- `POST /driver/jobs/:id/accept` - Accept job
- `POST /driver/jobs/:id/reject` - Reject job
- `POST /driver/jobs/:id/start` - Start job
- `POST /driver/jobs/:id/complete` - Complete job
- `POST /driver/location` - Update location
- `POST /driver/status` - Toggle online status
- `GET /driver/earnings` - Get earnings
- `GET /driver/jobs/history` - Get job history

### Admin
- `GET /admin/dashboard/stats` - Dashboard statistics
- `GET /admin/complaints` - All complaints
- `POST /admin/complaints/:id/assign` - Assign driver
- `PUT /admin/complaints/:id/status` - Update status
- `GET /admin/drivers` - All drivers
- `POST /admin/drivers/:id/approve` - Approve driver
- `POST /admin/drivers/:id/reject` - Reject driver
- `GET /admin/users` - All users
- `PUT /admin/users/:id/status` - Update user status
- `GET /admin/analytics` - Analytics data

## Security Notes

1. **Never commit `.env` file** - It's in `.gitignore`
2. **Use `.env.example`** for documentation
3. **Tokens are stored securely** in SharedPreferences
4. **All API calls include authentication** when required
5. **HTTPS only** in production

## Testing

Test with mock backend:
```bash
# Start your FastAPI backend
cd backend
uvicorn main:app --reload

# Update .env
BASE_URL=http://localhost:8000/api/v1

# Run Flutter app
flutter run -d chrome
```
