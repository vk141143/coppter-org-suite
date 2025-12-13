import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/blocs/auth/auth_bloc.dart';
import 'core/blocs/auth/auth_event.dart';
import 'core/blocs/waste/waste_bloc.dart';
import 'core/blocs/driver/driver_bloc.dart';
import 'core/blocs/admin/admin_bloc.dart';
import 'core/providers/language_provider.dart';
import 'features/auth/screens/animated_intro_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/user/screens/user_dashboard.dart';
import 'features/driver/screens/driver_main_screen.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'core/utils/role_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('⚠️ .env file not loaded: $e');
  }
  runApp(const WasteManagementApp());
}

class WasteManagementApp extends StatelessWidget {
  const WasteManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        BlocProvider(create: (context) => AuthBloc()..add(AuthCheckStatus())),
        BlocProvider(create: (context) => WasteBloc()),
        BlocProvider(create: (context) => DriverBloc()),
        BlocProvider(create: (context) => AdminBloc()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'LiftAway',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routes: {
            '/': (context) => FutureBuilder<Widget>(
              future: _getInitialScreen(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                return snapshot.data ?? const AnimatedIntroScreen();
              },
            ),
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const UserDashboard(),
            '/driver': (context) => const DriverMainScreen(),
            '/admin': (context) => const AdminDashboard(),
          },
          initialRoute: '/',
        ),
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    try {
      return await RoleNavigator.getInitialScreen();
    } catch (e) {
      debugPrint('❌ Error getting initial screen: $e');
      return const LoginScreen();
    }
  }
}