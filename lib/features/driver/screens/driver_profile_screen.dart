import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/screens/login_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _isAvailable = true;
  bool _notificationsEnabled = true;
  
  String _driverName = 'Mike Johnson';
  String _driverId = 'DR001234';
  String _phoneNumber = '+44 7700 900123';
  String _email = 'mike.johnson@liftaway.com';
  String _vehicleNumber = 'WM-1234';
  String _licenseNumber = 'DL123456789';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 800;
        
        if (isWeb) {
          return _buildWebLayout(theme, themeProvider);
        }
        
        // Mobile layout (unchanged)
        return Scaffold(
          appBar: AppBar(
            title: const Text('Driver Profile'),
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
                  const SizedBox(height: 24),
                  _buildDriverStats(theme),
                  const SizedBox(height: 24),
                  _buildVehicleDetails(theme),
                  const SizedBox(height: 24),
                  _buildSettings(theme, themeProvider),
                  const SizedBox(height: 24),
                  _buildHistory(theme),
                  const SizedBox(height: 24),
                  _buildLogoutButton(theme),
                ],
              ),
            ),
          ),
        );
      },
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
                // Web Header - Horizontal Layout
                _buildWebHeader(theme),
                const SizedBox(height: 32),
                
                // Stats Row
                _buildWebStats(theme),
                const SizedBox(height: 32),
                
                // Two Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildWebSettings(theme, themeProvider),
                          const SizedBox(height: 24),
                          _buildWebHistory(theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    // Right Column
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildWebVehicle(theme),
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
                Row(
                  children: [
                    Expanded(child: Text(_driverName, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
                    IconButton(
                      onPressed: () => _showEditDialog(context, true),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Driver ID: $_driverId', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(_phoneNumber, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text(_email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, color: BrandColors.primaryGreen, size: 24),
                    const SizedBox(width: 6),
                    Text('4.8', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('(124 reviews)', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _isAvailable ? BrandColors.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(_isAvailable ? Icons.check_circle : Icons.cancel, color: _isAvailable ? BrandColors.primaryGreen : Colors.red, size: 24),
                const SizedBox(width: 12),
                Text(_isAvailable ? 'Available' : 'Offline', style: TextStyle(color: _isAvailable ? BrandColors.primaryGreen : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 12),
                Switch(value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v)),
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
        Expanded(child: _buildWebStatCard(theme, 'Total Earnings', '£2,450', Icons.attach_money, BrandColors.primaryGreen)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'Completed Jobs', '156', Icons.check_circle, BrandColors.primaryGreen)),
        const SizedBox(width: 24),
        Expanded(child: _buildWebStatCard(theme, 'This Month', '24', Icons.calendar_today, BrandColors.primaryGreen)),
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

  Widget _buildWebVehicle(ThemeData theme) {
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
          Text('Vehicle Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.local_shipping, color: theme.colorScheme.primary, size: 48),
          ),
          const SizedBox(height: 16),
          Text('Waste Collection Truck', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Vehicle: $_vehicleNumber', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text('License: $_licenseNumber', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _showEditDialog(context, true), child: const Text('Edit Details'))),
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
              Expanded(child: _buildWebSettingTile(theme, Icons.notifications_outlined, 'Notifications', _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v))),
              const SizedBox(width: 16),
              Expanded(child: _buildWebSettingTile(theme, themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, 'Dark Mode', themeProvider.isDarkMode, (v) => themeProvider.toggleTheme())),
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

  Widget _buildWebHistory(ThemeData theme) {
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
              Text('Recent Jobs', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
              4: FixedColumnWidth(100),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05)),
                children: [
                  _tableHeader(''),
                  _tableHeader('Category'),
                  _tableHeader('Address'),
                  _tableHeader('Date'),
                  _tableHeader('Earnings'),
                ],
              ),
              _tableRow(theme, '🏠', 'Household Waste', '123 Main Street', 'Mar 15', '£25.00'),
              _tableRow(theme, '♻️', 'Recyclables', '456 Oak Avenue', 'Mar 14', '£20.00'),
              _tableRow(theme, '🌱', 'Garden Waste', '789 Pine Road', 'Mar 13', '£30.00'),
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

  TableRow _tableRow(ThemeData theme, String icon, String category, String address, String date, String earnings) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(icon, style: const TextStyle(fontSize: 24))),
        Padding(padding: const EdgeInsets.all(12), child: Text(category, style: const TextStyle(fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(12), child: Text(address)),
        Padding(padding: const EdgeInsets.all(12), child: Text(date)),
        Padding(padding: const EdgeInsets.all(12), child: Text(earnings, style: const TextStyle(fontWeight: FontWeight.bold, color: BrandColors.primaryGreen))),
      ],
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

  Widget _buildProfileHeader(ThemeData theme) {
    return CustomCard(
      child: Column(
        children: [
          // Edit Button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () => _showEditDialog(context, false),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
          ),
          
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
          
          // Driver Info
          Text(
            _driverName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Driver ID: $_driverId',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            _phoneNumber,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: BrandColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '4.8',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(124 reviews)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Availability Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? BrandColors.primaryGreen.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isAvailable ? Icons.check_circle : Icons.cancel,
                  color: _isAvailable ? BrandColors.primaryGreen : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _isAvailable ? 'Available for Jobs' : 'Not Available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _isAvailable ? BrandColors.primaryGreen : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Earnings',
            '£2,450',
            Icons.attach_money,
            BrandColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Completed Jobs',
            '156',
            Icons.check_circle,
            BrandColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'This Month',
            '24',
            Icons.calendar_today,
            BrandColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetails(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waste Collection Truck',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'Vehicle Number: $_vehicleNumber',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'License: $_licenseNumber',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              OutlinedButton(
                onPressed: () => _showEditDialog(context, false),
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(ThemeData theme, ThemeProvider themeProvider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            theme,
            Icons.notifications_outlined,
            'Push Notifications',
            'Receive job notifications',
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          _buildSwitchTile(
            theme,
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            'Dark Mode',
            'Switch between light and dark theme',
            themeProvider.isDarkMode,
            (value) {
              themeProvider.toggleTheme();
            },
          ),
          
          _buildOptionTile(
            theme,
            Icons.language_outlined,
            'Language',
            'English',
            () {},
          ),
          
          _buildOptionTile(
            theme,
            Icons.help_outline,
            'Help & Support',
            'Get help and contact support',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(ThemeData theme) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Jobs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildHistoryItem(
                theme,
                'Household Waste',
                '123 Main Street',
                'March 15, 2024',
                '£25.00',
                '🏠',
              ),
              const Divider(),
              _buildHistoryItem(
                theme,
                'Recyclables',
                '456 Oak Avenue',
                'March 14, 2024',
                '£20.00',
                '♻️',
              ),
              const Divider(),
              _buildHistoryItem(
                theme,
                'Garden Waste',
                '789 Pine Road',
                'March 13, 2024',
                '£30.00',
                '🌱',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    ThemeData theme,
    String category,
    String address,
    String date,
    String earnings,
    String icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            earnings,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: BrandColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: _handleLogout,
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: BrandColors.primaryGreen,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
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
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, bool isWeb) {
    final nameController = TextEditingController(text: _driverName);
    final phoneController = TextEditingController(text: _phoneNumber);
    final emailController = TextEditingController(text: _email);
    final vehicleController = TextEditingController(text: _vehicleNumber);
    final licenseController = TextEditingController(text: _licenseNumber);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number',
                    prefixIcon: Icon(Icons.local_shipping),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: licenseController,
                  decoration: const InputDecoration(
                    labelText: 'License Number',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _driverName = nameController.text;
                  _phoneNumber = phoneController.text;
                  _email = emailController.text;
                  _vehicleNumber = vehicleController.text;
                  _licenseNumber = licenseController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}