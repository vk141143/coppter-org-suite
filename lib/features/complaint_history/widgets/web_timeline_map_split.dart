import 'package:flutter/material.dart';

class WebTimelineMapSplit extends StatelessWidget {
  const WebTimelineMapSplit({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Timeline Section
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    const Icon(
                      Icons.timeline,
                      color: Color(0xFF0F5132),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTimelineItem(
                  context,
                  icon: Icons.add_circle,
                  title: 'New complaint submitted',
                  subtitle: 'Plastic Waste - CMP-006',
                  time: '2 hours ago',
                  isCompleted: true,
                  color: const Color(0xFF0F5132),
                ),
                _buildTimelineItem(
                  context,
                  icon: Icons.person_add,
                  title: 'Driver assigned',
                  subtitle: 'John Doe assigned to CMP-005',
                  time: '5 hours ago',
                  isCompleted: true,
                  color: const Color(0xFF2D7A4F),
                ),
                _buildTimelineItem(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Pickup in progress',
                  subtitle: 'CMP-004 collection started',
                  time: '1 day ago',
                  isCompleted: true,
                  color: const Color(0xFF5A9F6E),
                ),
                _buildTimelineItem(
                  context,
                  icon: Icons.check_circle,
                  title: 'Complaint completed',
                  subtitle: 'CMP-003 successfully resolved',
                  time: '2 days ago',
                  isCompleted: true,
                  color: const Color(0xFF0F5132),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // Map Preview Section
        Expanded(
          flex: 4,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 400,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Map placeholder
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFD1E7DD).withOpacity(0.3),
                            const Color(0xFF87C48D).withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.map,
                          size: 80,
                          color: const Color(0xFF0F5132).withOpacity(0.5),
                        ),
                      ),
                    ),
                    
                    // Markers
                    Positioned(
                      top: 80,
                      left: 100,
                      child: _buildMapMarker(const Color(0xFF0F5132), '3'),
                    ),
                    Positioned(
                      top: 150,
                      right: 120,
                      child: _buildMapMarker(const Color(0xFF2D7A4F), '2'),
                    ),
                    Positioned(
                      bottom: 100,
                      left: 150,
                      child: _buildMapMarker(const Color(0xFF5A9F6E), '5'),
                    ),
                    
                    // Overlay label
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF0F5132),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Active Locations',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(Color color, String count) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
