import 'package:flutter/material.dart';

class WebHeroBar extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onExport;
  final VoidCallback onRefresh;
  final VoidCallback? onBack;

  const WebHeroBar({
    Key? key,
    required this.onSearch,
    required this.onFilter,
    required this.onExport,
    required this.onRefresh,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (onBack != null) ...[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back',
            ),
            const SizedBox(width: 16),
          ],
          
          // Title
          Text(
            'Request Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const Spacer(),
          
          // Action Buttons
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onExport,
            icon: const Icon(Icons.download),
            tooltip: 'Export',
          ),
        ],
      ),
    );
  }
}
