import 'package:flutter/material.dart';

class WebEtaDistanceCards extends StatefulWidget {
  const WebEtaDistanceCards({super.key});

  @override
  State<WebEtaDistanceCards> createState() => _WebEtaDistanceCardsState();
}

class _WebEtaDistanceCardsState extends State<WebEtaDistanceCards> {
  bool _etaHovered = false;
  bool _distanceHovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'ETA', '5 mins', Icons.access_time, Colors.blue, _etaHovered, (hovered) => setState(() => _etaHovered = hovered))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(context, 'Distance', '1.2 km', Icons.location_on, Colors.green, _distanceHovered, (hovered) => setState(() => _distanceHovered = hovered))),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, bool isHovered, Function(bool) onHover) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: isHovered
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        transform: isHovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }
}
