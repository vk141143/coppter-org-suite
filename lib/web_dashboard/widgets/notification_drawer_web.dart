import 'package:flutter/material.dart';

class NotificationDrawerWeb extends StatelessWidget {
  final VoidCallback onClose;
  
  const NotificationDrawerWeb({super.key, required this.onClose});

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': 'Complaint Resolved',
      'message': 'Your household waste complaint has been resolved',
      'time': '5 min ago',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'title': 'Driver Assigned',
      'message': 'John Smith has been assigned to your complaint',
      'time': '1 hour ago',
      'icon': Icons.person,
      'color': Color(0xFF2D7A4F),
    },
    {
      'title': 'Pickup Scheduled',
      'message': 'Your waste pickup is scheduled for tomorrow',
      'time': '2 hours ago',
      'icon': Icons.schedule,
      'color': Color(0xFF5A9F6E),
    },
    {
      'title': 'Status Update',
      'message': 'Driver is on the way to your location',
      'time': '3 hours ago',
      'icon': Icons.local_shipping,
      'color': Color(0xFF0F5132),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        child: Container(
          width: 380,
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Notifications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _NotificationItem(
                      title: notification['title'],
                      message: notification['message'],
                      time: notification['time'],
                      icon: notification['icon'],
                      color: notification['color'],
                    );
                  },
                ),
              ),
              
              // Clear All Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Clear All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered ? theme.colorScheme.surfaceVariant.withOpacity(0.5) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
