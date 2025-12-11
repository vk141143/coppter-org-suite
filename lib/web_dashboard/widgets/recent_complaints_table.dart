import 'package:flutter/material.dart';

class RecentComplaintsTable extends StatefulWidget {
  const RecentComplaintsTable({super.key});

  @override
  State<RecentComplaintsTable> createState() => _RecentComplaintsTableState();
}

class _RecentComplaintsTableState extends State<RecentComplaintsTable> {
  int _currentPage = 0;
  final int _rowsPerPage = 5;

  final List<Map<String, dynamic>> _complaints = [
    {'icon': '🏠', 'category': 'Household Waste', 'time': '2 hours ago', 'driver': 'John Smith', 'status': 'In-Progress'},
    {'icon': '♻️', 'category': 'Recyclables', 'time': '5 hours ago', 'driver': 'Mike Johnson', 'status': 'Completed'},
    {'icon': '🌱', 'category': 'Garden Waste', 'time': '1 day ago', 'driver': 'Sarah Williams', 'status': 'Completed'},
    {'icon': '📱', 'category': 'E-Waste', 'time': '2 days ago', 'driver': 'Unassigned', 'status': 'Pending'},
    {'icon': '🏗️', 'category': 'Construction', 'time': '3 days ago', 'driver': 'David Brown', 'status': 'In-Progress'},
    {'icon': '🏥', 'category': 'Medical Waste', 'time': '4 days ago', 'driver': 'Emily Davis', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, _complaints.length);
    final displayedComplaints = _complaints.sublist(startIndex, endIndex);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Issues',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 60),
                    Expanded(flex: 2, child: Text('Category', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Submitted', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Driver', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
                    const SizedBox(width: 100, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              
              // Table Rows
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedComplaints.length,
                itemBuilder: (context, index) {
                  return _TableRow(complaint: displayedComplaints[index]);
                },
              ),
              
              // Pagination
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${startIndex + 1}-$endIndex of ${_complaints.length}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text('${_currentPage + 1}'),
                        IconButton(
                          onPressed: endIndex < _complaints.length ? () => setState(() => _currentPage++) : null,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const _TableRow({required this.complaint});

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _isHovered = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'In-Progress': return Colors.blue;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(widget.complaint['icon'], style: const TextStyle(fontSize: 20)),
              ),
            ),
            
            // Category
            Expanded(
              flex: 2,
              child: Text(widget.complaint['category'], style: theme.textTheme.bodyMedium),
            ),
            
            // Time
            Expanded(
              flex: 2,
              child: Text(
                widget.complaint['time'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            
            // Driver
            Expanded(
              flex: 2,
              child: Text(widget.complaint['driver'], style: theme.textTheme.bodyMedium),
            ),
            
            // Status
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.complaint['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.complaint['status'],
                  style: TextStyle(
                    color: _getStatusColor(widget.complaint['status']),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            // Action
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {},
                child: const Text('View'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
