import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class DriverJobsHistoryScreen extends StatefulWidget {
  const DriverJobsHistoryScreen({super.key});

  @override
  State<DriverJobsHistoryScreen> createState() => _DriverJobsHistoryScreenState();
}

class _DriverJobsHistoryScreenState extends State<DriverJobsHistoryScreen> {
  String _selectedFilter = 'All';
  int _hoveredRow = -1;
  String _sortColumn = '';
  bool _sortAscending = true;
  
  final List<String> _filters = ['All', 'Completed', 'In Progress', 'Cancelled'];

  final List<Map<String, dynamic>> _jobs = [
    {
      'id': 'JOB001',
      'wasteType': 'Household Waste',
      'icon': '🏠',
      'customer': 'John Doe',
      'address': '123 Main Street',
      'date': '2024-03-15',
      'time': '10:30 AM',
      'payment': 25.00,
      'status': 'Completed',
      'distance': '2.5 km',
    },
    {
      'id': 'JOB002',
      'wasteType': 'Recyclables',
      'icon': '♻️',
      'customer': 'Jane Smith',
      'address': '456 Oak Avenue',
      'date': '2024-03-15',
      'time': '2:15 PM',
      'payment': 30.00,
      'status': 'Completed',
      'distance': '3.2 km',
    },
    {
      'id': 'JOB003',
      'wasteType': 'Garden Waste',
      'icon': '🌱',
      'customer': 'Bob Johnson',
      'address': '789 Pine Road',
      'date': '2024-03-14',
      'time': '9:00 AM',
      'payment': 20.00,
      'status': 'Completed',
      'distance': '1.8 km',
    },
    {
      'id': 'JOB004',
      'wasteType': 'E-Waste',
      'icon': '📱',
      'customer': 'Alice Brown',
      'address': '321 Elm Street',
      'date': '2024-03-14',
      'time': '4:00 PM',
      'payment': 35.00,
      'status': 'Completed',
      'distance': '4.1 km',
    },
    {
      'id': 'JOB005',
      'wasteType': 'Bulk Items',
      'icon': '📦',
      'customer': 'Charlie Wilson',
      'address': '654 Maple Drive',
      'date': '2024-03-13',
      'time': '11:30 AM',
      'payment': 40.00,
      'status': 'Completed',
      'distance': '5.0 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb && width > 900;
    
    if (isWeb) {
      return buildWebLayout();
    }
    return buildMobileLayout();
  }

  Widget buildWebLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Jobs History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Filter Bar
              _buildWebFilterBar(theme, isDark),
              const SizedBox(height: 20),

              // Summary Cards
              _buildWebSummaryCards(theme, isDark),
              const SizedBox(height: 24),

              // Table
              Expanded(
                child: _buildWebTable(theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebFilterBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          IconData icon;
          switch (filter) {
            case 'Completed':
              icon = Icons.check_circle_outline;
              break;
            case 'In Progress':
              icon = Icons.refresh;
              break;
            case 'Cancelled':
              icon = Icons.cancel_outlined;
              break;
            default:
              icon = Icons.list_alt;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white24 : Colors.black12),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWebSummaryCards(ThemeData theme, bool isDark) {
    final completedJobs = _jobs.where((j) => j['status'] == 'Completed').length;
    final totalEarnings = _jobs
        .where((j) => j['status'] == 'Completed')
        .fold(0.0, (sum, job) => sum + (job['payment'] as double));
    final avgDistance = _jobs.isNotEmpty
        ? _jobs.fold(0.0, (sum, job) {
            final dist = double.parse(job['distance'].toString().replaceAll(' km', ''));
            return sum + dist;
          }) / _jobs.length
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildWebSummaryCard(
            theme,
            isDark,
            Icons.check_circle_outline,
            '$completedJobs',
            'Completed Jobs',
            BrandColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWebSummaryCard(
            theme,
            isDark,
            Icons.attach_money,
            '£${totalEarnings.toStringAsFixed(2)}',
            'Total Earnings',
            BrandColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWebSummaryCard(
            theme,
            isDark,
            Icons.directions_car_outlined,
            '${avgDistance.toStringAsFixed(1)} km',
            'Avg Distance',
            BrandColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildWebSummaryCard(
    ThemeData theme,
    bool isDark,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTable(ThemeData theme, bool isDark) {
    final filteredJobs = _selectedFilter == 'All'
        ? _jobs
        : _jobs.where((j) => j['status'] == _selectedFilter).toList();

    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeader('Type', 0.15),
                _buildTableHeader('Customer', 0.15),
                _buildTableHeader('Address', 0.2),
                _buildTableHeader('Date/Time', 0.15),
                _buildTableHeader('Distance', 0.1),
                _buildTableHeader('Payment', 0.12),
                _buildTableHeader('Status', 0.13),
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                return _buildTableRow(theme, isDark, filteredJobs[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String title, double flex) {
    return Expanded(
      flex: (flex * 100).toInt(),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> job,
    int index,
  ) {
    final isHovered = _hoveredRow == index;
    final statusColor = _getStatusColor(job['status']);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRow = index),
      onExit: (_) => setState(() => _hoveredRow = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isHovered
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02))
              : (index % 2 == 0
                  ? Colors.transparent
                  : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01))),
        ),
        child: InkWell(
          onTap: () {
            // Handle row click
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Waste Type
                Expanded(
                  flex: 15,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(job['icon'], style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['wasteType'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              job['id'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Customer
                Expanded(
                  flex: 15,
                  child: Text(
                    job['customer'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Address
                Expanded(
                  flex: 20,
                  child: Text(
                    job['address'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Date/Time
                Expanded(
                  flex: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['date'],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        job['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),

                // Distance
                Expanded(
                  flex: 10,
                  child: Text(
                    job['distance'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),

                // Payment
                Expanded(
                  flex: 12,
                  child: Text(
                    '£${job['payment'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.primaryGreen,
                    ),
                  ),
                ),

                // Status
                Expanded(
                  flex: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      job['status'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMobileLayout() {
    final theme = Theme.of(context);
    final filteredJobs = _selectedFilter == 'All'
        ? _jobs
        : _jobs.where((j) => j['status'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs History'),
        elevation: 0,
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
        child: ListView(
          children: [
            _buildFilterChips(theme),
            _buildSummaryCards(theme),
            _buildJobsTable(theme, filteredJobs),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final completedJobs = _jobs.where((j) => j['status'] == 'Completed').length;
    final inProgressJobs = _jobs.where((j) => j['status'] == 'In Progress').length;
    final cancelledJobs = _jobs.where((j) => j['status'] == 'Cancelled').length;
    final totalEarnings = _jobs
        .where((j) => j['status'] == 'Completed')
        .fold(0.0, (sum, job) => sum + (job['payment'] as double));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  theme,
                  Icons.check_circle,
                  '$completedJobs',
                  'Completed',
                  BrandColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  theme,
                  Icons.refresh,
                  '$inProgressJobs',
                  'In Progress',
                  const Color(0xFF87C48D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  theme,
                  Icons.cancel_outlined,
                  '$cancelledJobs',
                  'Cancelled',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  theme,
                  Icons.attach_money,
                  '£${totalEarnings.toStringAsFixed(0)}',
                  'Total Earned',
                  BrandColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsTable(ThemeData theme, List<Map<String, dynamic>> filteredJobs) {
    if (filteredJobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text('Type', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Customer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Payment', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            ...filteredJobs.asMap().entries.map((entry) {
              return _buildMobileTableRow(theme, entry.value, entry.key);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTableRow(ThemeData theme, Map<String, dynamic> job, int index) {
    final statusColor = _getStatusColor(job['status']);
    
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.transparent : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(job['icon'], style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job['wasteType'],
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job['id'],
                          style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                job['customer'],
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '£${job['payment'].toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.primaryGreen,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(ThemeData theme, Map<String, dynamic> job) {
    final statusColor = _getStatusColor(job['status']);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    job['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['wasteType'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${job['id']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.2)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'Customer: ${job['customer']}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, job['address']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.directions_car, 'Distance: ${job['distance']}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(Icons.calendar_today, '${job['date']} ${job['time']}'),
              Text(
                '£${job['payment'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return BrandColors.primaryGreen;
      case 'In Progress':
        return const Color(0xFF87C48D);
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
