import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoginRightPanel extends StatefulWidget {
  const LoginRightPanel({super.key});

  @override
  State<LoginRightPanel> createState() => _LoginRightPanelState();
}

class _LoginRightPanelState extends State<LoginRightPanel> with TickerProviderStateMixin {
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [Color(0xFF1B5E20), Color(0xFF0F1419)]
              : [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return CustomPaint(
                painter: _EcoBlobPainter(_blobController.value),
                size: Size.infinite,
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, double value, child) {
                    return Transform.rotate(
                      angle: value * 2 * math.pi,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                      ],
                    ),
                    child: const Icon(Icons.eco, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Waste Management',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Building a cleaner, greener future',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EcoBlobPainter extends CustomPainter {
  final double animation;
  _EcoBlobPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final blob1 = Offset(
      size.width * 0.3 + math.sin(animation * 2 * math.pi) * 150,
      size.height * 0.2 + math.cos(animation * 2 * math.pi) * 100,
    );
    paint.color = const Color(0xFF76FF03).withOpacity(0.15);
    canvas.drawCircle(blob1, 250, paint);

    final blob2 = Offset(
      size.width * 0.7 + math.cos(animation * 2 * math.pi + 1.5) * 120,
      size.height * 0.7 + math.sin(animation * 2 * math.pi + 1.5) * 130,
    );
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(blob2, 300, paint);

    final blob3 = Offset(
      size.width * 0.5 + math.sin(animation * 2 * math.pi + 3) * 100,
      size.height * 0.5 + math.cos(animation * 2 * math.pi + 3) * 80,
    );
    paint.color = const Color(0xFF76FF03).withOpacity(0.08);
    canvas.drawCircle(blob3, 200, paint);
  }

  @override
  bool shouldRepaint(_EcoBlobPainter oldDelegate) => true;
}
