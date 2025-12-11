import 'package:flutter/material.dart';
import '../widgets/web_hero_bar.dart';
import '../widgets/web_summary_pills.dart';
import '../widgets/web_timeline_map_split.dart';
import '../widgets/web_complaint_card_grid.dart';
import '../widgets/web_inspector_drawer.dart';
import '../widgets/web_filter_panel.dart';

class ComplaintHistoryWeb extends StatefulWidget {
  const ComplaintHistoryWeb({super.key});

  @override
  State<ComplaintHistoryWeb> createState() => _ComplaintHistoryWebState();
}

class _ComplaintHistoryWebState extends State<ComplaintHistoryWeb> {
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  Map<String, dynamic>? _selectedComplaint;
  bool _isFilterPanelOpen = false;

  final List<Map<String, dynamic>> _allComplaints = [
    {
      'id': 'CMP-001',
      'category': 'Plastic Waste',
      'icon': '♻️',
      'description': 'Large amount of plastic bottles near park entrance',
      'location': '123 Park Avenue, Downtown',
      'date': 'Jan 15, 2024',
      'status': 'Completed',
      'driver': 'John Doe',
    },
    {
      'id': 'CMP-002',
      'category': 'E-Waste',
      'icon': '🔌',
      'description': 'Old computer monitors and electronic equipment',
      'location': '456 Tech Street, Silicon Valley',
      'date': 'Jan 16, 2024',
      'status': 'In-Progress',
      'driver': 'Jane Smith',
    },
    {
      'id': 'CMP-003',
      'category': 'Organic Waste',
      'icon': '🍃',
      'description': 'Garden waste and food scraps',
      'location': '789 Green Road, Suburb',
      'date': 'Jan 17, 2024',
      'status': 'Pending',
      'driver': null,
    },
    {
      'id': 'CMP-004',
      'category': 'Metal Waste',
      'icon': '🔩',
      'description': 'Scrap metal and old appliances',
      'location': '321 Industrial Ave',
      'date': 'Jan 18, 2024',
      'status': 'Completed',
      'driver': 'Mike Johnson',
    },
    {
      'id': 'CMP-005',
      'category': 'Glass Waste',
      'icon': '🍾',
      'description': 'Broken glass bottles and containers',
      'location': '654 Main Street',
      'date': 'Jan 19, 2024',
      'status': 'In-Progress',
      'driver': 'Sarah Williams',
    },
    {
      'id': 'CMP-006',
      'category': 'Paper Waste',
      'icon': '📄',
      'description': 'Cardboard boxes and newspapers',
      'location': '987 Office Plaza',
      'date': 'Jan 20, 2024',
      'status': 'Pending',
      'driver': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredComplaints {
    return _allComplaints.where((complaint) {
      final matchesStatus =
          _selectedStatus == 'All' || complaint['status'] == _selectedStatus;
      final matchesCategory = _selectedCategory == 'All' ||
          complaint['category'] == _selectedCategory;
      return matchesStatus && matchesCategory;
    }).toList();
  }

  int get _totalComplaints => _allComplaints.length;
  int get _pendingCount =>
      _allComplaints.where((c) => c['status'] == 'Pending').length;
  int get _inProgressCount =>
      _allComplaints.where((c) => c['status'] == 'In-Progress').length;
  int get _completedCount =>
      _allComplaints.where((c) => c['status'] == 'Completed').length;

  void _handleComplaintTap(Map<String, dynamic> complaint) {
    setState(() {
      _selectedComplaint = complaint;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredComplaints = _filteredComplaints;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : Colors.white,
      body: Row(
        children: [
          // Main Workspace
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Bar
                  WebHeroBar(
                    onSearch: () {},
                    onFilter: () {
                      setState(() => _isFilterPanelOpen = !_isFilterPanelOpen);
                    },
                    onExport: () {},
                    onRefresh: () => setState(() {}),
                    onBack: () => Navigator.of(context).pop(),
                  ),

                  // Content with padding
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Pills
                        WebSummaryPills(
                          total: _totalComplaints,
                          pending: _pendingCount,
                          inProgress: _inProgressCount,
                          completed: _completedCount,
                        ),

                        const SizedBox(height: 32),

                        // Recent Activities Section
                        Text(
                          'Recent Activities',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Timeline + Map Split
                        const WebTimelineMapSplit(),

                        const SizedBox(height: 32),

                        // All Requests Section with Search/Filter
                        Row(
                          children: [
                            Text(
                              'All Requests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F5132).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredComplaints.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F5132),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Search Bar
                            Container(
                              width: 250,
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search requests...',
                                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(fontSize: 13),
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Filter Button
                            ElevatedButton.icon(
                              onPressed: () => setState(() => _isFilterPanelOpen = !_isFilterPanelOpen),
                              icon: const Icon(Icons.filter_list, size: 16),
                              label: const Text('Filter', style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5132),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Complaint Cards Grid or Empty State
                        filteredComplaints.isEmpty
                            ? _buildEmptyState(context)
                            : WebComplaintCardGrid(
                                complaints: filteredComplaints,
                                onCardTap: _handleComplaintTap,
                                isSidebarOpen: _selectedComplaint != null,
                              ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Inspector Drawer
          if (_selectedComplaint != null)
            WebInspectorDrawer(
              complaint: _selectedComplaint!,
              onClose: () => setState(() => _selectedComplaint = null),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF52B788).withOpacity(0.2),
                    const Color(0xFF40916C).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 64,
                color: Color(0xFF0F5132),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Requests Found',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5132),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
