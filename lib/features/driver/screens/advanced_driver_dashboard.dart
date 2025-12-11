import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';
import 'job_navigation_screen.dart';
import 'driver_wallet_screen.dart';
import 'driver_jobs_history_screen.dart';
import 'driver_support_screen.dart';
import '../../auth/screens/login_screen.dart';

class AdvancedDriverDashboard extends StatefulWidget {
  const AdvancedDriverDashboard({super.key});

  @override
  State<AdvancedDriverDashboard> createState() => _AdvancedDriverDashboardState();
}

class _AdvancedDriverDashboardState extends State<AdvancedDriverDashboard> with TickerProviderStateMixin {
  bool _isOnline = false;
  bool _hasActiveJob = false;
  bool _showNotifications = false;
  
  final List<JobRequest> _jobRequests = [];
  final Map<String, Timer> _jobTimers = {};
  final Map<String, int> _countdowns = {};
  
  Timer? _jobGeneratorTimer;
  Timer? _retryTimer;
  
  double _totalEarnings = 245.50;
  int _jobsCompleted = 12;
  double _dailyEarnings = 125.50;
  double _rating = 4.8;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Job Available',
      'message': 'A new pickup request is available nearby',
      'time': '5 min ago',
      'icon': Icons.work,
      'color': Colors.green,
    },
    {
      'title': 'Payment Received',
      'message': 'You received \$25.50 for completed job',
      'time': '1 hour ago',
      'icon': Icons.attach_money,
      'color': Colors.blue,
    },
    {
      'title': 'Rating Update',
      'message': 'Customer rated you 5 stars',
      'time': '2 hours ago',
      'icon': Icons.star,
      'color': Colors.amber,
    },
  ];

  @override
  void dispose() {
    _jobGeneratorTimer?.cancel();
    _retryTimer?.cancel();
    for (var timer in _jobTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _toggleOnlineStatus(bool value) {
    if (!value && _hasActiveJob) {
      _showCannotGoOfflineDialog();
      return;
    }
    
    setState(() {
      _isOnline = value;
    });
    
    if (_isOnline) {
      _startJobRequestSystem();
    } else {
      _stopJobRequestSystem();
    }
  }

  void _startJobRequestSystem() {
    _jobGeneratorTimer?.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      if (_isOnline && !_hasActiveJob && _jobRequests.isEmpty) {
        _generateJobRequest();
      }
    });
  }

  void _stopJobRequestSystem() {
    _jobGeneratorTimer?.cancel();
    _retryTimer?.cancel();
    _clearAllJobRequests();
  }

  void _generateJobRequest() {
    if (!_isOnline || _hasActiveJob || _jobRequests.isNotEmpty) return;
    
    final job = JobRequest(
      id: 'JOB${DateTime.now().millisecondsSinceEpoch}',
      wasteType: _getRandomWasteType(),
      address: _getRandomAddress(),
      distance: (Random().nextDouble() * 10 + 0.5).toStringAsFixed(1),
      payment: (Random().nextInt(30) + 20).toDouble(),
      icon: _getRandomIcon(),
    );
    
    setState(() {
      _jobRequests.add(job);
      _countdowns[job.id] = 45;
    });
    
    _startJobTimer(job);
    _showJobRequestDialog(job);
  }

  void _startJobTimer(JobRequest job) {
    _jobTimers[job.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdowns[job.id]! > 0) {
        setState(() {
          _countdowns[job.id] = _countdowns[job.id]! - 1;
        });
      } else {
        _removeJobRequest(job.id);
      }
    });
  }

  void _showJobRequestDialog(JobRequest job) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JobRequestDialog(
        job: job,
        countdown: _countdowns[job.id] ?? 45,
        onAccept: () => _acceptJob(job),
        onDecline: () => _declineJob(job.id),
        countdownStream: Stream.periodic(
          const Duration(seconds: 1),
          (_) => _countdowns[job.id] ?? 0,
        ),
      ),
    ).then((_) {
      if (_jobRequests.isEmpty && _isOnline && !_hasActiveJob) {
        _retryTimer = Timer(const Duration(seconds: 5), () {
          if (_isOnline && !_hasActiveJob) {
            _generateJobRequest();
          }
        });
      }
    });
  }

  void _acceptJob(JobRequest job) {
    Navigator.pop(context);
    
    setState(() {
      _hasActiveJob = true;
    });
    
    _stopJobRequestSystem();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobNavigationScreen(job: job),
      ),
    ).then((_) {
      setState(() {
        _hasActiveJob = false;
        _jobsCompleted++;
        _dailyEarnings += job.payment;
        _totalEarnings += job.payment;
      });
      
      if (_isOnline) {
        _startJobRequestSystem();
      }
    });
  }

  void _declineJob(String jobId) {
    Navigator.pop(context);
    _removeJobRequest(jobId);
  }

  void _removeJobRequest(String jobId) {
    _jobTimers[jobId]?.cancel();
    _jobTimers.remove(jobId);
    _countdowns.remove(jobId);
    
    setState(() {
      _jobRequests.removeWhere((job) => job.id == jobId);
    });
  }

  void _clearAllJobRequests() {
    for (var timer in _jobTimers.values) {
      timer.cancel();
    }
    _jobTimers.clear();
    _countdowns.clear();
    
    setState(() {
      _jobRequests.clear();
    });
  }

  void _showCannotGoOfflineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cannot Go Offline'),
        content: const Text('You have an active job. Please complete it before going offline.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getRandomWasteType() {
    final types = ['Household Request', 'Recyclable Request', 'Garden Request', 'E-Waste Request', 'Bulk Request'];
    return types[Random().nextInt(types.length)];
  }

  String _getRandomAddress() {
    final addresses = [
      '123 Main Street',
      '456 Oak Avenue',
      '789 Pine Road',
      '321 Elm Street',
      '654 Maple Drive',
    ];
    return addresses[Random().nextInt(addresses.length)];
  }

  String _getRandomIcon() {
    final icons = ['🏠', '♻️', '🌱', '📱', '📦'];
    return icons[Random().nextInt(icons.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: BrandColors.primaryGreen, size: 18),
                const SizedBox(width: 4),
                Text('$_rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  setState(() => _showNotifications = !_showNotifications);
                },
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F5132),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverSupportScreen()));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOnlineStatusCard(),
                      const SizedBox(height: 16),
                      _buildStatsGrid(constraints),
                      const SizedBox(height: 16),
                      if (_hasActiveJob) _buildActiveJobCard(),
                      if (!_isOnline && !_hasActiveJob) _buildOfflineMessage(),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_showNotifications) _buildNotificationDrawer(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatusCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _isOnline
            ? BrandColors.ctaGradient
            : const LinearGradient(colors: [Color(0xFF87C48D), Color(0xFFD1E7DD)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isOnline
            ? [
                BoxShadow(
                  color: BrandColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF87C48D).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isOnline ? Icons.work : Icons.work_off,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'You are Online' : 'You are Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline
                      ? 'Ready to receive job requests'
                      : 'Toggle to start receiving jobs',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: _toggleOnlineStatus,
            activeColor: Colors.white,
            activeTrackColor: BrandColors.secondaryGreen,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1E7DD),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BoxConstraints constraints) {
    final isTablet = constraints.maxWidth > 600;
    final crossAxisCount = isTablet ? 4 : 2;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('Total Earnings', '£${_totalEarnings.toStringAsFixed(2)}', Icons.attach_money, BrandColors.primaryGreen),
        _buildStatCard('Jobs Completed', '$_jobsCompleted', Icons.check_circle, BrandColors.primaryGreen),
        _buildStatCard('Daily Earnings', '£${_dailyEarnings.toStringAsFixed(2)}', Icons.today, BrandColors.primaryGreen),
        _buildStatCard('Rating', '$_rating', Icons.star, BrandColors.primaryGreen),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveJobCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Job',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('You have an active job in progress'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return CustomCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'You are Offline',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Toggle online to start receiving job requests',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDrawer() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        child: Container(
          width: 320,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showNotifications = false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (notification['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              notification['icon'] as IconData,
                              color: notification['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['message'] as String,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification['time'] as String,
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => setState(() => _notifications.clear()),
                  child: const Text('Clear All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: BrandColors.ctaGradient,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 30),
                ),
                SizedBox(height: 12),
                Text(
                  'Mike Johnson',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Driver ID: DRV001',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Wallet'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverWalletScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Jobs History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverJobsHistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class JobRequest {
  final String id;
  final String wasteType;
  final String address;
  final String distance;
  final double payment;
  final String icon;

  JobRequest({
    required this.id,
    required this.wasteType,
    required this.address,
    required this.distance,
    required this.payment,
    required this.icon,
  });
}

class JobRequestDialog extends StatelessWidget {
  final JobRequest job;
  final int countdown;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final Stream<int> countdownStream;

  const JobRequestDialog({
    super.key,
    required this.job,
    required this.countdown,
    required this.onAccept,
    required this.onDecline,
    required this.countdownStream,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'New Job Request',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder<int>(
                  stream: countdownStream,
                  initialData: countdown,
                  builder: (context, snapshot) {
                    final time = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: time < 10 ? const Color(0xFF0F5132) : const Color(0xFF0F5132),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${time}s',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(job.icon, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.wasteType,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '£${job.payment.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: BrandColors.primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.location_on, job.address),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.directions_car, '${job.distance} km away'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: BrandColors.secondaryGreen, width: 1.5),
                      foregroundColor: const Color(0xFF0F5132),
                    ),
                    child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: BrandColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
