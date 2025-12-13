import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/user/screens/user_dashboard.dart';
import '../../features/driver/screens/driver_main_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/animated_intro_screen.dart';
import 'secure_storage.dart';

class RoleNavigator {
  /// Navigate to appropriate dashboard based on role
  static Future<void> navigateByRole(BuildContext context) async {
    final role = await SecureStorage.getUserRole();
    
    if (role == null || role.isEmpty) {
      // Not logged in
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return;
    }
    
    Widget dashboard;
    
    switch (role.toLowerCase()) {
      case 'admin':
        dashboard = const AdminDashboard();
        break;
      case 'driver':
        dashboard = const DriverMainScreen();
        break;
      case 'customer':
        dashboard = const UserDashboard();
        break;
      default:
        dashboard = const LoginScreen();
    }
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboard),
      (route) => false,
    );
  }

  /// Get initial screen based on stored role
  static Future<Widget> getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    
    print('🚀 Getting initial screen...');
    print('  Has seen intro: $hasSeenIntro');
    
    // Always show intro on first launch or when not authenticated
    final isAuth = await SecureStorage.isAuthenticated();
    print('  Is authenticated: $isAuth');
    
    if (!hasSeenIntro || !isAuth) {
      print('→ Showing AnimatedIntroScreen');
      return const AnimatedIntroScreen();
    }

    final role = await SecureStorage.getUserRole();
    print('  User role: $role');
    
    switch (role?.toLowerCase()) {
      case 'admin':
        print('→ AUTO-NAVIGATING to AdminDashboard');
        return const AdminDashboard();
      case 'driver':
        print('→ AUTO-NAVIGATING to DriverMainScreen');
        return const DriverMainScreen();
      case 'customer':
        print('→ AUTO-NAVIGATING to UserDashboard');
        return const UserDashboard();
      default:
        print('→ Showing LoginScreen');
        return const LoginScreen();
    }
  }

  /// Logout and navigate to login
  static Future<void> logout(BuildContext context) async {
    await SecureStorage.clearAll();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
