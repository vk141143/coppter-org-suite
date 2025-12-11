import 'package:flutter/material.dart';
import 'dart:math' as math;

class TruckLoadingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const TruckLoadingScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  State<TruckLoadingScreen> createState() => _TruckLoadingScreenState();
}

class _TruckLoadingScreenState extends State<TruckLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _truckController;
  late AnimationController _floatingController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1,
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _fadeController.reverse().then((_) {
          widget.onComplete?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _truckController.dispose();
    _floatingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE8F5E9),
              const Color(0xFFC8E6C9),
              const Color(0xFFA5D6A7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating Icons
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildFloatingIcon('♻️', 0.2, 0.7, 0),
                    _buildFloatingIcon('🍃', 0.7, 0.6, 1),
                    _buildFloatingIcon('🗑️', 0.5, 0.8, 2),
                    _buildFloatingIcon('☁️', 0.3, 0.3, 1.5),
                    _buildFloatingIcon('☁️', 0.8, 0.2, 2.5),
                  ],
                );
              },
            ),
            
            // Road and Truck
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  
                  // Truck Animation
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        // Road
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: const Size(double.infinity, 60),
                            painter: _RoadPainter(_truckController.value),
                          ),
                        ),
                        
                        // Truck
                        AnimatedBuilder(
                          animation: _truckController,
                          builder: (context, child) {
                            final progress = _truckController.value;
                            final xPos = progress * MediaQuery.of(context).size.width;
                            final bounce = math.sin(progress * math.pi * 8) * 3;
                            
                            return Positioned(
                              left: xPos - 40,
                              bottom: 45 + bounce,
                              child: CustomPaint(
                                size: const Size(80, 60),
                                painter: _TruckPainter(progress),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading Text
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                            letterSpacing: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon(String emoji, double xFactor, double yStart, double offset) {
    final progress = (_floatingController.value + offset) % 1.0;
    final y = yStart - (progress * 0.4);
    final x = xFactor + (math.sin(progress * math.pi * 2) * 0.05);
    final opacity = 1 - progress;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * x,
      top: MediaQuery.of(context).size.height * y,
      child: Opacity(
        opacity: opacity,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final double animation;

  _RoadPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Road base
    final roadPaint = Paint()
      ..color = const Color(0xFF616161)
      ..style = PaintingStyle.fill;

    final roadPath = Path();
    roadPath.moveTo(0, size.height * 0.5);
    
    for (var i = 0; i <= size.width; i += 10) {
      final wave = math.sin((i / size.width) * math.pi * 2) * 5;
      roadPath.lineTo(i.toDouble(), size.height * 0.5 + wave);
    }
    
    roadPath.lineTo(size.width, size.height);
    roadPath.lineTo(0, size.height);
    roadPath.close();
    
    canvas.drawPath(roadPath, roadPaint);

    // Road markings
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dashOffset = (animation * 60) % 60;
    
    for (var i = -dashOffset; i < size.width; i += 60) {
      canvas.drawLine(
        Offset(i, size.height * 0.5),
        Offset(i + 30, size.height * 0.5),
        dashPaint,
      );
    }

    // Road glow
    final glowPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawPath(roadPath, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TruckPainter extends CustomPainter {
  final double animation;

  _TruckPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Neon glow
    final glowPaint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        const Radius.circular(8),
      ),
      glowPaint,
    );

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawOval(
      Rect.fromLTWH(15, size.height - 5, size.width - 30, 8),
      shadowPaint,
    );

    // Truck body
    final bodyPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    // Cabin
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 20, 25, 25),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Container
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(35, 15, 30, 30),
        const Radius.circular(4),
      ),
      bodyPaint,
    );

    // Windows
    final windowPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 23, 8, 8),
        const Radius.circular(2),
      ),
      windowPaint,
    );

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF212121)
      ..style = PaintingStyle.fill;

    final wheelRotation = animation * math.pi * 8;
    
    // Front wheel
    canvas.save();
    canvas.translate(28, size.height - 12);
    canvas.rotate(wheelRotation);
    canvas.drawCircle(Offset.zero, 6, wheelPaint);
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFF616161));
    canvas.restore();

    // Back wheel
    canvas.save();
    canvas.translate(55, size.height - 12);
    canvas.rotate(wheelRotation);
    canvas.drawCircle(Offset.zero, 6, wheelPaint);
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFF616161));
    canvas.restore();

    // Neon outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(15, 15, 50, 30),
        const Radius.circular(4),
      ),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
