import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'USR001',
      'name': 'John Doe',
      'email': 'john.doe@email.com',
      'phone': '+1 234 567 8900',
      'address': '123 Main Street, City',
      'joinDate': '2023-01-15',
      'totalComplaints': 12,
      'activeComplaints': 2,
      'status': 'Active',
      'lastActivity': '2024-03-15',
    },
    {
      'id': 'USR002',
      'name': 'Jane Smith',
      'email': 'jane.smith@email.com',
      'phone': '+1 234 567 8901',
      'address': '456 Oak Avenue, City',
      'joinDate': '2023-02-20',
      'totalComplaints': 8,
      'activeComplaints': 1,
      'status': 'Active',
      'lastActivity': '2024-03-14',
    },
    {
      'id': 'USR003',
      'name': 'Bob Wilson',
      'email': 'bob.wilson@email.com',
      'phone': '+1 234 567 8902',
      'address': '789 Pine Road, City',
      'joinDate': '2023-03-10',
      'totalComplaints': 15,
      'activeComplaints': 0,
      'status': 'Active',
      'lastActivity': '2024-03-13',
    },
    {
      'id': 'USR004',
      'name': 'Alice Brown',
      'email': 'alice.brown@email.com',
      'phone': '+1 234 567 8903',
      'address': '321 Elm Street, City',
      'joinDate': '2023-04-05',
      'totalComplaints': 6,
      'activeComplaints': 3,
      'status': 'Suspended',
      'lastActivity': '2024-03-10',
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
                if (!isWeb) _buildSearchBar(theme),
                Expanded(
                  child: _isLoading
                      ? const ShimmerList()
                      : isWeb
                          ? (_isGridView ? _buildGridView(theme) : _buildTableView(theme))
                          : _buildUsersList(theme),
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
                'User Management',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage users and monitor activity',
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
      child: Text(
        'User Management',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final totalCount = _users.length;
    final activeCount = _users.where((u) => u['status'] == 'Active').length;
    final suspendedCount = _users.where((u) => u['status'] == 'Suspended').length;
    final totalComplaints = _users.fold(0, (sum, user) => sum + (user['totalComplaints'] as int));

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard2(theme, 'Total Users', totalCount.toString(), Icons.people, const Color(0xFF0F5132)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Active', activeCount.toString(), Icons.check_circle, const Color(0xFF2D7A4F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Suspended', suspendedCount.toString(), Icons.block, const Color(0xFF5A9F6E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard2(theme, 'Total Complaints', totalComplaints.toString(), Icons.report_problem, const Color(0xFF87C48D)),
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
                  hintText: 'Search by name, email, phone, or ID...',
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
              items: ['All', 'Active', 'Suspended'].map((filter) {
                return DropdownMenuItem(value: filter, child: Text(filter));
              }).toList(),
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              items: ['Name', 'Join Date', 'Last Activity', 'Total Complaints'].map((sort) {
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
              'Total Users',
              '${_users.length}',
              Icons.people,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Active Users',
              '${_users.where((u) => u['status'] == 'Active').length}',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Total Complaints',
              '${_users.fold(0, (sum, user) => sum + (user['totalComplaints'] as int))}',
              Icons.report_problem,
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    var filtered = _users.where((u) {
      final matchesFilter = _selectedFilter == 'All' || u['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          u['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['phone'].contains(_searchQuery) ||
          u['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    if (_sortBy == 'Join Date') {
      filtered.sort((a, b) => b['joinDate'].compareTo(a['joinDate']));
    } else if (_sortBy == 'Last Activity') {
      filtered.sort((a, b) => b['lastActivity'].compareTo(a['lastActivity']));
    } else if (_sortBy == 'Total Complaints') {
      filtered.sort((a, b) => b['totalComplaints'].compareTo(a['totalComplaints']));
    } else {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    }

    return filtered;
  }

  Widget _buildTableView(ThemeData theme) {
    final filteredUsers = _getFilteredUsers();

    if (filteredUsers.isEmpty) {
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
              DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Joined', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Last Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
            rows: filteredUsers.map((user) {
              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(user['id'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ],
                  )),
                  DataCell(Text(user['email'], style: const TextStyle(fontSize: 13))),
                  DataCell(Text(user['phone'], style: const TextStyle(fontSize: 13))),
                  DataCell(SizedBox(width: 150, child: Text(user['address'], style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis))),
                  DataCell(Text('${user['totalComplaints']}', style: const TextStyle(fontSize: 13))),
                  DataCell(Text('${user['activeComplaints']}', style: const TextStyle(fontSize: 13))),
                  DataCell(Text(user['joinDate'], style: const TextStyle(fontSize: 12))),
                  DataCell(Text(user['lastActivity'], style: const TextStyle(fontSize: 12))),
                  DataCell(_buildStatusBadge(user['status'], theme)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18),
                        onPressed: () => _viewUserDetails(user),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.history, size: 18),
                        onPressed: () => _viewComplaintHistory(user),
                        tooltip: 'History',
                      ),
                      IconButton(
                        icon: Icon(
                          user['status'] == 'Active' ? Icons.block : Icons.check_circle,
                          size: 18,
                          color: user['status'] == 'Active' ? Colors.red : Colors.green,
                        ),
                        onPressed: () => _toggleUserStatus(user),
                        tooltip: user['status'] == 'Active' ? 'Suspend' : 'Activate',
                      ),
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
    final filteredUsers = _getFilteredUsers();
    final width = MediaQuery.of(context).size.width;

    if (filteredUsers.isEmpty) {
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
        childAspectRatio: 0.75,
      ),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserGridCard(theme, filteredUsers[index]);
      },
    );
  }

  Widget _buildUserGridCard(ThemeData theme, Map<String, dynamic> user) {
    final statusColor = user['status'] == 'Active' ? Colors.green : Colors.red;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _buildStatusBadge(user['status'], theme),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user['name'],
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            user['id'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  user['email'],
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
              Icon(Icons.phone, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  user['phone'],
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
              Icon(Icons.location_on, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  user['address'],
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Complaints:', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    Text('${user['totalComplaints']} (${user['activeComplaints']} active)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Joined:', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    Text(user['joinDate'], style: const TextStyle(fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Last Activity:', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    Text(user['lastActivity'], style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewUserDetails(user),
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
                  onPressed: () => _viewComplaintHistory(user),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('History', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _toggleUserStatus(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: user['status'] == 'Active' ? Colors.red : Colors.green,
                side: BorderSide(color: user['status'] == 'Active' ? Colors.red : Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 0),
              ),
              child: Text(user['status'] == 'Active' ? 'Suspend' : 'Activate', style: const TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final color = status == 'Active' ? const Color(0xFF0F5132) : const Color(0xFF87C48D);
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
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search users by name, email, or phone...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildUsersList(ThemeData theme) {
    final filteredUsers = _users.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user['name'].toLowerCase().contains(_searchQuery) ||
             user['email'].toLowerCase().contains(_searchQuery) ||
             user['phone'].contains(_searchQuery);
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No users found' : 'No users match your search',
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
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserItem(theme, user);
      },
    );
  }

  Widget _buildUserItem(ThemeData theme, Map<String, dynamic> user) {
    final statusColor = user['status'] == 'Active' ? Colors.green : Colors.red;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
                            user['name'],
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
                              user['status'],
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'ID: ${user['id']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Contact Info
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['email'],
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['phone'],
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 6),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user['address'],
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Stats Row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildUserStat(theme, 'Total\nComplaints', '${user['totalComplaints']}')),
                Expanded(child: _buildUserStat(theme, 'Active\nComplaints', '${user['activeComplaints']}')),
                Expanded(child: _buildUserStat(theme, 'Member\nSince', user['joinDate'])),
                Expanded(child: _buildUserStat(theme, 'Last\nActivity', user['lastActivity'])),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewUserDetails(user),
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
                  onPressed: () => _viewComplaintHistory(user),
                  icon: const Icon(Icons.history_outlined, size: 14),
                  label: const Text('History', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  ),
                ),
              ),
              
              const SizedBox(width: 6),
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(
                    user['status'] == 'Active' ? Icons.block : Icons.check_circle,
                    size: 14,
                  ),
                  label: Text(
                    user['status'] == 'Active' ? 'Block' : 'Active',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: user['status'] == 'Active' ? Colors.red : Colors.green,
                    side: BorderSide(
                      color: user['status'] == 'Active' ? Colors.red : Colors.green,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStat(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details - ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User ID', user['id']),
              _buildDetailRow('Name', user['name']),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Phone', user['phone']),
              _buildDetailRow('Address', user['address']),
              _buildDetailRow('Status', user['status']),
              _buildDetailRow('Join Date', user['joinDate']),
              _buildDetailRow('Last Activity', user['lastActivity']),
              _buildDetailRow('Total Complaints', '${user['totalComplaints']}'),
              _buildDetailRow('Active Complaints', '${user['activeComplaints']}'),
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
            width: 120,
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

  void _viewComplaintHistory(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['name']} - Complaint History'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Complaints: ${user['totalComplaints']}'),
              Text('Active Complaints: ${user['activeComplaints']}'),
              const SizedBox(height: 16),
              const Text('Recent complaints will be displayed here...'),
              // In a real app, you would fetch and display actual complaint data
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

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'Active' ? 'Suspended' : 'Active';
    final action = newStatus == 'Active' ? 'activate' : 'suspend';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} User'),
        content: Text('Are you sure you want to $action ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                user['status'] = newStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user['name']} ${action}d successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5132),
              foregroundColor: Colors.white,
            ),
            child: Text(action.capitalize()),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}