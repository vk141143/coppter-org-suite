import 'package:flutter/material.dart';
import 'dart:math' as math;

class WasteProcessAnimationWidget extends StatefulWidget {
  const WasteProcessAnimationWidget({super.key});

  @override
  State<WasteProcessAnimationWidget> createState() => _WasteProcessAnimationWidgetState();
}

class _WasteProcessAnimationWidgetState extends State<WasteProcessAnimationWidget> with TickerProviderStateMixin {
  int _currentScene = 0;
  late List<AnimationController> _controllers;
  bool _autoPlay = true;

  final List<Map<String, String>> _scenes = [
    {'title': 'Open App', 'description': 'Launch waste management app'},
    {'title': 'Take Photo', 'description': 'Capture waste image'},
    {'title': 'AI Pricing', 'description': 'Get instant estimate'},
    {'title': 'Assign Driver', 'description': 'Driver on the way'},
    {'title': 'Track Pickup', 'description': 'Real-time tracking'},
    {'title': 'Complete', 'description': 'Pickup successful'},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      6,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + index * 200),
      )..repeat(),
    );
    if (_autoPlay) _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _autoPlay) {
        setState(() => _currentScene = (_currentScene + 1) % 6);
        _startAutoPlay();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.05),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'How It Works',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _autoPlay = !_autoPlay),
                    icon: Icon(_autoPlay ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _currentScene = (_currentScene - 1) % 6),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _currentScene = (_currentScene + 1) % 6),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _buildScene(_currentScene),
            ),
          ),
          const SizedBox(height: 24),
          _buildSceneIndicators(),
          const SizedBox(height: 16),
          Text(
            _scenes[_currentScene]['title']!,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _scenes[_currentScene]['description']!,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScene(int index) {
    return Container(
      key: ValueKey(index),
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          switch (index) {
            case 0:
              return _Scene1OpenApp(_controllers[0].value);
            case 1:
              return _Scene2TakePhoto(_controllers[1].value);
            case 2:
              return _Scene3AIPricing(_controllers[2].value);
            case 3:
              return _Scene4AssignDriver(_controllers[3].value);
            case 4:
              return _Scene5Tracking(_controllers[4].value);
            case 5:
              return _Scene6Complete(_controllers[5].value);
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  Widget _buildSceneIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return GestureDetector(
          onTap: () => setState(() => _currentScene = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentScene == index ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentScene == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

// Scene 1: Open App
class _Scene1OpenApp extends StatelessWidget {
  final double progress;
  const _Scene1OpenApp(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OpenAppPainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _OpenAppPainter extends CustomPainter {
  final double progress;
  _OpenAppPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Phone
    final phonePaint = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 3;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: 180, height: 320),
      const Radius.circular(20),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    // Screen
    final screenPaint = Paint()..color = Colors.white;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: 160, height: 280),
      const Radius.circular(15),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // App icon
    final iconSize = 60.0 + (math.sin(progress * 2 * math.pi) * 5);
    final iconPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.green, Colors.blue],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: iconSize / 2));
    canvas.drawCircle(Offset(centerX, centerY), iconSize / 2, iconPaint);

    // Tap finger
    if (progress > 0.3 && progress < 0.7) {
      final fingerPaint = Paint()..color = Colors.orange.withOpacity(0.8);
      canvas.drawCircle(Offset(centerX + 40, centerY - 60), 15, fingerPaint);
    }

    // Glow particles
    if (progress > 0.5) {
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final distance = 50 * (progress - 0.5) * 2;
        final x = centerX + math.cos(angle) * distance;
        final y = centerY + math.sin(angle) * distance;
        final particlePaint = Paint()..color = Colors.greenAccent.withOpacity(1 - (progress - 0.5) * 2);
        canvas.drawCircle(Offset(x, y), 4, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scene 2: Take Photo
class _Scene2TakePhoto extends StatelessWidget {
  final double progress;
  const _Scene2TakePhoto(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TakePhotoPainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _TakePhotoPainter extends CustomPainter {
  final double progress;
  _TakePhotoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // User character
    final userPaint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(centerX - 100, centerY), 30, userPaint);
    canvas.drawLine(
      Offset(centerX - 100, centerY + 30),
      Offset(centerX - 100, centerY + 80),
      userPaint..strokeWidth = 8,
    );

    // Waste pile
    final wastePaint = Paint()..color = Colors.brown.withOpacity(0.7);
    canvas.drawCircle(Offset(centerX + 80, centerY + 50), 40, wastePaint);

    // Phone camera
    final phonePaint = Paint()..color = Colors.black87;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX - 70, centerY - 40), width: 60, height: 100),
        const Radius.circular(8),
      ),
      phonePaint,
    );

    // Camera flash
    if (progress > 0.4 && progress < 0.6) {
      final flashPaint = Paint()..color = Colors.yellow.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(centerX, centerY), 100, flashPaint);
    }

    // Photo upload animation
    if (progress > 0.6) {
      final photoProgress = (progress - 0.6) / 0.4;
      final photoY = centerY + 50 - (photoProgress * 100);
      final photoPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(centerX + 80, photoY), width: 60, height: 80),
        photoPaint,
      );

      // AI scanner rings
      for (int i = 0; i < 3; i++) {
        final ringProgress = (photoProgress + i * 0.3) % 1.0;
        final ringPaint = Paint()
          ..color = Colors.cyan.withOpacity(1 - ringProgress)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(
          Offset(centerX + 80, photoY),
          40 * ringProgress,
          ringPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scene 3: AI Pricing
class _Scene3AIPricing extends StatelessWidget {
  final double progress;
  const _Scene3AIPricing(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AIPricingPainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _AIPricingPainter extends CustomPainter {
  final double progress;
  _AIPricingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Hologram calculator
    final calcPaint = Paint()..color = Colors.cyan.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY - 50), width: 120, height: 160),
        const Radius.circular(12),
      ),
      calcPaint,
    );

    // Floating coins
    for (int i = 0; i < 6; i++) {
      final coinProgress = (progress + i * 0.15) % 1.0;
      final x = centerX - 60 + i * 25;
      final y = centerY + 80 - (coinProgress * 120);
      final rotation = coinProgress * math.pi * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final coinPaint = Paint()..color = Colors.amber.withOpacity(1 - coinProgress);
      canvas.drawCircle(Offset.zero, 12, coinPaint);
      canvas.drawCircle(Offset.zero, 8, Paint()..color = Colors.white.withOpacity(0.5));

      canvas.restore();
    }

    // Price display with pulse
    final pulseFactor = 1.0 + (math.sin(progress * 4 * math.pi) * 0.1);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '₹285',
        style: TextStyle(
          fontSize: 48 * pulseFactor,
          fontWeight: FontWeight.w900,
          color: Colors.green,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY - 20));

    // Negotiation slider
    final sliderY = centerY + 60;
    final sliderPaint = Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 4;
    canvas.drawLine(Offset(centerX - 80, sliderY), Offset(centerX + 80, sliderY), sliderPaint);

    final sliderPos = centerX - 80 + (160 * (0.5 + math.sin(progress * 2 * math.pi) * 0.3));
    final thumbPaint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(sliderPos, sliderY), 12, thumbPaint);

    // Tick mark when accepted
    if (progress > 0.7) {
      final tickPaint = Paint()..color = Colors.green..strokeWidth = 4..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(centerX + 100, centerY - 80), Offset(centerX + 120, centerY - 60), tickPaint);
      canvas.drawLine(Offset(centerX + 120, centerY - 60), Offset(centerX + 140, centerY - 100), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scene 4: Assign Driver
class _Scene4AssignDriver extends StatelessWidget {
  final double progress;
  const _Scene4AssignDriver(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AssignDriverPainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _AssignDriverPainter extends CustomPainter {
  final double progress;
  _AssignDriverPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Map background
    final mapPaint = Paint()..color = Colors.grey.withOpacity(0.2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), mapPaint);

    // Grid lines
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.1)..strokeWidth = 1;
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(Offset(i * size.width / 10, 0), Offset(i * size.width / 10, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * size.height / 10), Offset(size.width, i * size.height / 10), gridPaint);
    }

    // Customer location pin
    final pinPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(centerX + 100, centerY + 50), 15, pinPaint);
    canvas.drawPath(
      Path()
        ..moveTo(centerX + 100, centerY + 65)
        ..lineTo(centerX + 100, centerY + 85),
      pinPaint..strokeWidth = 3,
    );

    // Driver avatar popup
    if (progress > 0.3) {
      final avatarPaint = Paint()..color = Colors.blue;
      canvas.drawCircle(Offset(centerX - 100, centerY - 80), 30, avatarPaint);

      // Wave animation
      if (progress > 0.5) {
        final waveAngle = math.sin(progress * 8 * math.pi) * 0.5;
        canvas.save();
        canvas.translate(centerX - 70, centerY - 80);
        canvas.rotate(waveAngle);
        canvas.drawLine(Offset.zero, const Offset(20, -15), Paint()..color = Colors.blue..strokeWidth = 4);
        canvas.restore();
      }

      // Name badge
      final textPainter = TextPainter(
        text: const TextSpan(text: 'Mike', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX - 120, centerY - 40));
    }

    // Route line drawing
    if (progress > 0.4) {
      final routeProgress = (progress - 0.4) / 0.6;
      final routePaint = Paint()..color = Colors.blue..strokeWidth = 3..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(centerX - 100, centerY - 50);
      path.quadraticBezierTo(
        centerX,
        centerY - routeProgress * 50,
        centerX + 100 * routeProgress,
        centerY + 50 * routeProgress,
      );
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scene 5: Tracking
class _Scene5Tracking extends StatelessWidget {
  final double progress;
  const _Scene5Tracking(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrackingPainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _TrackingPainter extends CustomPainter {
  final double progress;
  _TrackingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width * 0.2;
    final endX = size.width * 0.8;
    final truckX = startX + ((endX - startX) * progress);
    final truckY = size.height / 2;

    // Road
    final roadPaint = Paint()..color = Colors.grey.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, truckY + 20, size.width, 40), roadPaint);

    // Dashed center line
    final dashPaint = Paint()..color = Colors.white..strokeWidth = 2;
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, truckY + 40), Offset(i + 10, truckY + 40), dashPaint);
    }

    // Truck
    final truckPaint = Paint()..color = Colors.green;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(truckX, truckY), width: 60, height: 35),
        const Radius.circular(6),
      ),
      truckPaint,
    );

    // Truck wiggle
    final wiggle = math.sin(progress * 20 * math.pi) * 2;
    canvas.save();
    canvas.translate(0, wiggle);

    // Wheels
    final wheelPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(truckX - 15, truckY + 20), 8, wheelPaint);
    canvas.drawCircle(Offset(truckX + 15, truckY + 20), 8, wheelPaint);

    canvas.restore();

    // Route path
    final pathPaint = Paint()..color = Colors.blue.withOpacity(0.5)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(startX, truckY + 60), Offset(endX, truckY + 60), pathPaint);

    // Progress indicator
    final progressPaint = Paint()..color = Colors.blue..strokeWidth = 5;
    canvas.drawLine(Offset(startX, truckY + 60), Offset(truckX, truckY + 60), progressPaint);

    // Destination pin
    final pinPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(endX, truckY + 60), 12, pinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Scene 6: Complete
