# BLoC State Management Usage Guide

## Overview

Your app now uses **BLoC (Business Logic Component)** pattern with:

- `AuthBloc` - Authentication & user management
- `WasteBloc` - Waste requests & complaints
- `DriverBloc` - Driver jobs & earnings
- `AdminBloc` - Admin dashboard & management

## Architecture

```
Event → BLoC → State → UI
```

Each BLoC has:
- **Events**: User actions (e.g., AuthLoginRequested)
- **States**: UI states (e.g., AuthLoading, AuthAuthenticated)
- **BLoC**: Business logic that transforms events into states

## Setup Complete ✅

All BLoCs registered in `main.dart`:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (context) => AuthBloc()),
    BlocProvider(create: (context) => WasteBloc()),
    BlocProvider(create: (context) => DriverBloc()),
    BlocProvider(create: (context) => AdminBloc()),
  ],
)
```

## Usage Examples

### 1. AuthBloc - Login Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_management_app/core/blocs/auth/auth_bloc.dart';
import 'package:waste_management_app/core/blocs/auth/auth_event.dart';
import 'package:waste_management_app/core/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _selectedUserType = 'Customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOTPSent) {
            // Navigate to OTP screen
            Navigator.pushNamed(context, '/otp', arguments: state.phone);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                _phoneController.text,
                                _selectedUserType,
                              ),
                            );
                      },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text('Send OTP'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 2. AuthBloc - OTP Verification

```dart
class OTPScreen extends StatefulWidget {
  final String phone;
  final String userType;

