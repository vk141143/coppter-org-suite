import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class WebStatusTimeline extends StatelessWidget {
  final int currentStatus;

  const WebStatusTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Timeline', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            children: List.generate(AppConstants.complaintStatus.length, (index) {
              final isCompleted = index <= currentStatus;
              final isCurrent = index == currentStatus;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Tooltip(
                            message: _getStatusTime(index, isCompleted, isCurrent),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                                shape: BoxShape.circle,
                                border: isCurrent ? Border.all(color: theme.colorScheme.primary, width: 3) : null,
                                boxShadow: isCurrent ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)] : [],
                              ),
                              child: Icon(_getStatusIcon(index), color: isCompleted ? Colors.white : theme.colorScheme.onSurfaceVariant, size: 24),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppConstants.complaintStatus[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (isCompleted && index < currentStatus)
                            Text(_getCompletedTime(index), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                    if (index < AppConstants.complaintStatus.length - 1)
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 60),
                          decoration: BoxDecoration(
                            color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(int index) {
    switch (index) {
      case 0: return Icons.receipt_long;
      case 1: return Icons.person_add;
      case 2: return Icons.local_shipping;
      case 3: return Icons.check_circle;
      default: return Icons.circle;
    }
  }

  String _getStatusTime(int index, bool isCompleted, bool isCurrent) {
    if (isCurrent) return 'In Progress';
    if (isCompleted) return _getCompletedTime(index);
    return 'Pending';
  }

  String _getCompletedTime(int index) {
    switch (index) {
      case 0: return '10:30 AM';
      case 1: return '11:15 AM';
      case 2: return '2:00 PM';
      default: return '';
    }
  }
}
