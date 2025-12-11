import 'package:flutter/material.dart';
import 'dart:math' as math;

class SubmitTransitionAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final Color buttonColor;

  const SubmitTransitionAnimation({
    super.key,
    required this.onComplete,
    this.buttonColor = const Color(0xFF1A73E8),
  });

  @override
  State<SubmitTransitionAnimation> createState() => _SubmitTransitionAnimationState();
}

class _SubmitTransitionAnimationState extends State<SubmitTransitionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _fadeController;
  late AnimationController _loadingController;
  late AnimationController _checkController;
  late AnimationController _slideController;

  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _checkAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInCubic,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Step 1: Expand button
    await _expandController.forward();

    // Step 2: Fade to white
    await _fadeController.forward();

    // Step 3: Loading animation
    _loadingController.repeat();
    await Future.delayed(const Duration(milliseconds: 1500));
    _loadingController.stop();

    // Step 4: Success checkmark
    await _checkController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 5: Slide up and navigate
    await _slideController.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    _loadingController.dispose();
    _checkController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _expandAnimation,
            _fadeAnimation,
            _loadingController,
            _checkAnimation,
          ]),
          builder: (context, child) {
            return Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withOpacity(0.3 * _expandAnimation.value),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  width: _expandAnimation.value < 1
                      ? 200 + (size.width - 200) * _expandAnimation.value
                      : size.width,
                  height: _expandAnimation.value < 1
                      ? 56 + (size.height - 56) * _expandAnimation.value
                      : size.height,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      widget.buttonColor,
                      Colors.white,
                      _fadeAnimation.value,
                    ),
                    borderRadius: BorderRadius.circular(
                      28 * (1 - _expandAnimation.value),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.buttonColor.withOpacity(
                          0.4 * (1 - _fadeAnimation.value),
                        ),
                        blurRadius: 30 * _expandAnimation.value,
                        spreadRadius: 10 * _expandAnimation.value,
                      ),
                    ],
                  ),
                  child: _expandAnimation.value >= 1
                      ? Center(
                          child: _checkController.value > 0
                              ? _buildSuccessCheck()
                              : _buildLoadingSpinner(),
                        )
                      : Center(
                          child: Text(
                            'Submit Complaint',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSpinner() {
    return CustomPaint(
      size: const Size(60, 60),
      painter: _LoadingSpinnerPainter(
        progress: _loadingController.value,
        color: widget.buttonColor,
      ),
    );
  }

  Widget _buildSuccessCheck() {
    return Transform.scale(
      scale: _checkAnimation.value,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _CheckmarkPainter(progress: _checkAnimation.value),
        ),
      ),
    );
  }
}

class _LoadingSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LoadingSpinnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw rotating arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + (progress * 2 * math.pi),
      math.pi,
      false,
      paint,
    );

    // Draw particles
    for (int i = 0; i < 3; i++) {
      final angle = (progress * 2 * math.pi) + (i * 2 * math.pi / 3);
      final x = center.dx + math.cos(angle) * (radius + 10);
      final y = center.dy + math.sin(angle) * (radius + 10);
      
      final particlePaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 3, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoadingSpinnerPainter oldDelegate) => true;
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;

  _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);

    // Checkmark path
    path.moveTo(center.dx - 15, center.dy);
    path.lineTo(center.dx - 5, center.dy + 10);
    path.lineTo(center.dx + 15, center.dy - 10);

    // Draw checkmark with progress
    final pathMetrics = path.computeMetrics().first;
    final extractPath = pathMetrics.extractPath(
      0,
      pathMetrics.length * progress,
    );

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => true;
}