  const OTPScreen({required this.phone, required this.userType});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to dashboard based on user type
            if (widget.userType == 'Customer') {
              Navigator.pushReplacementNamed(context, '/user-dashboard');
            } else if (widget.userType == 'Driver') {
              Navigator.pushReplacementNamed(context, '/driver-dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
              ),
              ElevatedButton(
                onPressed: state is AuthLoading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                              AuthOTPVerifyRequested(
                                widget.phone,
                                _otpController.text,
                                widget.userType,
                              ),
                            );
                      },
                child: state is AuthLoading
                    ? CircularProgressIndicator()
                    : Text('Verify OTP'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 3. WasteBloc - Submit Complaint

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_management_app/core/blocs/waste/waste_bloc.dart';
import 'package:waste_management_app/core/blocs/waste/waste_event.dart';
import 'package:waste_management_app/core/blocs/waste/waste_state.dart';

class RaiseComplaintScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<WasteBloc, WasteState>(
        listener: (context, state) {
          if (state is WasteRequestSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Request submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is WasteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Your form fields here
              ElevatedButton(
                onPressed: state is WasteLoading
                    ? null
                    : () {
                        context.read<WasteBloc>().add(
                              WasteSubmitRequest(
                                latitude: 37.7749,
                                longitude: -122.4194,
                                wasteType: 'Plastic',
                                description: 'Large plastic waste',
                              ),
                            );
                      },
                child: state is WasteLoading
                    ? CircularProgressIndicator()
                    : Text('Submit Request'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 4. WasteBloc - Display Complaints

```dart
class ComplaintHistoryScreen extends StatefulWidget {
  @override
  _ComplaintHistoryScreenState createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load complaints when screen opens
    context.read<WasteBloc>().add(WasteLoadComplaints());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Complaints')),
      body: BlocBuilder<WasteBloc, WasteState>(
        builder: (context, state) {
          if (state is WasteLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is WasteError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is WasteComplaintsLoaded) {
            if (state.complaints.isEmpty) {
              return Center(child: Text('No complaints found'));
            }

            return ListView.builder(
              itemCount: state.complaints.length,
              itemBuilder: (context, index) {
                final complaint = state.complaints[index];
                return ListTile(
                  title: Text(complaint['waste_type'] ?? 'Unknown'),
                  subtitle: Text(complaint['status'] ?? 'Pending'),
                  trailing: Text(complaint['created_at'] ?? ''),
                );
              },
            );
          }

          return Center(child: Text('No data'));
        },
      ),
    );
  }
}
```

### 5. DriverBloc - Job Management

```dart
class DriverDashboard extends StatefulWidget {
  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(DriverLoadJobs());
    context.read<DriverBloc>().add(DriverLoadEarnings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Dashboard')),
      body: Column(
        children: [
          // Online/Offline Toggle
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              final isOnline = state is DriverOnlineStatusChanged
                  ? state.isOnline
                  : false;

              return SwitchListTile(
                title: Text('Online Status'),
                value: isOnline,
                onChanged: (value) {
                  context.read<DriverBloc>().add(DriverToggleOnlineStatus());
                },
              );
            },
          ),

          // Earnings Display
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              if (state is DriverEarningsLoaded) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Total Earnings: \$${state.earnings['total']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

          // Jobs List
          Expanded(
            child: BlocConsumer<DriverBloc, DriverState>(
              listener: (context, state) {
                if (state is DriverJobAccepted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job accepted!')),
                  );
                } else if (state is DriverError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is DriverLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is DriverJobsLoaded) {
                  return ListView.builder(
                    itemCount: state.jobs.length,
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return ListTile(
                        title: Text(job['customer_name'] ?? 'Unknown'),
                        subtitle: Text(job['address'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.read<DriverBloc>().add(
                                  DriverAcceptJob(job['id']),
                                );
                          },
                          child: Text('Accept'),
                        ),
                      );
                    },
                  );
                }

                return Center(child: Text('No jobs available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 6. AdminBloc - Dashboard

```dart
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadDashboardStats());
    context.read<AdminBloc>().add(AdminLoadComplaints());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Cards
            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminStatsLoaded) {
                  return Row(
                    children: [
                      _StatCard(
                        title: 'Total Complaints',
                        value: state.stats['total_complaints'].toString(),
                      ),
                      _StatCard(
                        title: 'Active Drivers',
                        value: state.stats['active_drivers'].toString(),
                      ),
                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),

            // Recent Complaints
            BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminComplaintsLoaded) {
                  return Column(
                    children: [
                      Text('Recent Complaints', style: TextStyle(fontSize: 20)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.complaints.take(5).length,
                        itemBuilder: (context, index) {
                          final complaint = state.complaints[index];
                          return ListTile(
                            title: Text(complaint['waste_type'] ?? 'Unknown'),
                            subtitle: Text(complaint['status'] ?? 'Pending'),
                          );
                        },
                      ),
                    ],
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Key BLoC Patterns

### 1. BlocBuilder (Rebuild on state change)
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return CircularProgressIndicator();
    if (state is AuthAuthenticated) return Text('Welcome ${state.user['name']}');
    return Text('Please login');
  },
)
```

### 2. BlocListener (Side effects only)
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

### 3. BlocConsumer (Both rebuild and side effects)
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  },
  builder: (context, state) {
    return YourWidget();
  },
)
```

### 4. Dispatching Events
```dart
// Using context.read (recommended)
context.read<AuthBloc>().add(AuthLoginRequested(phone, userType));

// Using BlocProvider.of
BlocProvider.of<AuthBloc>(context).add(AuthLoginRequested(phone, userType));
```

## Available Events & States

### AuthBloc
**Events:**
- `AuthLoginRequested(phone, userType)`
- `AuthOTPVerifyRequested(phone, otp, userType)`
- `AuthRegisterRequested(userData)`
- `AuthLogoutRequested()`
- `AuthLoadProfile()`
- `AuthUpdateProfile(data)`
- `AuthCheckStatus()`

**States:**
- `AuthInitial`
- `AuthLoading`
- `AuthAuthenticated(user)`
- `AuthUnauthenticated`
- `AuthOTPSent(phone)`
- `AuthError(message)`

### WasteBloc
**Events:**
- `WasteSubmitRequest(lat, lng, type, desc, imageUrl)`
- `WasteLoadComplaints(status)`
- `WasteLoadCategories()`
- `WasteUploadImage(filePath)`
- `WasteTrackVehicle(complaintId)`

**States:**
- `WasteInitial`
- `WasteLoading`
- `WasteComplaintsLoaded(complaints)`
- `WasteCategoriesLoaded(categories)`
- `WasteRequestSubmitted`
- `WasteImageUploaded(imageUrl)`
- `WasteTrackingLoaded(trackingData)`
- `WasteError(message)`

### DriverBloc
**Events:**
- `DriverLoadJobs()`
- `DriverAcceptJob(jobId)`
- `DriverStartJob(jobId)`
- `DriverCompleteJob(jobId, proofImageUrl)`
- `DriverToggleOnlineStatus()`
- `DriverLoadEarnings(period)`
- `DriverUpdateLocation(lat, lng)`

**States:**
- `DriverInitial`
- `DriverLoading`
- `DriverJobsLoaded(jobs, isOnline)`
- `DriverEarningsLoaded(earnings)`
- `DriverJobAccepted`
- `DriverJobCompleted`
- `DriverOnlineStatusChanged(isOnline)`
- `DriverError(message)`

### AdminBloc
**Events:**
- `AdminLoadDashboardStats()`
- `AdminLoadComplaints(status, category)`
- `AdminAssignDriver(complaintId, driverId)`
- `AdminLoadDrivers(status)`
- `AdminApproveDriver(driverId)`
- `AdminLoadUsers(searchQuery)`

**States:**
- `AdminInitial`
- `AdminLoading`
- `AdminStatsLoaded(stats)`
- `AdminComplaintsLoaded(complaints)`
- `AdminDriversLoaded(drivers)`
- `AdminUsersLoaded(users)`
- `AdminDriverAssigned`
- `AdminDriverApproved`
- `AdminError(message)`

## Benefits of BLoC

✅ **Separation of Concerns** - Business logic separate from UI
✅ **Testable** - Easy to unit test BLoCs
✅ **Predictable** - Clear event → state flow
✅ **Reactive** - UI automatically updates on state changes
✅ **Scalable** - Easy to add new features
✅ **Type Safe** - Compile-time safety with Dart

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Replace existing screens with BLoC implementations
3. Test each BLoC with your backend API
4. Add more events/states as needed

## Testing BLoCs

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOTPSent] when login succeeds',
      build: () => AuthBloc(),
      act: (bloc) => bloc.add(AuthLoginRequested('+1234567890', 'Customer')),
      expect: () => [
        AuthLoading(),
        AuthOTPSent('+1234567890'),
      ],
    );
  });
}
```
