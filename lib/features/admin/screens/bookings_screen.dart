import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Assigned', 'In Progress', 'Completed', 'Cancelled'];

  final List<Map<String, dynamic>> _bookings = [
    {'id': 'BK001', 'customer': 'John Doe', 'driver': 'Mike Johnson', 'category': 'Household', 'price': 45.0, 'status': 'In Progress', 'date': '2024-03-15'},
    {'id': 'BK002', 'customer': 'Jane Smith', 'driver': 'Sarah Williams', 'category': 'E-Waste', 'price': 60.0, 'status': 'Completed', 'date': '2024-03-15'},
    {'id': 'BK003', 'customer': 'Bob Wilson', 'driver': 'Unassigned', 'category': 'Construction', 'price': 90.0, 'status': 'Pending', 'date': '2024-03-14'},
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
            Text('Bookings Management', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildFilterBar(theme),
            const SizedBox(height: 24),
            _buildBookingsTable(theme),
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

  Widget _buildBookingsTable(ThemeData theme) {
    return CustomCard(
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
              6: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: BrandColors.primaryGreen.withOpacity(0.1)),
                children: [
                  _tableHeader('ID'),
                  _tableHeader('Customer'),
                  _tableHeader('Driver'),
                  _tableHeader('Category'),
                  _tableHeader('Price'),
                  _tableHeader('Status'),
                  _tableHeader('Actions'),
                ],
              ),
              ..._bookings.map((booking) => _buildBookingRow(theme, booking)),
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

  TableRow _buildBookingRow(ThemeData theme, Map<String, dynamic> booking) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(booking['id'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(booking['customer'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(booking['driver'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(booking['category'])),
        Padding(padding: const EdgeInsets.all(12), child: Text('£${booking['price']}')),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(booking['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(booking['status'], style: TextStyle(color: _getStatusColor(booking['status']), fontSize: 12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _showBookingDetails(booking),
                tooltip: 'View Details',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _reassignDriver(booking),
                tooltip: 'Reassign Driver',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return BrandColors.primaryGreen;
      case 'In Progress': return const Color(0xFF2D7A4F);
      case 'Pending': return const Color(0xFF5A9F6E);
      case 'Cancelled': return const Color(0xFF87C48D);
      default: return const Color(0xFF1F1F1F);
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking ${booking['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking['customer']}'),
            Text('Driver: ${booking['driver']}'),
            Text('Category: ${booking['category']}'),
            Text('Price: £${booking['price']}'),
            Text('Status: ${booking['status']}'),
            Text('Date: ${booking['date']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _reassignDriver(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Driver'),
              items: ['Mike Johnson', 'Sarah Williams', 'Tom Brown'].map((driver) {
                return DropdownMenuItem(value: driver, child: Text(driver));
              }).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
