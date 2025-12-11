import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  bool _isLoading = false;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Offline', 'Pending Approval'];
  String _searchQuery = '';
  String _sortBy = 'Name';
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': 'DR001',
      'name': 'Mike Johnson',
      'phone': '+1 234 567 8900',
      'vehicle': 'WM-1234',
      'license': 'DL123456789',
      'rating': 4.8,
      'totalJobs': 156,
      'status': 'Active',
      'isOnline': true,
      'joinDate': '2023-01-15',
      'earnings': 2450.00,
    },
    {
      'id': 'DR002',
      'name': 'Sarah Davis',
      'phone': '+1 234 567 8901',
      'vehicle': 'WM-1235',
      'license': 'DL123456790',
      'rating': 4.9,
      'totalJobs': 203,
      'status': 'Active',
      'isOnline': false,
      'joinDate': '2022-11-20',
      'earnings': 3200.00,
    },
    {
      'id': 'DR003',
      'name': 'Tom Anderson',
      'phone': '+1 234 567 8902',
      'vehicle': 'WM-1236',
      'license': 'DL123456791',
      'rating': 4.7,
      'totalJobs': 89,
      'status': 'Offline',
      'isOnline': false,
      'joinDate': '2023-03-10',
      'earnings': 1800.00,
    },
    {
      'id': 'DR004',
      'name': 'Lisa Wilson',
      'phone': '+1 234 567 8903',
      'vehicle': 'WM-1237',
      'license': 'DL123456792',
      'rating': 0.0,
      'totalJobs': 0,
      'status': 'Pending Approval',
      'isOnline': false,
      'joinDate': '2024-03-15',
      'earnings': 0.0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            child: Column(
              children: [
                if (isWeb) _buildWebHeader(theme) else _buildMobileHeader(theme),
                if (isWeb) _buildStatsCards(theme),
                if (isWeb) _buildWebControls(theme),
                if (!isWeb) _buildStatsRow(theme),
                if (!isWeb) _buildFilterChips(theme),
                Expanded(
                  child: _isLoading
                      ? const ShimmerList()
                      : isWeb
                          ? (_isGridView ? _buildGridView(theme) : _buildTableView(theme))
                          : _buildDriversList(theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Management',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and monitor driver performance',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5132).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _isGridView = false),
                      icon: const Icon(Icons.view_list),
                      color: !_isGridView ? const Color(0xFF0F5132) : null,
                      tooltip: 'Table View',
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = true),
                      icon: const Icon(Icons.grid_view),
                      color: _isGridView ? const Color(0xFF0F5132) : null,
                      tooltip: 'Grid View',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Management',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage and monitor driver performance',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final totalCount = _drivers.length;
    final activeCount = _drivers.where((d) => d['status'] == 'Active').length;
    final onlineCount = _drivers.where((d) => d['isOnline']).length;
    final pendingCount = _drivers.where((d) => d['status'] == 'Pending Approval').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard2(theme, 'Total Drivers', totalCount.toString(), Icons.local_shipping, const Color(0xFF0F5132)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Active', activeCount.toString(), Icons.check_circle, const Color(0xFF2D7A4F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Online Now', onlineCount.toString(), Icons.circle, const Color(0xFF5A9F6E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Pending', pendingCount.toString(), Icons.pending, const Color(0xFF87C48D)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard2(ThemeData theme, String label, String count, IconData icon, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: CustomCard(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by name, ID, phone, vehicle, or license...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            DropdownButton<String>(
              value: _selectedFilter,
              underline: const SizedBox(),
              items: _filters.map((filter) {
                return DropdownMenuItem(value: filter, child: Text(filter));
              }).toList(),
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              items: ['Name', 'Rating', 'Earnings', 'Join Date'].map((sort) {
                return DropdownMenuItem(value: sort, child: Text(sort));
              }).toList(),
              onChanged: (value) => setState(() => _sortBy = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              'Total Drivers',
              '${_drivers.length}',
              Icons.local_shipping,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Online Now',
              '${_drivers.where((d) => d['isOnline']).length}',
              Icons.circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Pending',
              '${_drivers.where((d) => d['status'] == 'Pending Approval').length}',
              Icons.pending,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
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

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                selectedColor: const Color(0xFF0F5132).withOpacity(0.2),
                checkmarkColor: const Color(0xFF0F5132),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0F5132)
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

  Widget _buildDriversList(ThemeData theme) {
    final filteredDrivers = _getFilteredDrivers();

    if (filteredDrivers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No drivers found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filteredDrivers.length,
      itemBuilder: (context, index) {
        final driver = filteredDrivers[index];
        return _buildDriverItem(theme, driver);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredDrivers() {
    var filtered = _drivers.where((d) {
      final matchesFilter = _selectedFilter == 'All' || d['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          d['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d['phone'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d['vehicle'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d['license'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    if (_sortBy == 'Rating') {
      filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (_sortBy == 'Earnings') {
      filtered.sort((a, b) => b['earnings'].compareTo(a['earnings']));
    } else if (_sortBy == 'Join Date') {
      filtered.sort((a, b) => b['joinDate'].compareTo(a['joinDate']));
    } else {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    }

    return filtered;
  }

  Widget _buildTableView(ThemeData theme) {
    final filteredDrivers = _getFilteredDrivers();

    if (filteredDrivers.isEmpty) {
      return _buildEmptyState(theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: CustomCard(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              theme.colorScheme.primary.withOpacity(0.05),
            ),
            columnSpacing: 40,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 80,
            columns: const [
              DataColumn(label: Text('Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Vehicle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('License', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Joined', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
            rows: filteredDrivers.map((driver) {
              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
                          ),
                          if (driver['isOnline'])
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(driver['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(driver['id'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ],
                  )),
                  DataCell(Text(driver['phone'], style: const TextStyle(fontSize: 13))),
                  DataCell(Text(driver['vehicle'], style: const TextStyle(fontSize: 13))),
                  DataCell(Text(driver['license'], style: const TextStyle(fontSize: 13))),
                  DataCell(_buildStatusBadge(driver['status'], theme)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${driver['rating']}', style: const TextStyle(fontSize: 13)),
                    ],
                  )),
                  DataCell(Text('${driver['totalJobs']}', style: const TextStyle(fontSize: 13))),
                  DataCell(Text('\$${driver['earnings'].toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  DataCell(Text(driver['joinDate'], style: const TextStyle(fontSize: 12))),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (driver['status'] == 'Pending Approval') ...[
                        IconButton(
                          icon: const Icon(Icons.check, size: 18, color: Colors.green),
                          onPressed: () => _approveDriver(driver),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                          onPressed: () => _rejectDriver(driver),
                          tooltip: 'Reject',
                        ),
                      ] else ...[
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)),
                          onPressed: () => _viewDriverDetails(driver),
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.map, size: 18, color: Color(0xFF0F5132)),
                          onPressed: () => _assignArea(driver),
                          tooltip: 'Assign Area',
                        ),
                      ],
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(ThemeData theme) {
    final filteredDrivers = _getFilteredDrivers();
    final width = MediaQuery.of(context).size.width;

    if (filteredDrivers.isEmpty) {
      return _buildEmptyState(theme);
    }

    int crossAxisCount = 3;
    if (width > 1200) crossAxisCount = 4;
    if (width < 1000) crossAxisCount = 2;

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredDrivers.length,
      itemBuilder: (context, index) {
        return _buildDriverGridCard(theme, filteredDrivers[index]);
      },
    );
  }

  Widget _buildDriverGridCard(ThemeData theme, Map<String, dynamic> driver) {
    final statusColor = _getStatusColor(driver['status']);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: theme.colorScheme.primary, size: 24),
                  ),
                  if (driver['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              _buildStatusBadge(driver['status'], theme),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            driver['name'],
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            driver['id'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  driver['phone'],
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.local_shipping, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${driver['vehicle']} • ${driver['license']}',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (driver['rating'] > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${driver['rating']} (${driver['totalJobs']} jobs)',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Joined: ${driver['joinDate']}',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Earnings: \$${driver['earnings'].toStringAsFixed(0)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const Spacer(),
          if (driver['status'] == 'Pending Approval') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveDriver(driver),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Approve', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectDriver(driver),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Reject', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewDriverDetails(driver),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _assignArea(driver),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Assign', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No drivers found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverItem(ThemeData theme, Map<String, dynamic> driver) {
    final statusColor = _getStatusColor(driver['status']);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  if (driver['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            driver['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              driver['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'ID: ${driver['id']} • ${driver['phone']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (driver['rating'] > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${driver['rating']} (${driver['totalJobs']} jobs)',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Vehicle Info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vehicle: ${driver['vehicle']} • License: ${driver['license']}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildDriverStat(theme, 'Earnings', '\$${driver['earnings'].toStringAsFixed(0)}')),
              Expanded(child: _buildDriverStat(theme, 'Jobs', '${driver['totalJobs']}')),
              Expanded(child: _buildDriverStat(theme, 'Joined', driver['joinDate'])),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              if (driver['status'] == 'Pending Approval') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDriver(driver),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Approve', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectDriver(driver),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Reject', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDriverDetails(driver),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _assignArea(driver),
                    icon: const Icon(Icons.map_outlined, size: 14),
                    label: const Text('Assign', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF0F5132);
      case 'Offline':
        return const Color(0xFF87C48D);
      case 'Pending Approval':
        return const Color(0xFF5A9F6E);
      default:
        return const Color(0xFF1F1F1F);
    }
  }

  void _approveDriver(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approve Driver'),
        content: Text('Are you sure you want to approve ${driver['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                driver['status'] = 'Active';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${driver['name']} approved successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132), foregroundColor: Colors.white),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectDriver(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Driver'),
        content: Text('Are you sure you want to reject ${driver['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _drivers.remove(driver);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${driver['name']} rejected')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewDriverDetails(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Driver Details - ${driver['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Driver ID', driver['id']),
              _buildDetailRow('Name', driver['name']),
              _buildDetailRow('Phone', driver['phone']),
              _buildDetailRow('Vehicle', driver['vehicle']),
              _buildDetailRow('License', driver['license']),
              _buildDetailRow('Status', driver['status']),
              _buildDetailRow('Rating', '${driver['rating']}'),
              _buildDetailRow('Total Jobs', '${driver['totalJobs']}'),
              _buildDetailRow('Total Earnings', '\$${driver['earnings'].toStringAsFixed(2)}'),
              _buildDetailRow('Join Date', driver['joinDate']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _assignArea(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Area to ${driver['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select area for driver assignment:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Area',
                border: OutlineInputBorder(),
              ),
              items: ['Downtown', 'Suburbs', 'Industrial Area', 'Residential Zone'].map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${driver['name']} assigned to $value')),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Drivers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filters.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
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