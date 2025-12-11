import 'package:flutter/material.dart';

class WebSummaryPills extends StatelessWidget {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;

  const WebSummaryPills({
    super.key,
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPill(
            context,
            icon: Icons.list_alt,
            label: 'Total Requests',
            value: total,
            color: const Color(0xFF0F5132),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildPill(
            context,
            icon: Icons.pending_actions,
            label: 'Pending',
            value: pending,
            color: const Color(0xFF5A9F6E),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildPill(
            context,
            icon: Icons.autorenew,
            label: 'In-Progress',
            value: inProgress,
            color: const Color(0xFF2D7A4F),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildPill(
            context,
            icon: Icons.check_circle,
            label: 'Completed',
            value: completed,
            color: const Color(0xFF0F5132),
          ),
        ),
      ],
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border(
              bottom: BorderSide(
                color: color,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+12%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
