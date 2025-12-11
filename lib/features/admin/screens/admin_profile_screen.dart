import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;

    if (isWeb) {
      return _buildWebLayout(theme, themeProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(theme),
              const SizedBox(height: 24),
              _buildAdminStats(theme),
              const SizedBox(height: 24),
              _buildSettings(theme, themeProvider),
              const SizedBox(height: 24),
              _buildRecentActions(theme),
              const SizedBox(height: 24),
              _buildLogoutButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebLayout(ThemeData theme, ThemeProvider themeProvider) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWebHeader(theme),
                const SizedBox(height: 32),
                _buildWebStats(theme),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildWebSettings(theme, themeProvider),
                          const SizedBox(height: 24),
                          _buildWebRecentActions(theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildWebSystemInfo(theme),
                          const SizedBox(height: 24),
                          _buildWebLogout(theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.admin_panel_settings, size: 60, color: theme.colorScheme.primary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    Text('Admin User', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Text('admin@wastemanagement.com', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 24),
                      const SizedBox(width: 6),
                      Text('Super Admin', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildWebStatCard(theme, 'Total Actions', '1,234', Icons.touch_app, theme.colorScheme.primary)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'Resolved Issues', '856', Icons.check_circle, Colors.green)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'Active Users', '2,567', Icons.people, Colors.orange)),
      ],
    );
  }

  Widget _buildWebStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebSystemInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildInfoRow(theme, 'Role', 'Super Admin'),
          const SizedBox(height: 12),
          _buildInfoRow(theme, 'Access Level', 'Full Access'),
          const SizedBox(height: 12),
          _buildInfoRow(theme, 'Last Login', 'Today, 10:30 AM'),
          const SizedBox(height: 12),
          _buildInfoRow(theme, 'Account Created', 'Jan 15, 2024'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, child: const Text('Edit Profile'))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildWebSettings(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildWebSettingTile(theme, Icons.notifications_outlined, 'Notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v))),
              const SizedBox(width: 16),
              Expanded(child: _buildWebSettingTile(theme, Icons.email_outlined, 'Email Alerts', _emailNotifications, (v) => setState(() => _emailNotifications = v))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildWebSettingTile(theme, themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Dark Mode', themeProvider.isDarkMode, (v) => themeProvider.toggleTheme())),
              const SizedBox(width: 16),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebSettingTile(ThemeData theme, IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildWebRecentActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(60),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05)),
                children: [
                  _tableHeader(''),
                  _tableHeader('Action'),
                  _tableHeader('Details'),
                  _tableHeader('Time'),
                ],
              ),
              _tableRow(theme, '✅', 'Approved Driver', 'Mike Johnson - DR001234', '10 min ago'),
              _tableRow(theme, '📋', 'Updated Complaint', 'WM001234 - Status Changed', '25 min ago'),
              _tableRow(theme, '👤', 'Added User', 'John Smith - New Registration', '1 hour ago'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  TableRow _tableRow(ThemeData theme, String icon, String action, String details, String time) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(icon, style: const TextStyle(fontSize: 24))),
        Padding(padding: const EdgeInsets.all(12), child: Text(action, style: const TextStyle(fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(12), child: Text(details)),
        Padding(padding: const EdgeInsets.all(12), child: Text(time, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)))),
      ],
    );
  }

  Widget _buildWebLogout(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(text: 'Logout', onPressed: _handleLogout, backgroundColor: Colors.red, icon: Icons.logout, height: 56),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return CustomCard(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.admin_panel_settings, size: 50, color: theme.colorScheme.primary),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Admin User', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('admin@wastemanagement.com', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, color: Colors.green, size: 20),
              const SizedBox(width: 4),
              Text('Super Admin', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, 'Total Actions', '1,234', Icons.touch_app, theme.colorScheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, 'Resolved', '856', Icons.check_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(theme, 'Active Users', '2,567', Icons.people, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSettings(ThemeData theme, ThemeProvider themeProvider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSwitchTile(theme, Icons.notifications_outlined, 'Push Notifications', 'Receive system notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
          _buildSwitchTile(theme, Icons.email_outlined, 'Email Notifications', 'Receive email alerts', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
          _buildSwitchTile(theme, themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Dark Mode', 'Switch between light and dark theme', themeProvider.isDarkMode, (v) => themeProvider.toggleTheme()),
          _buildOptionTile(theme, Icons.security, 'Security', 'Password and security settings', () {}),
        ],
      ),
    );
  }

  Widget _buildRecentActions(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildActionItem(theme, 'Approved Driver', 'Mike Johnson - DR001234', '10 min ago', '✅'),
              const Divider(),
              _buildActionItem(theme, 'Updated Complaint', 'WM001234 - Status Changed', '25 min ago', '📋'),
              const Divider(),
              _buildActionItem(theme, 'Added User', 'John Smith - New Registration', '1 hour ago', '👤'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(ThemeData theme, String action, String details, String time, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(details, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          Text(time, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return CustomButton(text: 'Logout', onPressed: _handleLogout, backgroundColor: Colors.red, icon: Icons.logout);
  }

  Widget _buildSwitchTile(ThemeData theme, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildOptionTile(ThemeData theme, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
