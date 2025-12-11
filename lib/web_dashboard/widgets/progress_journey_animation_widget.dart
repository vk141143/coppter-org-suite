import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressJourneyAnimationWidget extends StatefulWidget {
  final bool autoPlay;
  final int currentStep;
  final Function(int)? onStepChanged;

  const ProgressJourneyAnimationWidget({
    super.key,
    this.autoPlay = true,
    this.currentStep = 0,
    this.onStepChanged,
  });

  @override
  State<ProgressJourneyAnimationWidget> createState() => _ProgressJourneyAnimationWidgetState();
}

class _ProgressJourneyAnimationWidgetState extends State<ProgressJourneyAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _walkController;
  late AnimationController _milestone1Controller;
  late AnimationController _milestone2Controller;
  late AnimationController _milestone3Controller;
  late AnimationController _milestone4Controller;
  late AnimationController _milestone5Controller;

  int _currentStep = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _milestone1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _milestone2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _milestone3Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _milestone4Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _milestone5Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _isPlaying = true;
    _animateToStep(0);
  }

  void _animateToStep(int step) async {
    if (!mounted) return;
    setState(() => _currentStep = step);
    widget.onStepChanged?.call(step);

    final targetProgress = step / 4;
    await _mainController.animateTo(targetProgress, duration: const Duration(milliseconds: 1500));

    if (!mounted) return;
    switch (step) {
      case 0:
        await _milestone1Controller.forward(from: 0);
        break;
      case 1:
        await _milestone2Controller.forward(from: 0);
        break;
      case 2:
        await _milestone3Controller.forward(from: 0);
        break;
      case 3:
        await _milestone4Controller.forward(from: 0);
        break;
      case 4:
        await _milestone5Controller.forward(from: 0);
        break;
    }

    if (widget.autoPlay && step < 4 && mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _animateToStep(step + 1);
    }
  }

  void _goToStep(int step) {
    if (_isPlaying) return;
    _animateToStep(step);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _walkController.dispose();
    _milestone1Controller.dispose();
    _milestone2Controller.dispose();
    _milestone3Controller.dispose();
    _milestone4Controller.dispose();
    _milestone5Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Waste Pickup Journey',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _mainController,
                _walkController,
                _milestone1Controller,
                _milestone2Controller,
                _milestone3Controller,
                _milestone4Controller,
                _milestone5Controller,
              ]),
              builder: (context, child) {
                return CustomPaint(
                  painter: _ProgressJourneyPainter(
                    progress: _mainController.value,
                    walkProgress: _walkController.value,
                    currentStep: _currentStep,
                    milestone1Progress: _milestone1Controller.value,
                    milestone2Progress: _milestone2Controller.value,
                    milestone3Progress: _milestone3Controller.value,
                    milestone4Progress: _milestone4Controller.value,
                    milestone5Progress: _milestone5Controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 5; i++)
                GestureDetector(
                  onTap: () => _goToStep(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep >= i ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressJourneyPainter extends CustomPainter {
  final double progress;
  final double walkProgress;
  final int currentStep;
  final double milestone1Progress;
  final double milestone2Progress;
  final double milestone3Progress;
  final double milestone4Progress;
  final double milestone5Progress;

  _ProgressJourneyPainter({
    required this.progress,
    required this.walkProgress,
    required this.currentStep,
    required this.milestone1Progress,
    required this.milestone2Progress,
    required this.milestone3Progress,
    required this.milestone4Progress,
    required this.milestone5Progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final progressY = size.height * 0.6;
    final startX = 60.0;
    final endX = size.width - 60;
    final progressWidth = endX - startX;

    // Draw progress line background
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, progressY), Offset(endX, progressY), bgPaint);

    // Draw filled progress
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.shade400, Colors.purple.shade400],
      ).createShader(Rect.fromLTWH(startX, progressY - 4, progressWidth * progress, 8))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(startX, progressY),
      Offset(startX + progressWidth * progress, progressY),
      progressPaint,
    );

    // Draw checkpoints
    for (int i = 0; i < 5; i++) {
      final x = startX + (progressWidth / 4) * i;
      final isActive = progress >= i / 4;
      final checkpointPaint = Paint()
        ..color = isActive ? Colors.green : Colors.grey.shade400
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, progressY), 12, checkpointPaint);

      if (isActive) {
        final glowPaint = Paint()
          ..color = Colors.green.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, progressY), 18, glowPaint);
      }
    }

    // Draw character
    final characterX = startX + progressWidth * progress;
    _drawCharacter(canvas, Offset(characterX, progressY - 40), walkProgress);

    // Draw milestone animations
    if (currentStep == 0 && milestone1Progress > 0) {
      _drawMilestone1(canvas, Offset(startX, progressY - 100), milestone1Progress);
    } else if (currentStep == 1 && milestone2Progress > 0) {
      _drawMilestone2(canvas, Offset(startX + progressWidth / 4, progressY - 100), milestone2Progress);
    } else if (currentStep == 2 && milestone3Progress > 0) {
      _drawMilestone3(canvas, Offset(startX + progressWidth / 2, progressY - 100), milestone3Progress);
    } else if (currentStep == 3 && milestone4Progress > 0) {
      _drawMilestone4(canvas, Offset(startX + progressWidth * 0.75, progressY - 100), milestone4Progress);
    } else if (currentStep == 4 && milestone5Progress > 0) {
      _drawMilestone5(canvas, Offset(endX, progressY - 100), milestone5Progress);
    }
  }

  void _drawCharacter(Canvas canvas, Offset position, double walkAnim) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(position.dx, position.dy + 35), width: 20, height: 8),
      shadowPaint,
    );

    // Body
    final bodyPaint = Paint()..color = Colors.blue.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: 16, height: 28),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = Colors.orange.shade300;
    canvas.drawCircle(Offset(position.dx, position.dy - 18), 10, headPaint);

    // Legs (walking animation)
    final legPaint = Paint()
      ..color = Colors.blue.shade900
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final legOffset = math.sin(walkAnim * 2 * math.pi) * 8;
    canvas.drawLine(
      Offset(position.dx - 4, position.dy + 14),
      Offset(position.dx - 4 + legOffset, position.dy + 28),
      legPaint,
    );
    canvas.drawLine(
      Offset(position.dx + 4, position.dy + 14),
      Offset(position.dx + 4 - legOffset, position.dy + 28),
      legPaint,
    );

    // Arms
    final armPaint = Paint()
      ..color = Colors.blue.shade900
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(position.dx - 8, position.dy - 4),
      Offset(position.dx - 12, position.dy + 8),
      armPaint,
    );
    canvas.drawLine(
      Offset(position.dx + 8, position.dy - 4),
      Offset(position.dx + 12, position.dy + 8),
      armPaint,
    );
  }

  void _drawMilestone1(Canvas canvas, Offset position, double progress) {
    final scale = Curves.elasticOut.transform(progress);

    // Phone
    final phonePaint = Paint()..color = Colors.grey.shade800;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: 40 * scale, height: 60 * scale),
        Radius.circular(8 * scale),
      ),
      phonePaint,
    );

    // Camera flash
    if (progress > 0.5) {
      final flashPaint = Paint()
        ..color = Colors.yellow.withOpacity((1 - (progress - 0.5) * 2))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(position, 30 * scale, flashPaint);
    }

    // Waste pile
    if (progress > 0.7) {
      final wastePaint = Paint()..color = Colors.brown;
      canvas.drawCircle(Offset(position.dx + 30, position.dy + 40), 15 * scale, wastePaint);
    }
  }

  void _drawMilestone2(Canvas canvas, Offset position, double progress) {
    final scale = Curves.easeOut.transform(progress);

    // Photo icons bouncing
    for (int i = 0; i < 3; i++) {
      final bounce = math.sin((progress + i * 0.2) * math.pi) * 20;
      final photoPaint = Paint()..color = Colors.blue.shade300;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(position.dx + (i - 1) * 30, position.dy - bounce),
            width: 24 * scale,
            height: 24 * scale,
          ),
          Radius.circular(4 * scale),
        ),
        photoPaint,
      );
    }

    // Cloud upload
    if (progress > 0.5) {
      final cloudPaint = Paint()..color = Colors.grey.shade400;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(position.dx, position.dy + 30), width: 50 * scale, height: 30 * scale),
        cloudPaint,
      );

      // Upload arrow
      final arrowPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(position.dx, position.dy + 40),
        Offset(position.dx, position.dy + 20),
        arrowPaint,
      );
    }
  }

  void _drawMilestone3(Canvas canvas, Offset position, double progress) {
    final scale = Curves.easeOut.transform(progress);

    // AI hologram scanner
    final scannerPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        position,
        (20 + i * 15) * scale * progress,
        scannerPaint,
      );
    }

    // Floating rupees
    if (progress > 0.4) {
      for (int i = 0; i < 4; i++) {
        final angle = (progress * 2 * math.pi) + (i * math.pi / 2);
        final x = position.dx + math.cos(angle) * 30;
        final y = position.dy + math.sin(angle) * 30;
        
        final rupeePaint = Paint()..color = Colors.amber;
        canvas.drawCircle(Offset(x, y), 8 * scale, rupeePaint);
      }
    }

    // Price card
    if (progress > 0.7) {
      final cardPaint = Paint()
        ..color = Colors.green.shade400
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(position.dx, position.dy + 40), width: 80 * scale, height: 30 * scale),
          Radius.circular(8 * scale),
        ),
        cardPaint,
      );
    }
  }

  void _drawMilestone4(Canvas canvas, Offset position, double progress) {
    final scale = Curves.elasticOut.transform(progress);

    // Driver avatar slides in
    final avatarPaint = Paint()..color = Colors.orange.shade400;
    canvas.drawCircle(Offset(position.dx - 30 * (1 - progress), position.dy), 20 * scale, avatarPaint);

    // Truck drives in
    if (progress > 0.4) {
      final truckX = position.dx + 30 - (60 * (1 - progress));
      final truckPaint = Paint()..color = Colors.green.shade700;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(truckX, position.dy + 30), width: 40 * scale, height: 25 * scale),
          Radius.circular(4 * scale),
        ),
        truckPaint,
      );

      // Wheels
      final wheelPaint = Paint()..color = Colors.grey.shade800;
      canvas.drawCircle(Offset(truckX - 12, position.dy + 42), 6 * scale, wheelPaint);
      canvas.drawCircle(Offset(truckX + 12, position.dy + 42), 6 * scale, wheelPaint);
    }

    // Map pin bouncing
    if (progress > 0.7) {
      final bounce = math.sin(progress * 4 * math.pi) * 10;
      final pinPaint = Paint()..color = Colors.red;
      canvas.drawCircle(Offset(position.dx, position.dy - 30 - bounce), 8 * scale, pinPaint);
    }
  }

  void _drawMilestone5(Canvas canvas, Offset position, double progress) {
    final scale = Curves.easeOut.transform(progress);

    // Truck leaving
    final truckX = position.dx + (progress * 50);
    final truckPaint = Paint()..color = Colors.green.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(truckX, position.dy + 20), width: 40 * scale, height: 25 * scale),
        Radius.circular(4 * scale),
      ),
      truckPaint,
    );

    // Checkmark
    if (progress > 0.5) {
      final checkPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final checkPath = Path()
        ..moveTo(position.dx - 20, position.dy)
        ..lineTo(position.dx - 5, position.dy + 15)
        ..lineTo(position.dx + 20, position.dy - 20);
      canvas.drawPath(checkPath, checkPaint);
    }

    // Confetti
    if (progress > 0.7) {
      for (int i = 0; i < 10; i++) {
        final confettiPaint = Paint()..color = [Colors.red, Colors.blue, Colors.yellow, Colors.green][i % 4];
        final x = position.dx + (i - 5) * 15;
        final y = position.dy - 40 + (progress - 0.7) * 100;
        canvas.drawCircle(Offset(x, y), 4, confettiPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressJourneyPainter oldDelegate) => true;
}
