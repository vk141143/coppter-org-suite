import 'package:flutter/material.dart';

class WebSummaryPanel extends StatelessWidget {
  final String? category;
  final int imageCount;
  final String description;
  final String location;

  const WebSummaryPanel({
    super.key,
    this.category,
    required this.imageCount,
    required this.description,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryItem(theme, Icons.category, 'Category', category ?? 'Not selected', category == null),
          const SizedBox(height: 16),
          _buildSummaryItem(theme, Icons.image, 'Images', '$imageCount uploaded', imageCount == 0),
          const SizedBox(height: 16),
          _buildSummaryItem(theme, Icons.description, 'Description', description.isEmpty ? 'Not provided' : '${description.length} characters', description.isEmpty),
          const SizedBox(height: 16),
          _buildSummaryItem(theme, Icons.location_on, 'Location', location.isEmpty ? 'Not provided' : location, location.isEmpty),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(ThemeData theme, IconData icon, String label, String value, bool isWarning) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: isWarning ? Colors.orange : theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isWarning ? Colors.orange : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
