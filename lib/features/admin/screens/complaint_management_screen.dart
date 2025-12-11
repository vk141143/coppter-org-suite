import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() => _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  bool _isLoading = false;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Assigned', 'In-Progress', 'Completed'];
  String _searchQuery = '';
  String _sortBy = 'Date (Newest)';
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'WM001234',
      'customer': 'John Doe',
      'category': 'Household Waste',
      'icon': '🏠',
      'status': 'Pending',
      'priority': 'High',
      'date': '2024-03-15',
      'time': '10:30 AM',
      'address': '123 Main Street',
      'driver': null,
    },
    {
      'id': 'WM001235',
      'customer': 'Jane Smith',
      'category': 'Recyclables',
      'icon': '♻️',
      'status': 'Assigned',
      'priority': 'Medium',
      'date': '2024-03-15',
      'time': '2:15 PM',
      'address': '456 Oak Avenue',
      'driver': 'Mike Johnson',
    },
    {
      'id': 'WM001236',
      'customer': 'Bob Wilson',
      'category': 'Garden Waste',
      'icon': '🌱',
      'status': 'In-Progress',
      'priority': 'Low',
      'date': '2024-03-15',
      'time': '9:00 AM',
      'address': '789 Pine Road',
      'driver': 'Sarah Davis',
    },
    {
      'id': 'WM001237',
      'customer': 'Alice Brown',
      'category': 'E-Waste',
      'icon': '📱',
      'status': 'Completed',
      'priority': 'Medium',
      'date': '2024-03-14',
      'time': '11:45 AM',
      'address': '321 Elm Street',
      'driver': 'Tom Anderson',
    },
  ];

  final List<String> _availableDrivers = [
    'Mike Johnson',
    'Sarah Davis',
    'Tom Anderson',
    'Lisa Wilson',
    'David Brown',
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
                if (!isWeb) _buildFilterChips(theme),
                Expanded(
                  child: _isLoading
                      ? const ShimmerList()
                      : isWeb
                          ? (_isGridView ? _buildGridView(theme) : _buildTableView(theme))
                          : _buildComplaintsList(theme),
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
                'Complaint Management',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage and track user complaints',
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
                      tooltip: 'List View',
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
            'Complaint Management',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage and track user complaints',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final totalCount = _complaints.length;
    final pendingCount = _complaints.where((c) => c['status'] == 'Pending').length;
    final assignedCount = _complaints.where((c) => c['status'] == 'Assigned').length;
    final inProgressCount = _complaints.where((c) => c['status'] == 'In-Progress').length;
    final completedCount = _complaints.where((c) => c['status'] == 'Completed').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(theme, 'Total', totalCount.toString(), Icons.list_alt, const Color(0xFF0F5132)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(theme, 'Pending', pendingCount.toString(), Icons.pending, const Color(0xFF2D7A4F)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(theme, 'Assigned', assignedCount.toString(), Icons.assignment_ind, const Color(0xFF5A9F6E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(theme, 'In Progress', inProgressCount.toString(), Icons.autorenew, const Color(0xFF87C48D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(theme, 'Completed', completedCount.toString(), Icons.check_circle, const Color(0xFF0F5132)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String count, IconData icon, Color color) {
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
                  hintText: 'Search by ID, customer, category, or address...',
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
              items: ['Date (Newest)', 'Date (Oldest)', 'Priority (High)', 'Status'].map((sort) {
                return DropdownMenuItem(value: sort, child: Text(sort));
              }).toList(),
              onChanged: (value) => setState(() => _sortBy = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

  List<Map<String, dynamic>> _getFilteredComplaints() {
    var filtered = _complaints.where((c) {
      final matchesFilter = _selectedFilter == 'All' || c['status'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          c['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c['customer'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c['address'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    if (_sortBy == 'Date (Oldest)') {
      filtered = filtered.reversed.toList();
    } else if (_sortBy == 'Priority (High)') {
      filtered.sort((a, b) {
        final priorities = {'High': 0, 'Medium': 1, 'Low': 2};
        return priorities[a['priority']]!.compareTo(priorities[b['priority']]!);
      });
    } else if (_sortBy == 'Status') {
      filtered.sort((a, b) => a['status'].compareTo(b['status']));
    }

    return filtered;
  }

  Widget _buildTableView(ThemeData theme) {
    final filteredComplaints = _getFilteredComplaints();

    if (filteredComplaints.isEmpty) {
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
              DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Date/Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
            rows: filteredComplaints.map((complaint) {
              return DataRow(
                cells: [
                  DataCell(Text(complaint['id'], style: const TextStyle(fontSize: 13))),
                  DataCell(Text(complaint['customer'], style: const TextStyle(fontSize: 13))),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(complaint['icon'], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(complaint['category'], style: const TextStyle(fontSize: 13)),
                    ],
                  )),
                  DataCell(_buildStatusPill(complaint['status'], theme)),
                  DataCell(_buildPriorityPill(complaint['priority'], theme)),
                  DataCell(Text(complaint['driver'] ?? 'Unassigned', style: const TextStyle(fontSize: 13))),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(complaint['date'], style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(complaint['time'], style: const TextStyle(fontSize: 11)),
                    ],
                  )),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (complaint['status'] == 'Pending')
                        IconButton(
                          icon: const Icon(Icons.person_add, size: 18, color: Color(0xFF0F5132)),
                          onPressed: () => _assignDriver(complaint),
                          tooltip: 'Assign',
                        ),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)),
                        onPressed: () => _viewDetails(complaint),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0F5132)),
                        onPressed: () => _changeStatus(complaint),
                        tooltip: 'Update',
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
    final filteredComplaints = _getFilteredComplaints();

    if (filteredComplaints.isEmpty) {
      return _buildEmptyState(theme);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) {
        return _buildGridCard(theme, filteredComplaints[index]);
      },
    );
  }

  Widget _buildGridCard(ThemeData theme, Map<String, dynamic> complaint) {
    final statusColor = _getStatusColor(complaint['status']);
    final priorityColor = _getPriorityColor(complaint['priority']);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(complaint['icon'], style: const TextStyle(fontSize: 20)),
              ),
              _buildPriorityPill(complaint['priority'], theme),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            complaint['id'],
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            complaint['customer'],
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            complaint['category'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${complaint['date']}',
                  style: const TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.location_on, size: 10, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  complaint['address'],
                  style: const TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusPill(complaint['status'], theme),
              Flexible(
                child: Text(
                  complaint['driver'] ?? 'N/A',
                  style: const TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (complaint['status'] == 'Pending') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _assignDriver(complaint),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Assign', style: TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewDetails(complaint),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 10)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _changeStatus(complaint),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text('Edit', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, ThemeData theme) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityPill(String priority, ThemeData theme) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 10,
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
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No complaints found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(ThemeData theme) {
    final filteredComplaints = _getFilteredComplaints();

    if (filteredComplaints.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) {
        final complaint = filteredComplaints[index];
        return _buildComplaintItem(theme, complaint);
      },
    );
  }

  Widget _buildComplaintItem(ThemeData theme, Map<String, dynamic> complaint) {
    final statusColor = _getStatusColor(complaint['status']);
    final priorityColor = _getPriorityColor(complaint['priority']);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    complaint['icon'],
                    style: const TextStyle(fontSize: 20),
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
                            complaint['id'],
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            complaint['priority'],
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${complaint['category']} - ${complaint['customer']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      '${complaint['date']} at ${complaint['time']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  complaint['address'],
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Status and Driver Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  complaint['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              
              if (complaint['driver'] != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Driver: ${complaint['driver']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              if (complaint['status'] == 'Pending') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _assignDriver(complaint),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Assign', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewDetails(complaint),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('View', style: TextStyle(fontSize: 11)),
                ),
              ),
              
              const SizedBox(width: 6),
              
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _changeStatus(complaint),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Update', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFF5A9F6E);
      case 'Assigned':
        return const Color(0xFF2D7A4F);
      case 'In-Progress':
        return const Color(0xFF87C48D);
      case 'Completed':
        return const Color(0xFF0F5132);
      default:
        return const Color(0xFF1F1F1F);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFF0F5132);
      case 'Medium':
        return const Color(0xFF2D7A4F);
      case 'Low':
        return const Color(0xFF5A9F6E);
      default:
        return const Color(0xFF1F1F1F);
    }
  }

  void _assignDriver(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Driver to ${complaint['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a driver for this complaint:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Available Drivers',
                border: OutlineInputBorder(),
              ),
              items: _availableDrivers.map((driver) {
                return DropdownMenuItem(
                  value: driver,
                  child: Text(driver),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    complaint['driver'] = value;
                    complaint['status'] = 'Assigned';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Driver $value assigned successfully')),
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

  void _viewDetails(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complaint Details - ${complaint['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Customer', complaint['customer']),
              _buildDetailRow('Category', complaint['category']),
              _buildDetailRow('Status', complaint['status']),
              _buildDetailRow('Priority', complaint['priority']),
              _buildDetailRow('Date', complaint['date']),
              _buildDetailRow('Time', complaint['time']),
              _buildDetailRow('Address', complaint['address']),
              if (complaint['driver'] != null)
                _buildDetailRow('Assigned Driver', complaint['driver']),
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
            width: 80,
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

  void _changeStatus(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status - ${complaint['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select new status:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: complaint['status'],
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Pending', 'Assigned', 'In-Progress', 'Completed'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    complaint['status'] = value;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status updated to $value')),
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
        title: const Text('Filter by Status'),
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