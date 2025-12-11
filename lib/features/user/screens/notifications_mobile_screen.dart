import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/auto_text.dart';

class NotificationsMobileScreen extends StatefulWidget {
  const NotificationsMobileScreen({super.key});

  @override
  State<NotificationsMobileScreen> createState() => _NotificationsMobileScreenState();
}

class _NotificationsMobileScreenState extends State<NotificationsMobileScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.check_circle,
      'color': Colors.green,
      'title': 'Issue Resolved',
      'message': 'Your household waste issue has been resolved',
      'time': '5 minutes ago',
      'isRead': false,
    },
    {
      'icon': Icons.local_shipping,
      'color': Color(0xFF2D7A4F),
      'title': 'Driver Assigned',
      'message': 'John Smith has been assigned to your issue',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'icon': Icons.schedule,
      'color': Color(0xFF5A9F6E),
      'title': 'Pickup Scheduled',
      'message': 'Your waste pickup is scheduled for tomorrow at 10:00 AM',
      'time': '3 hours ago',
      'isRead': true,
    },
    {
      'icon': Icons.star,
      'color': Color(0xFF87C48D),
      'title': 'Rate Your Experience',
      'message': 'Please rate your recent waste collection service',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'icon': Icons.info_outline,
      'color': Color(0xFF0F5132),
      'title': 'Service Update',
      'message': 'New waste categories are now available in your area',
      'time': '2 days ago',
      'isRead': true,
    },
  ];

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const AutoText('Notifications'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const AutoText('Mark all read'),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: _notifications.isEmpty
            ? _buildEmptyState(theme)
            : Column(
                children: [
                  if (_unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'You have $_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(
                            theme, _notifications[index], index);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNotificationItem(
      ThemeData theme, Map<String, dynamic> notification, int index) {
    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoText('Notification deleted')),
        );
      },
      child: CustomCard(
        margin: const EdgeInsets.only(bottom: 12),
        onTap: () => _markAsRead(index),
        child: Container(
          decoration: BoxDecoration(
            color: notification['isRead']
                ? Colors.transparent
                : theme.colorScheme.primary.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification['isRead'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification['time'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          AutoText(
            'No Notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          AutoText(
            'You\'re all caught up!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }
}
