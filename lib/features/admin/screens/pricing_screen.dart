import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  
  final List<Map<String, dynamic>> _payments = [
    {
      'paymentId': 'PAY001',
      'bookingId': 'BK001',
      'customerName': 'John Doe',
      'customerPhone': '+1 234 567 8900',
      'driverName': 'Mike Johnson',
      'driverPhone': '+1 234 567 8901',
      'amount': 85.50,
      'status': 'Completed',
      'method': 'Card',
      'date': '2024-03-15',
      'time': '10:30 AM',
    },
    {
      'paymentId': 'PAY002',
      'bookingId': 'BK002',
      'customerName': 'Jane Smith',
      'customerPhone': '+1 234 567 8902',
      'driverName': 'David Brown',
      'driverPhone': '+1 234 567 8903',
      'amount': 120.00,
      'status': 'Pending',
      'method': 'Cash',
      'date': '2024-03-15',
      'time': '11:45 AM',
    },
    {
      'paymentId': 'PAY003',
      'bookingId': 'BK003',
      'customerName': 'Bob Wilson',
      'customerPhone': '+1 234 567 8904',
      'driverName': 'Mike Johnson',
      'driverPhone': '+1 234 567 8901',
      'amount': 65.00,
      'status': 'Completed',
      'method': 'Card',
      'date': '2024-03-14',
      'time': '02:15 PM',
    },
    {
      'paymentId': 'PAY004',
      'bookingId': 'BK004',
      'customerName': 'Alice Brown',
      'customerPhone': '+1 234 567 8905',
      'driverName': 'Sarah Lee',
      'driverPhone': '+1 234 567 8906',
      'amount': 95.75,
      'status': 'Failed',
      'method': 'Card',
      'date': '2024-03-14',
      'time': '04:30 PM',
    },
    {
      'paymentId': 'PAY005',
      'bookingId': 'BK005',
      'customerName': 'Charlie Davis',
      'customerPhone': '+1 234 567 8907',
      'driverName': 'David Brown',
      'driverPhone': '+1 234 567 8903',
      'amount': 150.00,
      'status': 'Completed',
      'method': 'Cash',
      'date': '2024-03-13',
      'time': '09:00 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(theme),
          _buildStatsCards(theme),
          _buildControls(theme),
          Expanded(child: _buildPaymentsTable(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payments', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 28)),
              const SizedBox(height: 4),
              Text('View all payment transactions', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    final total = _payments.fold(0.0, (sum, p) => sum + p['amount']);
    final completed = _payments.where((p) => p['status'] == 'Completed').length;
    final pending = _payments.where((p) => p['status'] == 'Pending').length;
    final failed = _payments.where((p) => p['status'] == 'Failed').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(theme, 'Total Revenue', '£${total.toStringAsFixed(2)}', Icons.payments, const Color(0xFF0F5132))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Completed', '$completed', Icons.check_circle, const Color(0xFF2D7A4F))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Pending', '$pending', Icons.pending, const Color(0xFF5A9F6E))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Failed', '$failed', Icons.error, const Color(0xFF87C48D))),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: CustomCard(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search by payment ID, customer, driver, or booking ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Container(width: 1, height: 40, color: theme.colorScheme.onSurface.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 16)),
            DropdownButton<String>(
              value: _statusFilter,
              underline: const SizedBox(),
              items: ['All', 'Completed', 'Pending', 'Failed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) => setState(() => _statusFilter = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTable(ThemeData theme) {
    final filtered = _payments.where((p) {
      final matchesStatus = _statusFilter == 'All' || p['status'] == _statusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          p['paymentId'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['bookingId'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['customerName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['driverName'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.payment_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text('No payments found', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ]));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: CustomCard(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
            columnSpacing: 30,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 90,
            columns: const [
              DataColumn(label: Text('Payment ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
            ],
            rows: filtered.map((payment) {
              return DataRow(cells: [
                DataCell(Text(payment['paymentId'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                DataCell(Text(payment['bookingId'], style: const TextStyle(fontSize: 13))),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(payment['customerName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(payment['customerPhone'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(payment['driverName'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(payment['driverPhone'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                )),
                DataCell(Text('£${payment['amount'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: BrandColors.primaryGreen))),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(payment['method'] == 'Card' ? Icons.credit_card : Icons.money, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(payment['method'], style: const TextStyle(fontSize: 13)),
                  ],
                )),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(payment['date'], style: const TextStyle(fontSize: 13)),
                    Text(payment['time'], style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ],
                )),
                DataCell(_buildStatusBadge(payment['status'], theme)),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)), onPressed: () => _viewPaymentDetails(payment), tooltip: 'View'),
                    IconButton(icon: const Icon(Icons.receipt, size: 18, color: Color(0xFF0F5132)), onPressed: () => _downloadReceipt(payment), tooltip: 'Receipt'),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'Completed': color = const Color(0xFF0F5132); break;
      case 'Pending': color = const Color(0xFF5A9F6E); break;
      case 'Failed': color = const Color(0xFF87C48D); break;
      default: color = const Color(0xFF1F1F1F);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _viewPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details - ${payment['paymentId']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Payment ID', payment['paymentId']),
              _buildDetailRow('Booking ID', payment['bookingId']),
              const Divider(),
              _buildDetailRow('Customer Name', payment['customerName']),
              _buildDetailRow('Customer Phone', payment['customerPhone']),
              const Divider(),
              _buildDetailRow('Driver Name', payment['driverName']),
              _buildDetailRow('Driver Phone', payment['driverPhone']),
              const Divider(),
              _buildDetailRow('Amount', '£${payment['amount'].toStringAsFixed(2)}'),
              _buildDetailRow('Payment Method', payment['method']),
              _buildDetailRow('Status', payment['status']),
              _buildDetailRow('Date', payment['date']),
              _buildDetailRow('Time', payment['time']),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _downloadReceipt(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading receipt for ${payment['paymentId']}...')),
    );
  }
}
