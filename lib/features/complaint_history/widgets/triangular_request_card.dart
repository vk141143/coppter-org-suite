import 'dart:math' as math;
import 'package:flutter/material.dart';

class TriangularRequestGrid extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Function(Map<String, dynamic>) onCardTap;

  const TriangularRequestGrid({
    super.key,
    required this.requests,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 40,
      runSpacing: 40,
      alignment: WrapAlignment.start,
      children: List.generate(requests.length, (index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: -100, end: 0),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: TriangularRequestCard(
                request: requests[index],
                onTap: () => onCardTap(requests[index]),
                delay: index * 100,
              ),
            );
          },
        );
      }),
    );
  }
}

class TriangularRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;
  final int delay;

  const TriangularRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<TriangularRequestCard> createState() => _TriangularRequestCardState();
}

class _TriangularRequestCardState extends State<TriangularRequestCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _glowController;
  Offset _mousePosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return const Color(0xFF0F5132);
      case 'Pending':
        return const Color(0xFF5A9F6E);
      case 'In-Progress':
        return const Color(0xFF2D7A4F);
      default:
        return const Color(0xFF888888);
    }
  }

  List<Color> _getGradientColors(String status) {
    switch (status) {
      case 'Completed':
        return [
          const Color(0xFF0F5132).withOpacity(0.3),
          const Color(0xFF2D7A4F).withOpacity(0.2),
          const Color(0xFF5A9F6E).withOpacity(0.1),
        ];
      case 'Pending':
        return [
          const Color(0xFF5A9F6E).withOpacity(0.3),
          const Color(0xFF87C48D).withOpacity(0.2),
          const Color(0xFFD1E7DD).withOpacity(0.1),
        ];
      case 'In-Progress':
        return [
          const Color(0xFF2D7A4F).withOpacity(0.3),
          const Color(0xFF5A9F6E).withOpacity(0.2),
          const Color(0xFF87C48D).withOpacity(0.1),
        ];
      default:
        return [
          Colors.grey.withOpacity(0.3),
          Colors.grey.withOpacity(0.2),
          Colors.grey.withOpacity(0.1),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(widget.request['status']);
    final gradientColors = _getGradientColors(widget.request['status']);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      onHover: (event) => setState(() => _mousePosition = event.localPosition),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_isHovered ? -0.05 : 0)
            ..rotateY(_isHovered ? (_mousePosition.dx - 100) * 0.0002 : 0)
            ..translate(0.0, _isHovered ? -15.0 : 0.0, _isHovered ? 20.0 : 0.0),
          child: SizedBox(
            width: 260,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow Effect
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(240, 260),
                      painter: TriangleGlowPainter(
                        glowIntensity: _isHovered ? 1.0 : _glowController.value,
                        color: statusColor,
                        isHovered: _isHovered,
                      ),
                    );
                  },
                ),
                // Triangle Shape
                CustomPaint(
                  size: const Size(240, 260),
                  painter: TrianglePainter(
                    gradientColors: gradientColors,
                    borderColor: statusColor,
                    isDark: isDark,
                  ),
                ),
                // Centered Content
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Request ID
                      Text(
                        widget.request['id'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Date
                      Text(
                        widget.request['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          widget.request['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Category
                      Text(
                        widget.request['category'],
                        style: TextStyle(
                          fontSize: 12,
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Text(
                        '₹${600 + (widget.request['id'].hashCode % 300)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor, statusColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final List<Color> gradientColors;
  final Color borderColor;
  final bool isDark;

  TrianglePainter({
    required this.gradientColors,
    required this.borderColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 20);
    path.lineTo(size.width - 20, size.height - 20);
    path.lineTo(20, size.height - 20);
    path.close();

    // Gradient fill
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Background
    final bgPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1A1A1A).withOpacity(0.8)
          : Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TriangleGlowPainter extends CustomPainter {
  final double glowIntensity;
  final Color color;
  final bool isHovered;

  TriangleGlowPainter({
    required this.glowIntensity,
    required this.color,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 20);
    path.lineTo(size.width - 20, size.height - 20);
    path.lineTo(20, size.height - 20);
    path.close();

    final glowPaint = Paint()
      ..color = color.withOpacity(isHovered ? 0.4 : glowIntensity * 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isHovered ? 20 : 15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHovered ? 8 : 5;

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant TriangleGlowPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity ||
      oldDelegate.isHovered != isHovered;
}
