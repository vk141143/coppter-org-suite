import 'package:flutter/material.dart';

class WebFilterSidebar extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final VoidCallback onClearFilters;
  final bool isCollapsed;

  const WebFilterSidebar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearFilters,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: isCollapsed
                ? const Icon(Icons.filter_list)
                : Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCollapsed) ...[
                    Text('Status', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 12),
                  ],
                  _buildFilterItem(theme, 'All', Icons.list_alt, Colors.grey, isCollapsed),
                  _buildFilterItem(theme, 'Pending', Icons.pending, Colors.orange, isCollapsed),
                  _buildFilterItem(theme, 'In-Progress', Icons.sync, Colors.blue, isCollapsed),
                  _buildFilterItem(theme, 'Completed', Icons.check_circle, Colors.green, isCollapsed),
                ],
              ),
            ),
          ),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(ThemeData theme, String status, IconData icon, Color color, bool collapsed) {
    final isSelected = selectedStatus == status;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onStatusChanged(status),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.6)),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
