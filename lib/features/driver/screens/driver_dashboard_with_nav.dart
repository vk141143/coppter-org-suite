import 'package:flutter/material.dart';
import 'advanced_driver_dashboard.dart';
import 'driver_jobs_history_screen.dart';
import 'driver_profile_screen.dart';

class DriverDashboardWithNav extends StatefulWidget {
  const DriverDashboardWithNav({super.key});

  @override
  State<DriverDashboardWithNav> createState() => _DriverDashboardWithNavState();
}

class _DriverDashboardWithNavState extends State<DriverDashboardWithNav> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdvancedDriverDashboard(),
      const DriverJobsHistoryScreen(),
      const DriverProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
