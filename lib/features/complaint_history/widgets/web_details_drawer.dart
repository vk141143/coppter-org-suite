import 'package:flutter/material.dart';
import '../../user/screens/track_complaint_screen.dart';

class WebDetailsDrawer extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onClose;
  final VoidCallback onCancel;

  const WebDetailsDrawer({
    super.key,
    required this.complaint,
    required this.onClose,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(complaint['status']);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset((1 - value) * 450, 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: 450,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          border: Border(left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(-4, 0))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Complaint Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: theme.colorScheme.surfaceVariant)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(complaint['icon'], style: const TextStyle(fontSize: 64)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Complaint ID', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                              const SizedBox(height: 4),
                              Text(complaint['id'], style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(complaint['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection(theme, 'Category', complaint['category'], Icons.category),
                    _buildDetailSection(theme, 'Date & Time', '${complaint['date']} at ${complaint['time']}', Icons.calendar_today),
                    _buildDetailSection(theme, 'Location', complaint['location'], Icons.location_on),
                    _buildDetailSection(theme, 'Description', complaint['description'], Icons.description),
                    const SizedBox(height: 32),
                    if (complaint['status'] != 'Completed')
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen())),
                        icon: const Icon(Icons.track_changes),
                        label: const Text('Track Issue'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    if (complaint['status'] == 'Pending' || complaint['status'] == 'In-Progress') ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel Complaint'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In-Progress': return Colors.blue;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}
