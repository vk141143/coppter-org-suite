import 'package:flutter/material.dart';

class WebHeaderBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final VoidCallback onExportTap;
  final VoidCallback onRefreshTap;

  const WebHeaderBar({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.onExportTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text('Issue History', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 32),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search complaints by ID, category, or location...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildIconButton(theme, Icons.filter_list, 'Filter', onFilterTap),
          const SizedBox(width: 8),
          _buildIconButton(theme, Icons.download, 'Export', onExportTap),
          const SizedBox(width: 8),
          _buildIconButton(theme, Icons.refresh, 'Refresh', onRefreshTap),
        ],
      ),
    );
  }

  Widget _buildIconButton(ThemeData theme, IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
