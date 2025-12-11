import 'package:flutter/material.dart';
import 'widgets/web_sidebar.dart';
import 'widgets/top_navbar.dart';
import 'widgets/top_greeting_section.dart';
import 'widgets/quick_actions_web.dart';
import 'widgets/suggestions_section.dart';
import 'widgets/promotional_offers_section.dart';
import 'widgets/recent_complaints_section.dart';
import 'widgets/notification_drawer_web.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  bool _showNotifications = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar
          const WebSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navbar
                TopNavbar(
                  onNotificationTap: () {
                    setState(() => _showNotifications = !_showNotifications);
                  },
                ),
                
                // Content Area
                Expanded(
                  child: Stack(
                    children: [
                      // Main Dashboard Content
                      Container(
                        color: theme.colorScheme.surface,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick Actions
                              const QuickActionsWeb(),
                              
                              const SizedBox(height: 24),
                              
                              // Suggestions
                              const SuggestionsSection(),
                              
                              const SizedBox(height: 24),
                              
                              // Promotional Offers
                              const PromotionalOffersSection(),
                              
                              const SizedBox(height: 24),
                              
                              // Recent Complaints
                              const RecentComplaintsSection(),
                            ],
                          ),
                        ),
                      ),
                      
                      // Notification Drawer
                      if (_showNotifications)
                        NotificationDrawerWeb(
                          onClose: () => setState(() => _showNotifications = false),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
