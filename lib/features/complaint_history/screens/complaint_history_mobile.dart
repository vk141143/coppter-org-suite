import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../user/screens/track_complaint_screen.dart';
import '../../user/screens/complaint_details_screen.dart';
import '../../../core/services/issue_service.dart';

class ComplaintHistoryMobile extends StatefulWidget {
  const ComplaintHistoryMobile({super.key});

  @override
  State<ComplaintHistoryMobile> createState() => _ComplaintHistoryMobileState();
}

class _ComplaintHistoryMobileState extends State<ComplaintHistoryMobile> {
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'In-Progress', 'Completed'];
  final IssueService _issueService = IssueService();
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    try {
      final issues = await _issueService.getIssues();
      if (mounted) {
        setState(() {
          _complaints = issues.map((issue) => {
            'id': issue['id'],
            'category': issue['category_name'] ?? 'Unknown',
            'icon': _getCategoryIcon(issue['category_id']),
            'status': issue['status'] ?? 'Pending',
            'date': issue['created_at']?.toString().split('T')[0] ?? '',
            'time': issue['created_at']?.toString().split('T')[1].substring(0, 5) ?? '',
            'description': issue['description'] ?? '',
            'location': issue['pickup_location'] ?? '',
            'payment_amount': issue['payment_amount'] ?? '0',
            'assigned_driver_name': issue['assigned_driver_name'],
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String _getCategoryIcon(int? categoryId) {
    if (categoryId == null || categoryId >= AppConstants.wasteCategories.length) return '🗑️';
    return AppConstants.wasteCategories[categoryId]['icon'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Issue History'), elevation: 0, backgroundColor: Colors.transparent, actions: [IconButton(onPressed: _showFilterDialog, icon: const Icon(Icons.filter_list))]),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [theme.colorScheme.primary.withOpacity(0.05), theme.colorScheme.surface])),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              _buildFilterChips(theme),
              Expanded(child: _isLoading ? const ShimmerList() : _buildComplaintsList(theme)),
            ],
          ),
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
                onSelected: (selected) => setState(() => _selectedFilter = filter),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildComplaintsList(ThemeData theme) {
    final filteredComplaints = _selectedFilter == 'All' ? _complaints : _complaints.where((c) => c['status'] == _selectedFilter).toList();

    if (filteredComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('No complaints found', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)))),
            const SizedBox(height: 8),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('Try adjusting your filters', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredComplaints.length,
      itemBuilder: (context, index) => _buildComplaintItem(theme, filteredComplaints[index]),
    );
  }

  Widget _buildComplaintItem(ThemeData theme, Map<String, dynamic> complaint) {
    final statusColor = _getStatusColor(complaint['status']);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 16),
        leading: SizedBox(width: 50, height: 50, child: Container(decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(complaint['icon'], style: const TextStyle(fontSize: 24))))),
        title: Text(complaint['category'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${complaint['id']}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 4),
            Text('${complaint['date']} at ${complaint['time']}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(complaint['status'], style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600))),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.description_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)), const SizedBox(width: 8), Expanded(child: Text(complaint['description'], style: theme.textTheme.bodyMedium))]),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)), const SizedBox(width: 8), Expanded(child: Text(complaint['location'], style: theme.textTheme.bodyMedium))]),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (complaint['status'] != 'Completed') ...[Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen())), icon: const Icon(Icons.track_changes, size: 16), label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Track')), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8)))), const SizedBox(width: 8)],
                  if (complaint['status'] == 'Pending' || complaint['status'] == 'In-Progress') ...[Expanded(child: OutlinedButton.icon(onPressed: () => _showCancelDialog(complaint['id']), icon: const Icon(Icons.cancel_outlined, size: 16), label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Cancel')), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), foregroundColor: Colors.red))), const SizedBox(width: 8)],
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailsScreen(complaint: complaint))), icon: const Icon(Icons.visibility_outlined, size: 16), label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Details')), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8)))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xFF2D7A4F);
      case 'In-Progress': return const Color(0xFF0F5132);
      case 'Completed': return const Color(0xFF198754);
      default: return Colors.grey;
    }
  }

  void _showCancelDialog(String complaintId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Complaint'),
        content: Text('Are you sure you want to cancel complaint $complaintId?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(onPressed: () {Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint cancelled successfully')));}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Yes, Cancel')),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(mainAxisSize: MainAxisSize.min, children: _filters.map((filter) => RadioListTile<String>(title: Text(filter), value: filter, groupValue: _selectedFilter, onChanged: (value) {setState(() => _selectedFilter = value!); Navigator.of(context).pop();})).toList()),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadIssues();
  }

  @override
  void dispose() {
    _issueService.dispose();
    super.dispose();
  }
}
