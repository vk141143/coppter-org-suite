import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Open', 'Under Review', 'Resolved', 'Closed'];

  final List<Map<String, dynamic>> _disputes = [
    {'id': 'DS001', 'booking': 'BK001', 'raisedBy': 'Customer', 'reason': 'Price too high', 'amount': 45.0, 'status': 'Open', 'date': '2024-03-15'},
    {'id': 'DS002', 'booking': 'BK002', 'raisedBy': 'Driver', 'reason': 'Customer not available', 'amount': 60.0, 'status': 'Under Review', 'date': '2024-03-14'},
    {'id': 'DS003', 'booking': 'BK003', 'raisedBy': 'Customer', 'reason': 'Incomplete service', 'amount': 90.0, 'status': 'Resolved', 'date': '2024-03-13'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disputes Management', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildFilterBar(theme),
            const SizedBox(height: 24),
            _buildDisputesTable(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Wrap(
      spacing: 12,
      children: _filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (selected) => setState(() => _selectedFilter = filter),
          backgroundColor: theme.colorScheme.surface,
          selectedColor: BrandColors.primaryGreen.withOpacity(0.2),
          checkmarkColor: BrandColors.primaryGreen,
        );
      }).toList(),
    );
  }

  Widget _buildDisputesTable(ThemeData theme) {
    return CustomCard(
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
              6: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: BrandColors.primaryGreen.withOpacity(0.1)),
                children: [
                  _tableHeader('ID'),
                  _tableHeader('Booking'),
                  _tableHeader('Raised By'),
                  _tableHeader('Reason'),
                  _tableHeader('Amount'),
                  _tableHeader('Status'),
                  _tableHeader('Actions'),
                ],
              ),
              ..._disputes.map((dispute) => _buildDisputeRow(theme, dispute)),
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

  TableRow _buildDisputeRow(ThemeData theme, Map<String, dynamic> dispute) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(dispute['id'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(dispute['booking'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(dispute['raisedBy'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(dispute['reason'])),
        Padding(padding: const EdgeInsets.all(12), child: Text('£${dispute['amount']}')),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(dispute['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(dispute['status'], style: TextStyle(color: _getStatusColor(dispute['status']), fontSize: 12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _showDisputeDetails(dispute),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.gavel, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _resolveDispute(dispute),
                tooltip: 'Resolve',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved': return const Color(0xFF0F5132);
      case 'Under Review': return const Color(0xFF2D7A4F);
      case 'Open': return const Color(0xFF5A9F6E);
      case 'Closed': return const Color(0xFF87C48D);
      default: return const Color(0xFF1F1F1F);
    }
  }

  void _showDisputeDetails(Map<String, dynamic> dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dispute ${dispute['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking: ${dispute['booking']}'),
              Text('Raised By: ${dispute['raisedBy']}'),
              Text('Reason: ${dispute['reason']}'),
              Text('Amount: £${dispute['amount']}'),
              Text('Status: ${dispute['status']}'),
              Text('Date: ${dispute['date']}'),
              const SizedBox(height: 16),
              const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(child: Text('Photos/Messages')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _resolveDispute(Map<String, dynamic> dispute) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Action'),
              items: ['Refund Customer', 'Adjust Price', 'Penalize Driver', 'Close Dispute'].map((action) {
                return DropdownMenuItem(value: action, child: Text(action));
              }).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Resolution Notes'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}
