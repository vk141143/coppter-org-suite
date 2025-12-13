import 'package:flutter/material.dart';
import 'dart:math' as math;

class CinematicHeroAnimation extends StatefulWidget {
  const CinematicHeroAnimation({super.key});

  @override
  State<CinematicHeroAnimation> createState() => _CinematicHeroAnimationState();
}

class _CinematicHeroAnimationState extends State<CinematicHeroAnimation> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final progress = _mainController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(progress),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildCityscape(progress),
                _buildParticleSystem(progress),
                _buildHolographicElements(progress),
                _buildDroneMovement(progress),
                _buildHumanMoment(progress),
                _buildBrandReveal(progress),
                _buildTextOverlays(progress),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getBackgroundGradient(double progress) {
    if (progress < 0.2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1F1F1F),
          const Color(0xFF2A2A2A),
        ],
      );
    } else if (progress < 0.5) {
      final t = (progress - 0.2) / 0.3;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF1F1F1F), const Color(0xFF0F5132), t)!,
          Color.lerp(const Color(0xFF2A2A2A), const Color(0xFFD1E7DD), t)!,
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F5132), Color(0xFFD1E7DD), Color(0xFFFAF7F2)],
      );
    }
  }

  Widget _buildCityscape(double progress) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CityscapePainter(progress),
      ),
    );
  }

  Widget _buildParticleSystem(double progress) {
    if (progress > 0.8) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(30, (i) {
            final angle = (i / 30) * 2 * math.pi;
            final distance = 50 + (_particleController.value * 200);
            final x = 0.5 + math.cos(angle + progress * 2 * math.pi) * distance / 400;
            final y = 0.3 + math.sin(angle + progress * 2 * math.pi) * distance / 400;
            final opacity = progress < 0.3 ? (progress / 0.3) * (1 - _particleController.value) : 0.0;
            
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD1E7DD),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD1E7DD).withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHolographicElements(double progress) {
    if (progress < 0.25 || progress > 0.75) return const SizedBox.shrink();
    
    final opacity = progress < 0.35 ? (progress - 0.25) / 0.1 : progress > 0.65 ? 1 - (progress - 0.65) / 0.1 : 1.0;
    
    return Positioned.fill(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: CustomPaint(
          painter: _HolographicPainter(progress, _particleController.value),
        ),
      ),
    );
  }

  Widget _buildDroneMovement(double progress) {
    if (progress < 0.3 || progress > 0.65) return const SizedBox.shrink();
    
    final t = (progress - 0.3) / 0.35;
    final opacity = t < 0.1 ? t / 0.1 : t > 0.9 ? 1 - (t - 0.9) / 0.1 : 1.0;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * (0.1 + t * 0.8),
          top: MediaQuery.of(context).size.height * (0.4 + math.sin(t * math.pi) * 0.1),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 60 + _pulseController.value * 10,
              height: 60 + _pulseController.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F5132).withOpacity(0.8),
                    const Color(0xFF0F5132).withOpacity(0.2),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.6),
                    blurRadius: 20 + _pulseController.value * 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.eco, size: 30, color: Colors.white.withOpacity(0.9)),
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: _DroneTrailPainter(t),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHumanMoment(double progress) {
    if (progress < 0.5 || progress > 0.75) return const SizedBox.shrink();
    
    final opacity = progress < 0.55 ? (progress - 0.5) / 0.05 : progress > 0.7 ? 1 - (progress - 0.7) / 0.05 : 1.0;
    
    return Positioned(
      right: 40,
      bottom: 100,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1F1F1F).withOpacity(0.6),
                const Color(0xFF1F1F1F).withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F5132),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5132).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandReveal(double progress) {
    if (progress < 0.7) return const SizedBox.shrink();
    
    final t = (progress - 0.7) / 0.3;
    final scale = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
    
    return Center(
      child: Transform.scale(
        scale: scale,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F5132),
                    const Color(0xFF2D7A4F),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.4 + _pulseController.value * 0.2),
                    blurRadius: 40 + _pulseController.value * 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(150, 150),
                    painter: _HolographicRingsPainter(_particleController.value),
                  ),
                  const Icon(Icons.eco, size: 70, color: Colors.white),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextOverlays(double progress) {
    return Stack(
      children: [
        if (progress < 0.25) _buildText('Every City Deserves\na Second Chance', progress / 0.25, Alignment.center),
        if (progress >= 0.5 && progress < 0.7) _buildText('Technology that brings\nhope back', (progress - 0.5) / 0.2, Alignment.center),
        if (progress >= 0.75) _buildText('LiftAway\nTurning Waste Into\nIntelligent Clean Cities', (progress - 0.75) / 0.25, Alignment.bottomCenter, isTagline: true),
      ],
    );
  }

  Widget _buildText(String text, double opacity, Alignment alignment, {bool isTagline = false}) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(bottom: isTagline ? 40 : 0),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: isTagline ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (isTagline) ...[
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFF0F5132), const Color(0xFF2D7A4F), _pulseController.value)!,
                            const Color(0xFF0F5132),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F5132).withOpacity(0.4 + _pulseController.value * 0.3),
                            blurRadius: 15 + _pulseController.value * 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class _CityscapePainter extends CustomPainter {
  final double progress;
  _CityscapePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final buildings = [
      {'x': 0.1, 'h': 0.4},
      {'x': 0.25, 'h': 0.6},
      {'x': 0.4, 'h': 0.35},
      {'x': 0.55, 'h': 0.55},
      {'x': 0.7, 'h': 0.45},
      {'x': 0.85, 'h': 0.5},
    ];

    for (var building in buildings) {
      final x = size.width * (building['x'] as double);
      final h = size.height * (building['h'] as double);
      
      final color = progress < 0.3
          ? const Color(0xFF2A2A2A)
          : Color.lerp(
              const Color(0xFF2A2A2A),
              const Color(0xFF0F5132),
              ((progress - 0.3) / 0.3).clamp(0.0, 1.0),
            )!;

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.6), color],
        ).createShader(Rect.fromLTWH(x, size.height - h, 60, h));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, 60, h),
          const Radius.circular(4),
        ),
        paint,
      );

      if (progress > 0.3) {
        final glowPaint = Paint()
          ..color = const Color(0xFF0F5132).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, 60, h),
            const Radius.circular(4),
          ),
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HolographicPainter extends CustomPainter {
  final double progress;
  final double animation;
  _HolographicPainter(this.progress, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFD1E7DD).withOpacity(0.6);

    for (var i = 0; i < 3; i++) {
      final radius = 30.0 + i * 40 + animation * 20;
      canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.5),
        radius,
        paint,
      );
    }

    final iconPaint = Paint()
      ..color = const Color(0xFF0F5132).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final icons = [
      {'x': 0.2, 'y': 0.3},
      {'x': 0.5, 'y': 0.4},
      {'x': 0.7, 'y': 0.5},
    ];

    for (var icon in icons) {
      final x = size.width * (icon['x'] as double);
      final y = size.height * (icon['y'] as double);
      canvas.drawCircle(Offset(x, y), 20, iconPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DroneTrailPainter extends CustomPainter {
  final double progress;
  _DroneTrailPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1E7DD).withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < 10; i++) {
      final t = i / 10;
      final x = -30.0 * t;
      final y = math.sin(t * math.pi * 2) * 5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HolographicRingsPainter extends CustomPainter {
  final double animation;
  _HolographicRingsPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 3; i++) {
      final radius = 60.0 + i * 15 + animation * 10;
      paint.color = const Color(0xFFD1E7DD).withOpacity(0.3 - i * 0.1);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
