import 'dart:async';
import 'package:flutter/material.dart';

class RecentComplaintsSection extends StatefulWidget {
  const RecentComplaintsSection({super.key});

  @override
  State<RecentComplaintsSection> createState() => _RecentComplaintsSectionState();
}

class _RecentComplaintsSectionState extends State<RecentComplaintsSection> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  String _getCategoryImage(String category) {
    switch (category) {
      case 'Household':
        return 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400';
      case 'E-Waste':
        return 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400';
      case 'Recyclables':
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400';
      case 'Bulk Waste':
        return 'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=400';
      case 'Medical':
        return 'https://images.unsplash.com/photo-1584820927498-cfe5211fd8bf?w=400';
      case 'Garden':
        return 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=400';
      case 'Construction':
        return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400';
      case 'Plastic':
        return 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=400';
      default:
        return 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final complaints = [
      {
        'id': 'WM-2024-001',
        'category': 'Household',
        'icon': '🏠',
        'date': 'Dec 15, 2024',
        'time': '10:30 AM',
        'status': 'Completed',
        'price': '₹250',
        'color': Colors.blue,
      },
      {
        'id': 'WM-2024-002',
        'category': 'E-Waste',
        'icon': '💻',
        'date': 'Dec 14, 2024',
        'time': '2:15 PM',
        'status': 'Completed',
        'price': '₹180',
        'color': Colors.purple,
      },
      {
        'id': 'WM-2024-003',
        'category': 'Recyclables',
        'icon': '♻️',
        'date': 'Dec 13, 2024',
        'time': '9:00 AM',
        'status': 'Completed',
        'price': '₹120',
        'color': Colors.green,
      },
      {
        'id': 'WM-2024-004',
        'category': 'Bulk Waste',
        'icon': '🚛',
        'date': 'Dec 12, 2024',
        'time': '11:45 AM',
        'status': 'Assigned',
        'price': '₹450',
        'color': Colors.orange,
      },
      {
        'id': 'WM-2024-005',
        'category': 'Medical',
        'icon': '🏥',
        'date': 'Dec 11, 2024',
        'time': '3:30 PM',
        'status': 'Pending',
        'price': '₹200',
        'color': Colors.red,
      },
      {
        'id': 'WM-2024-006',
        'category': 'Garden',
        'icon': '🌿',
        'date': 'Dec 10, 2024',
        'time': '8:00 AM',
        'status': 'Completed',
        'price': '₹150',
        'color': Colors.teal,
      },
      {
        'id': 'WM-2024-007',
        'category': 'Construction',
        'icon': '🏗️',
        'date': 'Dec 9, 2024',
        'time': '1:20 PM',
        'status': 'Completed',
        'price': '₹600',
        'color': Colors.brown,
      },
      {
        'id': 'WM-2024-008',
        'category': 'Plastic',
        'icon': '🥤',
        'date': 'Dec 8, 2024',
        'time': '4:00 PM',
        'status': 'Completed',
        'price': '₹90',
        'color': Colors.cyan,
      },
      {
        'id': 'WM-2024-009',
        'category': 'Household',
        'icon': '🏠',
        'date': 'Dec 7, 2024',
        'time': '5:00 PM',
        'status': 'Completed',
        'price': '₹300',
        'color': Colors.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Pickups',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 3,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 3;
              return Row(
                children: List.generate(3, (index) {
                  final complaintIndex = startIndex + index;
                  if (complaintIndex >= complaints.length) {
                    return const Expanded(child: SizedBox());
                  }
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
                      child: _ComplaintCard(
                        complaint: complaints[complaintIndex],
                        backgroundImage: _getCategoryImage(complaints[complaintIndex]['category'] as String),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ComplaintCard extends StatefulWidget {
  final Map<String, dynamic> complaint;
  final String backgroundImage;

  const _ComplaintCard({required this.complaint, required this.backgroundImage});

  @override
  State<_ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<_ComplaintCard> {
  bool _isHovered = false;

  Color _getStatusColor() {
    switch (widget.complaint['status']) {
      case 'Completed':
        return const Color(0xFF4CAF50);
      case 'Assigned':
        return const Color(0xFFFF9800);
      case 'Pending':
        return const Color(0xFFE53E3E);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: widget.complaint['color'].withOpacity(0.3),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.complaint['icon'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.complaint['id'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.complaint['category'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          widget.complaint['date'],
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          widget.complaint['time'],
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.complaint['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          widget.complaint['price'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 18,
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
}
