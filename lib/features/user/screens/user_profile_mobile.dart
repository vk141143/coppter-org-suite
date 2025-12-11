import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/auto_text.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';

class UserProfileMobile extends StatefulWidget {
  const UserProfileMobile({super.key});

  @override
  State<UserProfileMobile> createState() => _UserProfileMobileState();
}

class _UserProfileMobileState extends State<UserProfileMobile> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
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
      appBar: AppBar(
        title: const AutoText('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
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
              const SizedBox(height: 32),
              _buildProfileOptions(theme, themeProvider),
              const SizedBox(height: 24),
              _buildNotificationSettings(theme),
              const SizedBox(height: 24),
              _buildAppSettings(theme, themeProvider),
              const SizedBox(height: 24),
              _buildLogoutButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    if (_isLoading) {
      return CustomCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          ),
        ),
      );
    }

    final fullName = _profileData?['full_name'] ?? 'User';
    final email = _profileData?['email'] ?? 'No email';
    final phone = _profileData?['phone_number'] ?? 'No phone';
    final role = _profileData?['role'] ?? 'customer';
    final isActive = _profileData?['is_active'] ?? false;

    return CustomCard(
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Text(
            fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1F1F1F).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            phone,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1F1F1F).withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(ThemeData theme, ThemeProvider themeProvider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText('Account', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildOptionTile(theme, Icons.person_outline, 'Personal Information', 'Update your personal details', () => _showEditDialog()),
          _buildOptionTile(theme, Icons.location_on_outlined, 'Address Book', 'Manage your addresses', () => _showAddressDialog()),
          _buildOptionTile(theme, Icons.payment_outlined, 'Payment Methods', 'Manage payment options', () => _showPaymentDialog()),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText('Notifications', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSwitchTile(theme, Icons.notifications_outlined, 'Push Notifications', 'Receive app notifications', _notificationsEnabled, (value) => setState(() => _notificationsEnabled = value)),
          _buildSwitchTile(theme, Icons.email_outlined, 'Email Notifications', 'Receive email updates', _emailNotifications, (value) => setState(() => _emailNotifications = value)),
          _buildSwitchTile(theme, Icons.sms_outlined, 'SMS Notifications', 'Receive SMS updates', _smsNotifications, (value) => setState(() => _smsNotifications = value)),
        ],
      ),
    );
  }

  Widget _buildAppSettings(ThemeData theme, ThemeProvider themeProvider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText('App Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSwitchTile(theme, themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Dark Mode', 'Switch between light and dark theme', themeProvider.isDarkMode, (value) => themeProvider.toggleTheme()),
          _buildOptionTile(theme, Icons.language_outlined, 'Language', 'English', () => _showLanguageDialog()),
          _buildOptionTile(theme, Icons.info_outline, 'About', 'App version and information', () => _showAboutDialog()),
          _buildOptionTile(theme, Icons.privacy_tip_outlined, 'Privacy Policy', 'Read our privacy policy', () {}),
          _buildOptionTile(theme, Icons.description_outlined, 'Terms of Service', 'Read terms and conditions', () {}),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return CustomButton(text: 'Logout', onPressed: _handleLogout, backgroundColor: const Color(0xFF0F5132), icon: Icons.logout);
  }

  Widget _buildOptionTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: AutoText(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: AutoText(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: AutoText(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: AutoText(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _editProfile() {
    _showEditDialog();
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: _profileData?['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: _profileData?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: _profileData?['phone_number'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AutoText('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))),
              const SizedBox(height: 16),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const AutoText('Cancel')),
          ElevatedButton(onPressed: () async {
            try {
              final authService = AuthService();
              await authService.updateProfile(
                fullName: nameCtrl.text,
                email: emailCtrl.text,
                phoneNumber: phoneCtrl.text,
              );
              Navigator.pop(context);
              _loadProfile();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: AutoText('Profile updated!')));
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AutoText(e.toString()), backgroundColor: Colors.red));
            }
          }, child: const AutoText('Save')),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AutoText('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (Home/Work)', prefixIcon: Icon(Icons.label))),
            const SizedBox(height: 16),
            TextField(controller: addressCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address added!'))); }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    final cardCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AutoText('Add Payment Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cardCtrl, decoration: const InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card))),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Card Holder', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Flexible(child: TextField(controller: expiryCtrl, decoration: const InputDecoration(labelText: 'MM/YY'))),
                  const SizedBox(width: 12),
                  Flexible(child: TextField(controller: cvvCtrl, decoration: const InputDecoration(labelText: 'CVV'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card added!'))); }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final currentLang = languageProvider.currentLanguage;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const AutoText('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageProvider.languages.entries.map((entry) {
              final isSelected = entry.key == currentLang;
              return ListTile(
                leading: Text(entry.value['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(entry.value['name']!),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  languageProvider.changeLanguage(entry.key);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language changed to ${entry.value['name']}')),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(title: const AutoText('About'), content: const AutoText('Waste Management App\nVersion 1.0.0'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const AutoText('OK'))]));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () {Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132), foregroundColor: Colors.white), child: const Text('Logout')),
        ],
      ),
    );
  }
}
