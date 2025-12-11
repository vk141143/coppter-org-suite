# Provider State Management Usage Guide

## Overview

Your app uses **Provider** for state management with the following providers:

- `AuthProvider` - Authentication & user management
- `WasteProvider` - Waste requests & complaints
- `DriverProvider` - Driver jobs & earnings
- `AdminProvider` - Admin dashboard & management

## Setup Complete ✅

All providers are registered in `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => WasteProvider()),
    ChangeNotifierProvider(create: (context) => DriverProvider()),
    ChangeNotifierProvider(create: (context) => AdminProvider()),
  ],
)
```

## Usage Examples

### 1. AuthProvider - Login Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _selectedUserType = 'Customer';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show error if exists
        if (authProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
            authProvider.clearError();
          });
        }

        return Scaffold(
          body: Column(
            children: [
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final success = await authProvider.login(
                          _phoneController.text,
                          _selectedUserType,
                        );
                        if (success) {
                          // Navigate to OTP screen
                          Navigator.pushNamed(context, '/otp');
                        }
                      },
                child: authProvider.isLoading
                    ? CircularProgressIndicator()
                    : Text('Send OTP'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 2. WasteProvider - Submit Complaint

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/core/providers/waste_provider.dart';

class RaiseComplaintScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wasteProvider = Provider.of<WasteProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: wasteProvider.isLoading
                ? null
                : () async {
                    final success = await wasteProvider.submitRequest(
                      latitude: 37.7749,
                      longitude: -122.4194,
                      wasteType: 'Plastic',
                      description: 'Large plastic waste',
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Request submitted!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(wasteProvider.error ?? 'Error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            child: wasteProvider.isLoading
                ? CircularProgressIndicator()
                : Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
```

### 3. WasteProvider - Display Complaints

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/core/providers/waste_provider.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  @override
  _ComplaintHistoryScreenState createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load complaints when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WasteProvider>().loadComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Complaints')),
      body: Consumer<WasteProvider>(
        builder: (context, wasteProvider, child) {
          if (wasteProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (wasteProvider.error != null) {
            return Center(child: Text('Error: ${wasteProvider.error}'));
          }

          if (wasteProvider.complaints.isEmpty) {
            return Center(child: Text('No complaints found'));
          }

          return ListView.builder(
            itemCount: wasteProvider.complaints.length,
            itemBuilder: (context, index) {
              final complaint = wasteProvider.complaints[index];
              return ListTile(
                title: Text(complaint['waste_type'] ?? 'Unknown'),
                subtitle: Text(complaint['status'] ?? 'Pending'),
                trailing: Text(complaint['created_at'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 4. DriverProvider - Job Management

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/core/providers/driver_provider.dart';

class DriverDashboard extends StatefulWidget {
  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverProvider = context.read<DriverProvider>();
      driverProvider.loadJobs();
      driverProvider.loadEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Dashboard')),
      body: Consumer<DriverProvider>(
        builder: (context, driverProvider, child) {
          return Column(
            children: [
              // Online/Offline Toggle
              SwitchListTile(
                title: Text('Online Status'),
                value: driverProvider.isOnline,
                onChanged: (value) {
                  driverProvider.toggleOnlineStatus();
                },
              ),

              // Earnings Display
              if (driverProvider.earnings != null)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Total Earnings: \$${driverProvider.earnings!['total']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // Jobs List
              Expanded(
                child: driverProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: driverProvider.jobs.length,
                        itemBuilder: (context, index) {
                          final job = driverProvider.jobs[index];
                          return ListTile(
                            title: Text(job['customer_name'] ?? 'Unknown'),
                            subtitle: Text(job['address'] ?? ''),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final success = await driverProvider.acceptJob(job['id']);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Job accepted!')),
                                  );
                                }
                              },
                              child: Text('Accept'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 5. AdminProvider - Dashboard

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/core/providers/admin_provider.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = context.read<AdminProvider>();
      adminProvider.loadDashboardStats();
      adminProvider.loadComplaints();
      adminProvider.loadDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Stats Cards
                if (adminProvider.stats != null)
                  Row(
                    children: [
                      _StatCard(
                        title: 'Total Complaints',
                        value: adminProvider.stats!['total_complaints'].toString(),
                      ),
                      _StatCard(
                        title: 'Active Drivers',
                        value: adminProvider.stats!['active_drivers'].toString(),
                      ),
                    ],
                  ),

                // Recent Complaints
                Text('Recent Complaints', style: TextStyle(fontSize: 20)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: adminProvider.complaints.take(5).length,
                  itemBuilder: (context, index) {
                    final complaint = adminProvider.complaints[index];
                    return ListTile(
                      title: Text(complaint['waste_type'] ?? 'Unknown'),
                      subtitle: Text(complaint['status'] ?? 'Pending'),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title),
              SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Key Patterns

### 1. Consumer Pattern (Reactive UI)
```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?['name'] ?? 'Guest');
  },
)
```

### 2. Provider.of Pattern (One-time read)
```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.login(phone, userType);
```

### 3. context.read Pattern (No rebuild)
```dart
context.read<WasteProvider>().loadComplaints();
```

### 4. context.watch Pattern (Auto rebuild)
```dart
final isLoading = context.watch<AuthProvider>().isLoading;
```

## Error Handling

All providers have built-in error handling:

```dart
if (authProvider.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.error!)),
  );
  authProvider.clearError();
}
```

## Loading States

All providers have `isLoading` property:

```dart
ElevatedButton(
  onPressed: authProvider.isLoading ? null : _handleLogin,
  child: authProvider.isLoading 
      ? CircularProgressIndicator() 
      : Text('Login'),
)
```

## Benefits

✅ **Centralized State** - All API state in one place
✅ **Automatic UI Updates** - UI rebuilds when data changes
✅ **Error Handling** - Built-in error management
✅ **Loading States** - Easy loading indicators
✅ **Clean Code** - Separation of business logic and UI
✅ **Testable** - Easy to test providers independently

## Next Steps

Replace your existing screens with Provider-based implementations:
1. Update `login_screen.dart` to use `AuthProvider`
2. Update `user_dashboard.dart` to use `WasteProvider`
3. Update `driver_dashboard.dart` to use `DriverProvider`
4. Update `admin_dashboard.dart` to use `AdminProvider`
