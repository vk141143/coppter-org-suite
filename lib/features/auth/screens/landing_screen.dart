import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../shared/widgets/custom_button.dart';
import 'onboarding_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late AnimationController _truckController;
  late AnimationController _earthController;
  late AnimationController _progressController;
  
  late Animation<double> _truckPosition;
  late Animation<double> _wheelRotation;
  late Animation<double> _earthRotation;
  late Animation<double> _earthGlow;
  late Animation<double> _progressRing;
  late Animation<double> _icon1;
  late Animation<double> _icon2;
  late Animation<double> _icon3;

  @override
  void initState() {
    super.initState();
    
    // Truck animation (0-3s)
    _truckController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _truckPosition = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _truckController, curve: Curves.easeInOut),
    );
    
    _wheelRotation = Tween<double>(begin: 0, end: 8 * math.pi).animate(_truckController);
    
    // Earth animation (3-6s)
    _earthController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _earthRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_earthController);
    _earthGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _earthController, curve: Curves.easeIn),
    );
    
    // Progress animation (6-9s)
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _progressRing = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
    
    _icon1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeIn),
      ),
    );
    
    _icon2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.33, 0.66, curve: Curves.easeIn),
      ),
    );
    
    _icon3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _startAnimation();
  }

  void _startAnimation() async {
    await _truckController.forward();
    await _earthController.forward();
    await _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Truck Animation
                    AnimatedBuilder(
                      animation: _truckController,
                      builder: (context, child) {
                        return Positioned(
                          left: size.width * _truckPosition.value,
                          top: size.height * 0.15,
                          child: Opacity(
                            opacity: _truckController.value < 0.9 ? 1.0 : 1.0 - (_truckController.value - 0.9) * 10,
                            child: _buildTruck(),
                          ),
                        );
                      },
                    ),
                    
                    // Earth Animation
                    AnimatedBuilder(
                      animation: _earthController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _truckController.value > 0.8 ? (_truckController.value - 0.8) * 5 : 0,
                          child: Transform.rotate(
                            angle: _earthRotation.value,
                            child: _buildEarth(),
                          ),
                        );
                      },
                    ),
                    
                    // Progress Ring
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _earthController.isCompleted ? 1.0 : 0.0,
                          child: _buildProgressRing(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Text Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'Towards a Cleaner Future',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Smart waste pickup for a greener planet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Hero(
                      tag: 'get-started',
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomButton(
                          text: 'Get Started',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnboardingScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTruck() {
    return AnimatedBuilder(
      animation: _wheelRotation,
      builder: (context, child) {
        return SizedBox(
          width: 120,
          height: 80,
          child: CustomPaint(
            painter: TruckPainter(_wheelRotation.value),
          ),
        );
      },
    );
  }

  Widget _buildEarth() {
    return AnimatedBuilder(
      animation: _earthGlow,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Theme.of(context).colorScheme.secondary.withOpacity(_earthGlow.value * 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(Colors.grey, Theme.of(context).colorScheme.primary, _earthGlow.value)!,
                    Color.lerp(Colors.brown, Theme.of(context).colorScheme.secondary, _earthGlow.value)!,
                  ],
                ),
              ),
              child: const Icon(
                Icons.public,
                size: 80,
                color: Colors.white70,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressRing() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          AnimatedBuilder(
            animation: _progressRing,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: RingPainter(_progressRing.value, Theme.of(context).colorScheme.secondary),
              );
            },
          ),
          
          // Icons
          _buildEcoIcon(_icon1, Icons.remove_circle_outline, -100, -100),
          _buildEcoIcon(_icon2, Icons.autorenew, 100, -100),
          _buildEcoIcon(_icon3, Icons.recycling, 0, 120),
        ],
      ),
    );
  }

  Widget _buildEcoIcon(Animation<double> animation, IconData icon, double dx, double dy) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: animation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(animation.value),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _truckController.dispose();
    _earthController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

class TruckPainter extends CustomPainter {
  final double wheelRotation;

  TruckPainter(this.wheelRotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    // Truck body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, 80, 40),
        const Radius.circular(8),
      ),
      paint,
    );

    // Wheels
    final wheelPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(35, 60);
    canvas.rotate(wheelRotation);
    canvas.drawCircle(Offset.zero, 12, wheelPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(85, 60);
    canvas.rotate(wheelRotation);
    canvas.drawCircle(Offset.zero, 12, wheelPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(TruckPainter oldDelegate) => wheelRotation != oldDelegate.wheelRotation;
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) => progress != oldDelegate.progress;
}
