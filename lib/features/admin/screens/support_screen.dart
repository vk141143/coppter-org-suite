import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../core/constants/brand_colors.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Support Management', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Support Tickets'),
              Tab(text: 'FAQs Management'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTicketsTab(theme),
                _buildFAQsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab(ThemeData theme) {
    final tickets = [
      {'id': 'TK001', 'user': 'John Doe', 'subject': 'Payment issue', 'status': 'Open', 'priority': 'High'},
      {'id': 'TK002', 'user': 'Jane Smith', 'subject': 'App not working', 'status': 'In Progress', 'priority': 'Medium'},
      {'id': 'TK003', 'user': 'Bob Wilson', 'subject': 'Driver complaint', 'status': 'Resolved', 'priority': 'Low'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: CustomCard(
        child: Column(
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: BrandColors.primaryGreen.withOpacity(0.1)),
                  children: [
                    _tableHeader('ID'),
                    _tableHeader('User'),
                    _tableHeader('Subject'),
                    _tableHeader('Priority'),
                    _tableHeader('Status'),
                    _tableHeader('Actions'),
                  ],
                ),
                ...tickets.map((ticket) => _buildTicketRow(theme, ticket)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQsTab(ThemeData theme) {
    final faqs = [
      {'question': 'How do I book a pickup?', 'answer': 'You can book a pickup through the app...', 'category': 'Booking'},
      {'question': 'What payment methods are accepted?', 'answer': 'We accept credit cards, debit cards...', 'category': 'Payment'},
      {'question': 'How do I track my driver?', 'answer': 'You can track your driver in real-time...', 'category': 'Tracking'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _addFAQ,
                icon: const Icon(Icons.add),
                label: const Text('Add FAQ'),
                style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => CustomCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(faq['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF0F5132)), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Color(0xFF87C48D)), onPressed: () {}),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(faq['answer']!),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: BrandColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(faq['category']!, style: const TextStyle(fontSize: 12, color: BrandColors.primaryGreen)),
                ),
              ],
            ),
          )),
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

  TableRow _buildTicketRow(ThemeData theme, Map<String, dynamic> ticket) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(ticket['id'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(ticket['user'])),
        Padding(padding: const EdgeInsets.all(12), child: Text(ticket['subject'])),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(ticket['priority']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(ticket['priority'], style: TextStyle(color: _getPriorityColor(ticket['priority']), fontSize: 12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(ticket['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(ticket['status'], style: TextStyle(color: _getStatusColor(ticket['status']), fontSize: 12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _viewTicket(ticket),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.reply, size: 18, color: Color(0xFF0F5132)),
                onPressed: () => _replyTicket(ticket),
                tooltip: 'Reply',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return const Color(0xFF0F5132);
      case 'Medium': return const Color(0xFF2D7A4F);
      case 'Low': return const Color(0xFF5A9F6E);
      default: return const Color(0xFF1F1F1F);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved': return const Color(0xFF0F5132);
      case 'In Progress': return const Color(0xFF2D7A4F);
      case 'Open': return const Color(0xFF5A9F6E);
      default: return const Color(0xFF1F1F1F);
    }
  }

  void _viewTicket(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ticket ${ticket['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${ticket['user']}'),
            Text('Subject: ${ticket['subject']}'),
            Text('Priority: ${ticket['priority']}'),
            Text('Status: ${ticket['status']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _replyTicket(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Ticket'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Your Reply'),
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: BrandColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _addFAQ() {}
}
