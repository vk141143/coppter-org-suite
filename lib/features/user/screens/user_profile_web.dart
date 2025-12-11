import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import 'customer_support_screen.dart';

class UserProfileWeb extends StatefulWidget {
  const UserProfileWeb({super.key});

  @override
  State<UserProfileWeb> createState() => _UserProfileWebState();
}

class _UserProfileWebState extends State<UserProfileWeb> {
  bool _notificationsEnabled = true;
  bool _smsAlerts = false;
  bool _emailUpdates = true;
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = AuthService();
      final profile = await authService.getUserProfile();
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildWebSupport(theme),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            tooltip: 'Back to Dashboard',
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
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
                Text(_isLoading ? 'Loading...' : (_profileData?['full_name'] ?? 'User'), style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_profileData?['email'] ?? 'No email', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text('ID: ${_profileData?['id'] ?? 'N/A'}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: BrandColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (_profileData?['role'] ?? 'customer').toString().toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BrandColors.primaryGreen),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (_profileData?['is_active'] ?? false) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (_profileData?['is_active'] ?? false) ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: (_profileData?['is_active'] ?? false) ? Colors.green : Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showEditProfileDialog(theme),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: BrandColors.primaryGreen),
              foregroundColor: BrandColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: _buildWebStatCard(theme, 'Total Bookings', '24', Icons.list_alt, BrandColors.primaryGreen)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'Completed Pickups', '18', Icons.check_circle, BrandColors.primaryGreen)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'Pending Issues', '3', Icons.pending_actions, const Color(0xFF5A9F6E))),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'This Month', '6', Icons.calendar_today, BrandColors.primaryGreen)),
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
              Expanded(child: _buildWebSettingTile(theme, Icons.notifications_outlined, 'Push Notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v))),
              const SizedBox(width: 16),
              Expanded(child: _buildWebSettingTile(theme, Icons.sms_outlined, 'SMS Alerts', _smsAlerts, (v) => setState(() => _smsAlerts = v))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildWebSettingTile(theme, Icons.email_outlined, 'Email Updates', _emailUpdates, (v) => setState(() => _emailUpdates = v))),
              const SizedBox(width: 16),
              Expanded(child: _buildWebSettingTile(theme, themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Dark Mode', themeProvider.isDarkMode, (v) => themeProvider.toggleTheme())),
            ],
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildOptionButton(theme, Icons.lock_outline, 'Change Password', () {}),
              _buildOptionButton(theme, Icons.language_outlined, 'Language', () {}),
              _buildOptionButton(theme, Icons.location_on_outlined, 'Manage Addresses', () => _showAddressDialog(theme)),
              _buildOptionButton(theme, Icons.credit_card_outlined, 'Payment Methods', () => _showPaymentDialog(theme)),
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
          Switch(value: value, onChanged: onChanged, activeColor: BrandColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildOptionButton(ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
    );
  }



  Widget _buildWebSupport(ThemeData theme) {
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
          Text('Help & Support', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildSupportTile(theme, Icons.support_agent, 'Contact Support', 'Get help from our team', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerSupportScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSupportTile(ThemeData theme, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLogout(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showEditProfileDialog(ThemeData theme) {
    final nameCtrl = TextEditingController(text: _profileData?['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: _profileData?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profileData?['phone_number'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    await picker.pickImage(source: ImageSource.gallery);
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: BrandColors.primaryGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 16),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
                const SizedBox(height: 16),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final authService = AuthService();
                await authService.updateProfile(
                  fullName: nameCtrl.text,
                  email: emailCtrl.text,
                  phoneNumber: phoneCtrl.text,
                );
                Navigator.pop(context);
                _loadProfile();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog(ThemeData theme) {
    final addresses = [
      {'label': 'Home', 'address': '123 Main Street, Apt 4B\nNew York, NY 10001'},
      {'label': 'Work', 'address': '456 Business Ave, Suite 200\nNew York, NY 10002'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Addresses'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: addresses.map((addr) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.location_on, color: BrandColors.primaryGreen),
                  title: Text(addr['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(addr['address']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: BrandColors.primaryGreen), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Add New'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(ThemeData theme) {
    final cards = [
      {'type': 'Visa', 'last4': '4242', 'expiry': '12/25'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Payment Methods'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cards.map((card) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.credit_card, color: BrandColors.primaryGreen),
                  title: Text('${card['type']} •••• ${card['last4']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Expires ${card['expiry']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: BrandColors.primaryGreen), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Add Card'),
          ),
        ],
      ),
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
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
