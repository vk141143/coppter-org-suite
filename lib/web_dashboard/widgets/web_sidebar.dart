import 'package:flutter/material.dart';
import '../../features/user/screens/raise_complaint_screen.dart';
import '../../features/user/screens/track_complaint_screen.dart';
import '../../features/user/screens/complaint_history_screen.dart';
import '../../features/user/screens/customer_support_screen.dart';
import '../../features/user/screens/user_profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';

class WebSidebar extends StatefulWidget {
  const WebSidebar({super.key});

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.add_circle_outline, 'label': 'Raise Service'},
    {'icon': Icons.track_changes, 'label': 'Track Service'},
    {'icon': Icons.history, 'label': 'Service History'},
    {'icon': Icons.support_agent, 'label': 'Support'},
    {'icon': Icons.person, 'label': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'LiftAway',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F1F1F),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleMenuTap(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: Color(0xFF0F5132),
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF0F5132),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RaiseComplaintScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintHistoryScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerSupportScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfileScreen()));
        break;
    }
  }
}
