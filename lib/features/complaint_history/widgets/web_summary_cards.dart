import 'package:flutter/material.dart';

class WebSummaryCards extends StatelessWidget {
  final List<Map<String, dynamic>> complaints;

  const WebSummaryCards({super.key, required this.complaints});

  @override
  Widget build(BuildContext context) {
    final total = complaints.length;
    final pending = complaints.where((c) => c['status'] == 'Pending').length;
    final inProgress = complaints.where((c) => c['status'] == 'In-Progress').length;
    final completed = complaints.where((c) => c['status'] == 'Completed').length;

    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Total', value: '$total', icon: Icons.assignment, color: Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'Pending', value: '$pending', icon: Icons.pending, color: Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'In-Progress', value: '$inProgress', icon: Icons.sync, color: Colors.purple)),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'Completed', value: '$completed', icon: Icons.check_circle, color: Colors.green)),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered ? [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: widget.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(widget.icon, color: widget.color, size: 28)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(widget.title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
