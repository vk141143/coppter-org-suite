import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfessionalHeroAnimation extends StatefulWidget {
  const ProfessionalHeroAnimation({super.key});

  @override
  State<ProfessionalHeroAnimation> createState() => _ProfessionalHeroAnimationState();
}

class _ProfessionalHeroAnimationState extends State<ProfessionalHeroAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFAF7F2), Color(0xFFD1E7DD)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (t < 0.25) _buildCityLineAnimation(t / 0.25),
                if (t >= 0.2 && t < 0.5) _buildRouteVisualization((t - 0.2) / 0.3),
                if (t >= 0.45 && t < 0.7) _buildSystemBlocks((t - 0.45) / 0.25),
                if (t >= 0.65 && t < 0.85) _buildDashboardGraphs((t - 0.65) / 0.2),
                if (t >= 0.8) _buildBrandMoment((t - 0.8) / 0.2),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityLineAnimation(double progress) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CityLinePainter(progress),
      ),
    );
  }

  Widget _buildRouteVisualization(double progress) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RouteVisualizationPainter(progress),
      ),
    );
  }

  Widget _buildSystemBlocks(double progress) {
    final blocks = [
      {'label': 'Drivers', 'x': 0.15, 'delay': 0.0},
      {'label': 'Bins', 'x': 0.3, 'delay': 0.15},
      {'label': 'Routes', 'x': 0.45, 'delay': 0.3},
      {'label': 'Analytics', 'x': 0.6, 'delay': 0.45},
      {'label': 'Tasks', 'x': 0.75, 'delay': 0.6},
    ];

    return Stack(
      children: [
        CustomPaint(
          painter: _ConnectionLinesPainter(progress),
          size: Size.infinite,
        ),
        ...blocks.map((block) {
          final blockProgress = ((progress - (block['delay'] as double)) / 0.2).clamp(0.0, 1.0);
          return _buildBlock(
            block['label'] as String,
            block['x'] as double,
            blockProgress,
          );
        }),
      ],
    );
  }

  Widget _buildBlock(String label, double xPos, double progress) {
    return Positioned(
      left: MediaQuery.of(context).size.width * xPos - 40,
      top: MediaQuery.of(context).size.height * 0.5 - 30 + (1 - progress) * 50,
      child: Opacity(
        opacity: progress,
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF0F5132), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5132).withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIconForBlock(label), color: const Color(0xFF0F5132), size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForBlock(String label) {
    switch (label) {
      case 'Drivers': return Icons.local_shipping;
      case 'Bins': return Icons.delete_outline;
      case 'Routes': return Icons.route;
      case 'Analytics': return Icons.analytics;
      case 'Tasks': return Icons.task_alt;
      default: return Icons.circle;
    }
  }

  Widget _buildDashboardGraphs(double progress) {
    return Center(
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _DashboardGraphsPainter(progress),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandMoment(double progress) {
    return Center(
      child: Opacity(
        opacity: progress.clamp(0.0, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0F5132),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.eco, size: 60, color: Color(0xFF0F5132)),
            ),
            const SizedBox(height: 24),
            const Text(
              'LiftAway',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F5132),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Smart Waste Management. Simplified.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F1F1F).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CityLinePainter extends CustomPainter {
  final double progress;
  _CityLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F5132)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final buildings = [
      {'x': 0.1, 'h': 0.3},
      {'x': 0.2, 'h': 0.45},
      {'x': 0.3, 'h': 0.25},
      {'x': 0.45, 'h': 0.4},
      {'x': 0.6, 'h': 0.35},
      {'x': 0.75, 'h': 0.5},
      {'x': 0.85, 'h': 0.3},
    ];

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    for (var i = 0; i < buildings.length; i++) {
      final building = buildings[i];
      final x = size.width * (building['x'] as double);
      final h = size.height * (building['h'] as double);
      final baseY = size.height * 0.7;

      if (i / buildings.length <= progress) {
        path.lineTo(x - 20, baseY);
        path.lineTo(x - 20, baseY - h);
        path.lineTo(x + 20, baseY - h);
        path.lineTo(x + 20, baseY);
      }
    }

    path.lineTo(size.width, size.height * 0.7);
    canvas.drawPath(path, paint);

    if (progress > 0.5) {
      final iconPaint = Paint()
        ..color = const Color(0xFF0F5132)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < 3; i++) {
        final x = size.width * (0.25 + i * 0.25);
        final y = size.height * 0.7;
        canvas.drawCircle(Offset(x, y), 8, iconPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RouteVisualizationPainter extends CustomPainter {
  final double progress;
  _RouteVisualizationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0F5132)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF0F5132).withOpacity(0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final points = [
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.4),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      if (i / points.length <= progress) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    final binPaint = Paint()
      ..color = progress > 0.7 ? const Color(0xFFFF6F00) : const Color(0xFF0F5132)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      if (i / points.length <= progress) {
        canvas.drawCircle(points[i], 10, binPaint);
        
        if (progress > 0.7) {
          final ringPaint = Paint()
            ..color = const Color(0xFFFF6F00).withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(points[i], 15, ringPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConnectionLinesPainter extends CustomPainter {
  final double progress;
  _ConnectionLinesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.8) return;

    final paint = Paint()
      ..color = const Color(0xFF0F5132).withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final positions = [0.15, 0.3, 0.45, 0.6, 0.75];
    final y = size.height * 0.5;

    for (var i = 0; i < positions.length - 1; i++) {
      final start = Offset(size.width * positions[i], y);
      final end = Offset(size.width * positions[i + 1], y);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DashboardGraphsPainter extends CustomPainter {
  final double progress;
  _DashboardGraphsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = const Color(0xFF0F5132)
      ..style = PaintingStyle.fill;

    final bars = [0.4, 0.7, 0.5, 0.9, 0.6];
    final barWidth = size.width / (bars.length * 2);

    for (var i = 0; i < bars.length; i++) {
      final height = size.height * bars[i] * progress;
      final x = (i * 2 + 0.5) * barWidth;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - height, barWidth, height),
          const Radius.circular(4),
        ),
        barPaint,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFFFF6F00)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.7);
    
    for (var i = 0; i <= 10; i++) {
      final x = (i / 10) * size.width;
      final y = size.height * (0.7 - 0.3 * math.sin(i / 10 * math.pi * 2) * progress);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
