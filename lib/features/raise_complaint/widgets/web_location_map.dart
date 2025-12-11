import 'package:flutter/material.dart';

class WebLocationMap extends StatelessWidget {
  final String location;
  final VoidCallback onLocationTap;

  const WebLocationMap({super.key, required this.location, required this.onLocationTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onLocationTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    location.isEmpty ? 'Click to select location on map' : 'Location selected',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            if (location.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(location, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
