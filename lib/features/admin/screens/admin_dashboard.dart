import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import 'complaint_management_screen.dart';
import 'driver_management_screen.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';
import 'bookings_screen.dart';
import 'pricing_screen.dart';
import 'disputes_screen.dart';
import 'support_screen.dart';
import 'branches_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_notifications_screen.dart';
import 'category_management_screen.dart';
import '../../auth/screens/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  int _hoveredIndex = -1;

  final List<Widget> _screens = [
    const AdminHome(),
    const BookingsScreen(),
    const ComplaintManagementScreen(),
    const DriverManagementScreen(),
    const UserManagementScreen(),
    const PricingScreen(),
    const CategoryManagementScreen(),
    const DisputesScreen(),
    const SupportScreen(),
    const BranchesScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;

    if (isWeb) {
      return _buildWebLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildWebLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2),
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF0F5132).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F5132).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Color(0xFF0F5132), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text('LiftAway Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildNavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.book_outlined, Icons.book, 'Bookings', 1, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.report_problem_outlined, Icons.report_problem, 'Complaints', 2, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.local_shipping_outlined, Icons.local_shipping, 'Drivers', 3, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.people_outline, Icons.people, 'Users', 4, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.attach_money_outlined, Icons.attach_money, 'Pricing', 5, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.category_outlined, Icons.category, 'Categories', 6, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.gavel_outlined, Icons.gavel, 'Disputes', 7, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.support_agent_outlined, Icons.support_agent, 'Support', 8, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.location_city_outlined, Icons.location_city, 'Branches', 9, isDark),
                      const SizedBox(height: 4),
                      _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Analytics', 10, isDark),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87C48D).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_outlined, size: 18, color: Color(0xFF0F5132)),
                          const SizedBox(width: 12),
                          const Text('Logout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F5132))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey(_currentIndex),
                child: _screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData selectedIcon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F5132).withOpacity(0.1)
                : isHovered
                    ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFD1E7DD).withOpacity(0.3))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: isSelected ? const Color(0xFF0F5132) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 20,
                color: isSelected ? const Color(0xFF0F5132) : (isDark ? Colors.white70 : const Color(0xFF1F1F1F).withOpacity(0.7)),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F5132) : (isDark ? Colors.white70 : const Color(0xFF1F1F1F)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiftAway Admin'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
                  );
                },
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F5132),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  const Text('LiftAway Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                  _buildDrawerItem(Icons.book, 'Bookings', 1),
                  _buildDrawerItem(Icons.report_problem, 'Complaints', 2),
                  _buildDrawerItem(Icons.local_shipping, 'Drivers', 3),
                  _buildDrawerItem(Icons.people, 'Users', 4),
                  _buildDrawerItem(Icons.attach_money, 'Pricing', 5),
                  _buildDrawerItem(Icons.category, 'Categories', 6),
                  _buildDrawerItem(Icons.gavel, 'Disputes', 7),
                  _buildDrawerItem(Icons.support_agent, 'Support', 8),
                  _buildDrawerItem(Icons.location_city, 'Branches', 9),
                  _buildDrawerItem(Icons.analytics, 'Analytics', 10),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF0F5132)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
  
  Widget _buildDrawerItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0F5132) : null),
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? const Color(0xFF0F5132) : null)),
      selected: isSelected,
      selectedTileColor: const Color(0xFF0F5132).withOpacity(0.1),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isWeb ? 32 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, isWeb),
                  const SizedBox(height: 32),
                  _buildStatsCards(theme, isWeb),
                  const SizedBox(height: 32),
                  _buildChartsSection(theme, isWeb),
                  const SizedBox(height: 32),
                  _buildRecentActivity(theme, isWeb),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isWeb) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isWeb ? 32 : 22,
                  color: const Color(0xFF1F1F1F),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, Admin',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF1F1F1F).withOpacity(0.6),
                  fontSize: isWeb ? 16 : 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined, color: Color(0xFF0F5132), size: 20),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0F5132).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF0F5132), size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(ThemeData theme, bool isWeb) {
    return GridView.count(
      crossAxisCount: isWeb ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWeb ? 1.3 : 1.4,
      children: [
        _buildStatCard(theme, 'Total Complaints', '1,234', Icons.report_problem, const Color(0xFF0F5132), '+12%'),
        _buildStatCard(theme, 'Resolved Today', '45', Icons.check_circle, const Color(0xFF0F5132), '8 pending'),
        _buildStatCard(theme, 'Active Drivers', '28', Icons.local_shipping, const Color(0xFF0F5132), '5 offline'),
        _buildStatCard(theme, 'Total Users', '2,567', Icons.people, const Color(0xFF0F5132), '+45 week'),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 12 : 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isWeb ? 8 : 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: isWeb ? 18 : 14),
                ),
                Icon(Icons.trending_up, color: Colors.green, size: isWeb ? 14 : 11),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isWeb ? 24 : 20,
                    color: const Color(0xFF1F1F1F),
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isWeb ? 12 : 11,
                    color: const Color(0xFF1F1F1F),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1F1F1F).withOpacity(0.6),
                    fontSize: isWeb ? 10 : 9,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ThemeData theme, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isWeb ? 24 : 20,
          ),
        ),
        const SizedBox(height: 24),
        isWeb
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildCategoryChart(theme)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildStatusChart(theme)),
                ],
              )
            : Column(
                children: [
                  _buildCategoryChart(theme),
                  const SizedBox(height: 16),
                  _buildStatusChart(theme),
                ],
              ),
      ],
    );
  }

  Widget _buildCategoryChart(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 35,
                    color: const Color(0xFF0F5132),
                    title: '35%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: const Color(0xFF2D7A4F),
                    title: '25%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: const Color(0xFF5A9F6E),
                    title: '20%',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: const Color(0xFF87C48D),
                    title: '20%',
                    radius: 50,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildLegendItem('Household', const Color(0xFF0F5132)),
              _buildLegendItem('Recyclables', const Color(0xFF2D7A4F)),
              _buildLegendItem('Garden', const Color(0xFF5A9F6E)),
              _buildLegendItem('Others', const Color(0xFF87C48D)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChart(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Pending');
                          case 1:
                            return const Text('Assigned');
                          case 2:
                            return const Text('Progress');
                          case 3:
                            return const Text('Complete');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 25, color: const Color(0xFF0F5132)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 40, color: const Color(0xFF2D7A4F)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 60, color: const Color(0xFF5A9F6E)),
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 80, color: const Color(0xFF87C48D)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ThemeData theme, bool isWeb) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isWeb ? 24 : 20,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const ShimmerList(itemCount: 5, itemHeight: 70)
            : CustomCard(
                child: Column(
                  children: [
                    _buildActivityItem(theme, Icons.person_add, 'New user registered', 'John Smith joined the platform', '5 min ago', const Color(0xFF0F5132)),
                    const Divider(height: 24),
                    _buildActivityItem(theme, Icons.report_problem, 'New complaint submitted', 'Household waste collection request', '12 min ago', const Color(0xFF0F5132)),
                    const Divider(height: 24),
                    _buildActivityItem(theme, Icons.check_circle, 'Complaint resolved', 'WM001234 marked as completed', '25 min ago', const Color(0xFF0F5132)),
                    const Divider(height: 24),
                    _buildActivityItem(theme, Icons.local_shipping, 'Driver assigned', 'Mike Johnson assigned to WM001235', '1 hour ago', const Color(0xFF0F5132)),
                    const Divider(height: 24),
                    _buildActivityItem(theme, Icons.star, 'High rating received', 'Driver received 5-star rating', '2 hours ago', const Color(0xFF0F5132)),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildActivityItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
    String time,
    Color color,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isWeb ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: isWeb ? 20 : 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isWeb ? 16 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: isWeb ? 14 : 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
              fontSize: isWeb ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}