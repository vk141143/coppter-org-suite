import 'package:flutter/material.dart';
import 'dart:math' as math;

class EmotionalHeroAnimation extends StatefulWidget {
  const EmotionalHeroAnimation({super.key});

  @override
  State<EmotionalHeroAnimation> createState() => _EmotionalHeroAnimationState();
}

class _EmotionalHeroAnimationState extends State<EmotionalHeroAnimation> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _breathController;
  late AnimationController _hopeController;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _breathController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _hopeController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final t = _mainController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: _getSceneGradient(t),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                _buildCityscape(t),
                _buildHopeWave(t),
                _buildHumanFigures(t),
                _buildCommunityScenes(t),
                _buildHolographicUI(t),
                _buildHopeParticles(t),
                _buildTextNarrative(t),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getSceneGradient(double t) {
    if (t < 0.15) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF4A4A4A), const Color(0xFF2A2A2A)],
      );
    } else if (t < 0.4) {
      final progress = (t - 0.15) / 0.25;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF4A4A4A), const Color(0xFFD1E7DD), progress)!,
          Color.lerp(const Color(0xFF2A2A2A), const Color(0xFF0F5132), progress)!,
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD1E7DD), Color(0xFF0F5132), Color(0xFFFAF7F2)],
      );
    }
  }

  Widget _buildCityscape(double t) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CityscapePainter(t, _breathController.value),
      ),
    );
  }

  Widget _buildHopeWave(double t) {
    if (t < 0.15 || t > 0.45) return const SizedBox.shrink();
    
    final waveProgress = (t - 0.15) / 0.3;
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: _HopeWavePainter(waveProgress, _breathController.value),
          ),
        );
      },
    );
  }

  Widget _buildHumanFigures(double t) {
    return Stack(
      children: [
        if (t < 0.2 || t > 0.85) _buildBalconyScene(t),
        if (t >= 0.7 && t < 0.85) _buildDiversePeople(t),
      ],
    );
  }

  Widget _buildBalconyScene(double t) {
    final opacity = t < 0.2 ? 1.0 : t > 0.85 ? (t - 0.85) / 0.15 : 0.0;
    final childSmile = t > 0.2 && t < 0.3 ? (t - 0.2) / 0.1 : 0.0;
    
    return Positioned(
      right: 60,
      top: 120,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1F1F1F).withOpacity(0.3),
                const Color(0xFF1F1F1F).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPerson(40, const Color(0xFFD1E7DD)),
                  const SizedBox(width: 8),
                  _buildPerson(25, const Color(0xFFFAF7F2), isChild: true, smile: childSmile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerson(double size, Color color, {bool isChild = false, double smile = 0.0}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: isChild && smile > 0
              ? Center(
                  child: Container(
                    width: size * 0.6,
                    height: size * 0.3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5132).withOpacity(smile),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Container(
          width: size * 0.8,
          height: size * 1.2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityScenes(double t) {
    if (t < 0.3 || t > 0.65) return const SizedBox.shrink();
    
    final sceneProgress = (t - 0.3) / 0.35;
    final scene1 = sceneProgress < 0.33 ? sceneProgress / 0.33 : sceneProgress < 0.66 ? 1.0 : 1 - (sceneProgress - 0.66) / 0.34;
    final scene2 = sceneProgress < 0.33 ? 0.0 : sceneProgress < 0.66 ? (sceneProgress - 0.33) / 0.33 : 1 - (sceneProgress - 0.66) / 0.34;
    
    return Stack(
      children: [
        if (scene1 > 0) _buildWorkerScene(scene1),
        if (scene2 > 0) _buildElderlyScene(scene2),
      ],
    );
  }

  Widget _buildWorkerScene(double opacity) {
    return Positioned(
      left: 40,
      bottom: 150,
      child: Opacity(
        opacity: opacity,
        child: Row(
          children: [
            _buildPerson(35, const Color(0xFFFF6F00)),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _hopeController,
              builder: (context, child) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132).withOpacity(0.2 + _hopeController.value * 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0F5132), width: 2),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFF0F5132), size: 30),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderlyScene(double opacity) {
    return Positioned(
      right: 50,
      bottom: 180,
      child: Opacity(
        opacity: opacity,
        child: Row(
          children: [
            _buildPerson(32, const Color(0xFFD1E7DD)),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color(0xFF0F5132),
                      const Color(0xFFD1E7DD),
                      _breathController.value,
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F5132).withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolographicUI(double t) {
    if (t < 0.4 || t > 0.75) return const SizedBox.shrink();
    
    final opacity = t < 0.45 ? (t - 0.4) / 0.05 : t > 0.7 ? 1 - (t - 0.7) / 0.05 : 1.0;
    
    return AnimatedBuilder(
      animation: _hopeController,
      builder: (context, child) {
        return Positioned.fill(
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: CustomPaint(
              painter: _HolographicUIPainter(_hopeController.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiversePeople(double t) {
    final opacity = (t - 0.7) / 0.1;
    
    return Center(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: AnimatedBuilder(
          animation: _breathController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0F5132).withOpacity(0.3),
                    const Color(0xFF0F5132).withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.3 + _breathController.value * 0.2),
                    blurRadius: 40 + _breathController.value * 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPersonInCircle(0, 4, const Color(0xFFFF6F00)),
                  _buildPersonInCircle(1, 4, const Color(0xFFD1E7DD)),
                  _buildPersonInCircle(2, 4, const Color(0xFFFAF7F2)),
                  _buildPersonInCircle(3, 4, const Color(0xFF0F5132)),
                  const Icon(Icons.eco, size: 50, color: Color(0xFF0F5132)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonInCircle(int index, int total, Color color) {
    final angle = (index / total) * 2 * math.pi - math.pi / 2;
    final radius = 70.0;
    
    return Transform.translate(
      offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  Widget _buildHopeParticles(double t) {
    if (t < 0.15) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _hopeController,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (i) {
            final angle = (i / 20) * 2 * math.pi;
            final distance = 100 + (_hopeController.value * 150);
            final x = 0.5 + math.cos(angle + t * math.pi) * distance / MediaQuery.of(context).size.width;
            final y = 0.5 + math.sin(angle + t * math.pi) * distance / MediaQuery.of(context).size.height;
            final opacity = (1 - _hopeController.value) * 0.6;
            
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
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

  Widget _buildTextNarrative(double t) {
    return Stack(
      children: [
        if (t < 0.15) _buildNarrativeText('Every day, millions breathe\nair they shouldn\'t have to.', t / 0.15, Alignment.center),
        if (t >= 0.5 && t < 0.7) _buildNarrativeText('Because technology should\nclean the world…\nnot complicate it.', (t - 0.5) / 0.2, Alignment.center),
        if (t >= 0.75) _buildNarrativeText('LiftAway\nClean Cities.\nConnected Communities.', (t - 0.75) / 0.15, Alignment.bottomCenter, isFinal: true),
      ],
    );
  }

  Widget _buildNarrativeText(String text, double opacity, Alignment alignment, {bool isFinal = false}) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(bottom: isFinal ? 50 : 0),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isFinal ? 22 : 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.4,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _breathController.dispose();
    _hopeController.dispose();
    super.dispose();
  }
}

class _CityscapePainter extends CustomPainter {
  final double progress;
  final double breathe;
  _CityscapePainter(this.progress, this.breathe);

  @override
  void paint(Canvas canvas, Size size) {
    final buildings = [
      {'x': 0.05, 'h': 0.3},
      {'x': 0.2, 'h': 0.5},
      {'x': 0.35, 'h': 0.25},
      {'x': 0.5, 'h': 0.45},
      {'x': 0.65, 'h': 0.35},
      {'x': 0.8, 'h': 0.4},
      {'x': 0.92, 'h': 0.3},
    ];

    for (var building in buildings) {
      final x = size.width * (building['x'] as double);
      final h = size.height * (building['h'] as double);
      
      final baseColor = progress < 0.2
          ? const Color(0xFF3A3A3A)
          : Color.lerp(
              const Color(0xFF3A3A3A),
              const Color(0xFF0F5132),
              ((progress - 0.2) / 0.3).clamp(0.0, 1.0),
            )!;

      final glowIntensity = progress > 0.4 ? breathe * 0.3 : 0.0;
      
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            baseColor.withOpacity(0.7 + glowIntensity),
            baseColor,
          ],
        ).createShader(Rect.fromLTWH(x, size.height - h, 50, h));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h, 50, h),
          const Radius.circular(4),
        ),
        paint,
      );

      if (progress > 0.4) {
        final windowPaint = Paint()..color = const Color(0xFFFAF7F2).withOpacity(0.6 + breathe * 0.2);
        for (var i = 0; i < 3; i++) {
          for (var j = 0; j < (h / 30).floor(); j++) {
            canvas.drawRect(
              Rect.fromLTWH(x + 10 + i * 12, size.height - h + 10 + j * 25, 8, 15),
              windowPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HopeWavePainter extends CustomPainter {
  final double progress;
  final double pulse;
  _HopeWavePainter(this.progress, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0F5132).withOpacity(0.6),
          const Color(0xFFD1E7DD).withOpacity(0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 + pulse * 10);

    final waveX = size.width * progress;
    final waveWidth = size.width * 0.3;
    
    canvas.drawOval(
      Rect.fromLTWH(waveX - waveWidth / 2, 0, waveWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HolographicUIPainter extends CustomPainter {
  final double animation;
  _HolographicUIPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFD1E7DD).withOpacity(0.5);

    final positions = [
      {'x': 0.2, 'y': 0.3},
      {'x': 0.5, 'y': 0.5},
      {'x': 0.75, 'y': 0.4},
    ];

    for (var i = 0; i < positions.length; i++) {
      final pos = positions[i];
      final center = Offset(size.width * (pos['x'] as double), size.height * (pos['y'] as double));
      
      for (var j = 0; j < 2; j++) {
        final radius = 20.0 + j * 15 + animation * 8;
        canvas.drawCircle(center, radius, paint);
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF0F5132).withOpacity(0.3)
      ..strokeWidth = 2;
    
    for (var i = 0; i < positions.length - 1; i++) {
      final start = Offset(
        size.width * (positions[i]['x'] as double),
        size.height * (positions[i]['y'] as double),
      );
      final end = Offset(
        size.width * (positions[i + 1]['x'] as double),
        size.height * (positions[i + 1]['y'] as double),
      );
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
