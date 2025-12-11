import 'package:flutter/material.dart';
import 'dart:math' as math;

class PremiumLoadingAnimations extends StatefulWidget {
  final VoidCallback? onComplete;

  const PremiumLoadingAnimations({Key? key, this.onComplete}) : super(key: key);

  @override
  State<PremiumLoadingAnimations> createState() => _PremiumLoadingAnimationsState();
}

class _PremiumLoadingAnimationsState extends State<PremiumLoadingAnimations> with TickerProviderStateMixin {
  int _currentAnimation = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    for (int i = 0; i < 3; i++) {
      setState(() => _currentAnimation = i);
      _controller.reset();
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 2500));
    }
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildCurrentAnimation(),
        ),
      ),
    );
  }

  Widget _buildCurrentAnimation() {
    switch (_currentAnimation) {
      case 0:
        return _BinOpeningAnimation(key: const ValueKey(0), controller: _controller);
      case 1:
        return _RadarScannerAnimation(key: const ValueKey(1), controller: _controller);
      case 2:
        return _CleanSweepAnimation(key: const ValueKey(2), controller: _controller);
      default:
        return const SizedBox();
    }
  }
}

// Animation A: Bin Opening + Leaf Particles
class _BinOpeningAnimation extends StatelessWidget {
  final AnimationController controller;

  const _BinOpeningAnimation({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Floating leaves
              for (int i = 0; i < 5; i++)
                _buildLeaf(i, controller.value),
              
              // Bin
              CustomPaint(
                size: const Size(80, 80),
                painter: _BinPainter(controller.value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaf(int index, double progress) {
    final offset = (index * 0.2);
    final y = -60 * ((progress + offset) % 1.0);
    final x = 15 * math.sin((progress + offset) * math.pi * 2);
    final opacity = 1 - ((progress + offset) % 1.0);
    
    return Positioned(
      left: 40 + x,
      top: 60 + y,
      child: Opacity(
        opacity: opacity,
        child: const Text('🍃', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _BinPainter extends CustomPainter {
  final double animation;

  _BinPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final binPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.7, size.width * 0.7, 8),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Bin body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.4, size.width * 0.6, size.height * 0.4),
        const Radius.circular(8),
      ),
      binPaint,
    );

    // Lid (opens/closes)
    final lidOpen = math.sin(animation * math.pi * 4).abs();
    canvas.save();
    canvas.translate(size.width * 0.2, size.height * 0.4);
    canvas.rotate(-lidOpen * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -10, size.width * 0.6, 12),
        const Radius.circular(6),
      ),
      binPaint..color = const Color(0xFF4CAF50),
    );
    canvas.restore();

    // Recycling symbol
    final textPainter = TextPainter(
      text: const TextSpan(text: '♻️', style: TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.35, size.height * 0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animation B: Neon Radar Scanner
class _RadarScannerAnimation extends StatelessWidget {
  final AnimationController controller;

  const _RadarScannerAnimation({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: _RadarPainter(controller.value),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: const Text(
                  'Scanning your area...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double animation;

  _RadarPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Outer rings
    for (int i = 0; i < 3; i++) {
      final radius = (size.width / 2) * (0.4 + (i * 0.2));
      final paint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.2)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, paint);
    }

    // Rotating scan line
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * math.pi * 2);
    
    final gradient = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E676).withOpacity(0.8),
          const Color(0xFF00E676).withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
      -math.pi / 6,
      math.pi / 3,
      true,
      gradient,
    );
    canvas.restore();

    // Random dots
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + (animation * math.pi * 2);
      final distance = (size.width / 2) * (0.3 + ((i % 3) * 0.2));
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      final dotPaint = Paint()
        ..color = const Color(0xFF00E676)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Animation C: Clean Sweep Transition
class _CleanSweepAnimation extends StatelessWidget {
  final AnimationController controller;

  const _CleanSweepAnimation({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Dust particles
              for (int i = 0; i < 8; i++)
                _buildDustParticle(i, controller.value),
              
              // Sweep effect
              CustomPaint(
                size: const Size(150, 150),
                painter: _SweepPainter(controller.value),
              ),
              
              // Clean card fade in
              if (controller.value > 0.6)
                Center(
                  child: Opacity(
                    opacity: (controller.value - 0.6) / 0.4,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF4CAF50),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDustParticle(int index, double progress) {
    final x = (index * 20.0) - 80;
    final fadeOut = progress > (index * 0.1) ? 1 - ((progress - (index * 0.1)) / 0.3) : 1.0;
    
    if (fadeOut <= 0) return const SizedBox();
    
    return Positioned(
      left: 75 + x,
      top: 60 + (index % 3) * 15.0,
      child: Opacity(
        opacity: fadeOut.clamp(0.0, 1.0),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  final double animation;

  _SweepPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final sweepX = size.width * animation;
    
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF4CAF50).withOpacity(0),
          const Color(0xFF4CAF50).withOpacity(0.3),
          const Color(0xFF4CAF50).withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(sweepX - 30, 0, 60, size.height));
    
    canvas.drawRect(
      Rect.fromLTWH(sweepX - 30, 0, 60, size.height),
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
