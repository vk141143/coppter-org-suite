import 'package:flutter/material.dart';

class ScheduleEvent {
  final String time;
  final String title;
  final String driver;
  final String status;
  final String day;

  ScheduleEvent({
    required this.time,
    required this.title,
    required this.driver,
    required this.status,
    required this.day,
  });
}

class UpcomingScheduleWeb extends StatelessWidget {
  UpcomingScheduleWeb({super.key});

  final List<ScheduleEvent> events = [
    ScheduleEvent(time: '9:00 AM', title: 'Ward 12 Pickup', driver: 'Mike Johnson', status: 'In Progress', day: 'Today'),
    ScheduleEvent(time: '11:30 AM', title: 'Ward 5 Collection', driver: 'Sarah Williams', status: 'Scheduled', day: 'Today'),
    ScheduleEvent(time: '2:00 PM', title: 'Ward 8 Pickup', driver: 'John Davis', status: 'Scheduled', day: 'Today'),
    ScheduleEvent(time: '8:00 AM', title: 'Ward 3 Collection', driver: 'Mike Johnson', status: 'Scheduled', day: 'Tomorrow'),
    ScheduleEvent(time: '10:00 AM', title: 'Ward 15 Pickup', driver: 'Emma Brown', status: 'Scheduled', day: 'Tomorrow'),
    ScheduleEvent(time: '9:00 AM', title: 'Ward 7 Collection', driver: 'David Lee', status: 'Scheduled', day: 'This Week'),
    ScheduleEvent(time: '1:00 PM', title: 'Ward 20 Pickup', driver: 'Sarah Williams', status: 'Scheduled', day: 'This Week'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width > 1400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Pickup Schedule',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MiniCalendar(),
                  const SizedBox(width: 24),
                  Expanded(child: _ScheduleList(events: events)),
                ],
              )
            : Column(
                children: [
                  _MiniCalendar(),
                  const SizedBox(height: 16),
                  _ScheduleList(events: events),
                ],
              ),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${_getMonthName(now.month)} ${now.year}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 2;
                  final isCurrentDay = dayNumber == now.day;
                  final isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;

                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrentDay ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isValidDay ? '$dayNumber' : '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCurrentDay
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _ScheduleList extends StatelessWidget {
  final List<ScheduleEvent> events;

  const _ScheduleList({required this.events});

  @override
  Widget build(BuildContext context) {
    final todayEvents = events.where((e) => e.day == 'Today').toList();
    final tomorrowEvents = events.where((e) => e.day == 'Tomorrow').toList();
    final weekEvents = events.where((e) => e.day == 'This Week').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayEvents.isNotEmpty) ...[
          _DayHeader(title: 'Today'),
          ...todayEvents.map((e) => _EventCard(event: e)),
        ],
        if (tomorrowEvents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DayHeader(title: 'Tomorrow'),
          ...tomorrowEvents.map((e) => _EventCard(event: e)),
        ],
        if (weekEvents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _DayHeader(title: 'This Week'),
          ...weekEvents.map((e) => _EventCard(event: e)),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String title;

  const _DayHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final ScheduleEvent event;

  const _EventCard({required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isHovered = false;

  Color _getStatusColor() {
    switch (widget.event.status) {
      case 'In Progress':
        return Colors.amber;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        transform: _isHovered ? (Matrix4.identity()..translate(-4.0, 0.0)) : Matrix4.identity(),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: statusColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        widget.event.time.split(' ')[0],
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.event.time.split(' ')[1],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Driver: ${widget.event.driver}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.event.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