class _Scene6Complete extends StatelessWidget {
  final double progress;
  const _Scene6Complete(this.progress);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompletePainter(progress),
      size: const Size(double.infinity, 400),
    );
  }
}

class _CompletePainter extends CustomPainter {
  final double progress;
  _CompletePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Truck driving away
    final truckX = centerX - 100 + (progress * 200);
    final truckPaint = Paint()..color = Colors.green.withOpacity(1 - progress * 0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(truckX, centerY + 50), width: 50, height: 30),
        const Radius.circular(4),
      ),
      truckPaint,
    );

    // Dust particles
    if (progress < 0.5) {
      for (int i = 0; i < 5; i++) {
        final dustProgress = (progress * 2 + i * 0.1) % 1.0;
        final dustPaint = Paint()..color = Colors.grey.withOpacity(0.5 * (1 - dustProgress));
        canvas.drawCircle(
          Offset(truckX - 30 - i * 10, centerY + 60 + dustProgress * 20),
          4 * (1 - dustProgress),
          dustPaint,
        );
      }
    }

    // Completed stamp
    if (progress > 0.3) {
      final stampScale = math.min((progress - 0.3) / 0.3, 1.0);
      canvas.save();
      canvas.translate(centerX, centerY - 50);
      canvas.scale(stampScale);

      final stampPaint = Paint()..color = Colors.green.withOpacity(0.8);
      canvas.drawCircle(Offset.zero, 60, stampPaint);

      final checkPaint = Paint()..color = Colors.white..strokeWidth = 8..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-20, 0), const Offset(-5, 15), checkPaint);
      canvas.drawLine(const Offset(-5, 15), const Offset(25, -20), checkPaint);

      canvas.restore();
    }

    // Satisfaction stars
    if (progress > 0.5) {
      for (int i = 0; i < 5; i++) {
        final starProgress = math.max(0.0, (progress - 0.5 - i * 0.05) / 0.3);
        if (starProgress > 0) {
          final starPaint = Paint()..color = Colors.amber.withOpacity(starProgress);
          _drawStar(canvas, Offset(centerX - 80 + i * 40, centerY + 80), 15, starPaint);
        }
      }
    }

    // Confetti
    if (progress > 0.7) {
      for (int i = 0; i < 20; i++) {
        final confettiProgress = (progress - 0.7) / 0.3;
        final angle = (i / 20) * 2 * math.pi;
        final distance = 100 * confettiProgress;
        final x = centerX + math.cos(angle) * distance;
        final y = centerY - 50 + math.sin(angle) * distance + (confettiProgress * 50);

        final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple];
        final confettiPaint = Paint()..color = colors[i % 5].withOpacity(1 - confettiProgress);
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 6, height: 10), confettiPaint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      final innerAngle = angle + math.pi / 5;
      final innerX = center.dx + (size * 0.4) * math.cos(innerAngle);
      final innerY = center.dy + (size * 0.4) * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
