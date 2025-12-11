import 'package:flutter/material.dart';
import 'customer_support_detail_screen.dart';

class CustomerSupportIssueListWeb extends StatelessWidget {
  final String category;
  final List<String> issues;

  const CustomerSupportIssueListWeb({
    super.key,
    required this.category,
    required this.issues,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getCategoryIcon(), size: 32, color: _getCategoryColor()),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose the issue you\'re facing',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                ...issues.map((issue) => _buildIssueRow(context, isDark, issue)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueRow(BuildContext context, bool isDark, String issue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerSupportDetailScreen(category: category, issue: issue),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 24,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    issue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (category.contains('Account')) return Icons.account_circle;
    if (category.contains('Booking')) return Icons.add_circle;
    if (category.contains('Tracking')) return Icons.location_on;
    if (category.contains('Collection')) return Icons.delete;
    if (category.contains('Payment')) return Icons.payment;
    if (category.contains('App')) return Icons.phone_android;
    if (category.contains('Location')) return Icons.map;
    if (category.contains('Safety')) return Icons.warning;
    if (category.contains('History')) return Icons.history;
    if (category.contains('Notifications')) return Icons.notifications;
    return Icons.feedback;
  }

  Color _getCategoryColor() {
    if (category.contains('Account')) return const Color(0xFF1A73E8);
    if (category.contains('Booking')) return const Color(0xFF00C853);
    if (category.contains('Tracking')) return const Color(0xFFFF9800);
    if (category.contains('Collection')) return const Color(0xFF9C27B0);
    if (category.contains('Payment')) return const Color(0xFF4CAF50);
    if (category.contains('App')) return const Color(0xFF2196F3);
    if (category.contains('Location')) return const Color(0xFFE91E63);
    if (category.contains('Safety')) return const Color(0xFFF44336);
    if (category.contains('History')) return const Color(0xFF607D8B);
    if (category.contains('Notifications')) return const Color(0xFFFF5722);
    return const Color(0xFF9E9E9E);
  }
}
