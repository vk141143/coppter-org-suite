import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'login_screen.dart';

class AnimatedIntroScreen extends StatefulWidget {
  const AnimatedIntroScreen({super.key});

  @override
  State<AnimatedIntroScreen> createState() => _AnimatedIntroScreenState();
}

class _AnimatedIntroScreenState extends State<AnimatedIntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    )..forward();
  }

  Color _getBackgroundColor() {
    final value = _controller.value;
    if (value < 0.25) return const Color(0xFFFAF7F2);
    if (value < 0.30) return Color.lerp(const Color(0xFFFAF7F2), const Color(0xFFD1E7DD), (value - 0.25) / 0.05)!;
    if (value < 0.40) return const Color(0xFFD1E7DD);
    if (value < 0.45) return Color.lerp(const Color(0xFFD1E7DD), const Color(0xFF0F5132), (value - 0.40) / 0.05)!;
    if (value < 0.52) return const Color(0xFF0F5132);
    if (value < 0.57) return Color.lerp(const Color(0xFF0F5132), const Color(0xFFFAF7F2), (value - 0.52) / 0.05)!;
    return const Color(0xFFFAF7F2);
  }

  double _getBallY(double value) {
    if (value < 0.10) {
      return Curves.easeInQuad.transform(value / 0.10);
    } else if (value < 0.30) {
      final t = (value - 0.10) / 0.20;
      return 1.0 - (4 * t * (1 - t) * 0.4);
    } else if (value < 0.45) {
      final t = (value - 0.30) / 0.15;
      return 1.0 - (4 * t * (1 - t) * 0.25);
    } else if (value < 0.57) {
      final t = (value - 0.45) / 0.12;
      return 1.0 - (4 * t * (1 - t) * 0.12);
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: _getBackgroundColor(),
            child: Stack(
              children: [
                _buildLine(size),
                if (_controller.value < 0.57) _buildBall(size),
                if (_controller.value >= 0.28 && _controller.value < 0.31) _buildShockwave(size, 0.28),
                if (_controller.value >= 0.43 && _controller.value < 0.46) _buildShockwave(size, 0.43),
                if (_controller.value >= 0.55 && _controller.value < 0.58) _buildShockwave(size, 0.55),
                if (_controller.value >= 0.57 && _controller.value < 0.72) _buildMorphSequence(size),
                if (_controller.value >= 0.72) _buildFinalLeaf(size),
                if (_controller.value >= 0.75) _buildText(size),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLine(Size size) {
    final lineProgress = (_controller.value / 0.08).clamp(0.0, 1.0);
    final fadeOut = _controller.value > 0.57 ? 1.0 - ((_controller.value - 0.57) / 0.05).clamp(0.0, 1.0) : 1.0;
    final lineWidth = size.width * 0.10 * lineProgress;
    
    return Positioned(
      top: size.height * 0.65,
      left: (size.width - lineWidth) / 2,
      child: Opacity(
        opacity: fadeOut,
        child: Container(
          width: lineWidth,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF0F5132),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5132).withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBall(Size size) {
    final ballY = _getBallY(_controller.value);
    final isImpact = (_controller.value > 0.28 && _controller.value < 0.30) ||
                     (_controller.value > 0.43 && _controller.value < 0.45) ||
                     (_controller.value > 0.55 && _controller.value < 0.57);
    final squashY = isImpact ? 0.6 : 1.0;
    final squashX = isImpact ? 1.3 : 1.0;
    
    return Positioned(
      left: size.width / 2 - 15,
      top: size.height * 0.65 * ballY - 30,
      child: Transform.rotate(
        angle: _controller.value * 4 * math.pi,
        child: Transform.scale(
          scaleY: squashY,
          scaleX: squashX,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFF2D7A4F), Color(0xFF0F5132)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShockwave(Size size, double startTime) {
    final progress = ((_controller.value - startTime) / 0.03).clamp(0.0, 1.0);
    final waveSize = 10 + (progress * 50);
    
    return Positioned(
      left: size.width / 2 - waveSize / 2,
      top: size.height * 0.65 - waveSize / 2,
      child: Opacity(
        opacity: 1 - progress,
        child: Container(
          width: waveSize,
          height: waveSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F5132), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5132).withOpacity(0.6),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMorphSequence(Size size) {
    final morphValue = _controller.value;
    IconData icon;
    double iconOpacity = 1.0;
    
    if (morphValue < 0.615) {
      icon = Icons.delete_outline;
      iconOpacity = ((morphValue - 0.57) / 0.045).clamp(0.0, 1.0);
    } else if (morphValue < 0.66) {
      icon = Icons.local_shipping_outlined;
      iconOpacity = ((morphValue - 0.615) / 0.045).clamp(0.0, 1.0);
    } else {
      icon = Icons.eco;
      iconOpacity = ((morphValue - 0.66) / 0.06).clamp(0.0, 1.0);
    }
    
    return Stack(
      children: [
        if (morphValue >= 0.615 && morphValue < 0.63) _buildParticleBurst(size, 0.615),
        if (morphValue >= 0.66 && morphValue < 0.68) _buildParticleBurst(size, 0.66),
        Positioned(
          left: size.width / 2 - 40,
          top: size.height * 0.65 - 40,
          child: Opacity(
            opacity: iconOpacity,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D7A4F), Color(0xFF0F5132)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.7),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(icon, size: 45, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticleBurst(Size size, double startTime) {
    final progress = ((_controller.value - startTime) / 0.015).clamp(0.0, 1.0);
    
    return Stack(
      children: List.generate(8, (i) {
        final angle = (i / 8) * 2 * math.pi;
        final distance = progress * 40;
        final x = size.width / 2 + math.cos(angle) * distance;
        final y = size.height * 0.65 + math.sin(angle) * distance;
        
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 1 - progress,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F5132),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFinalLeaf(Size size) {
    final scaleProgress = ((_controller.value - 0.72) / 0.03).clamp(0.0, 1.0);
    final scale = 1.0 + (Curves.easeOutBack.transform(scaleProgress) * 0.2);
    
    return Positioned(
      left: size.width / 2 - 50,
      top: size.height * 0.20,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2D7A4F), Color(0xFF0F5132)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F5132).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.eco, size: 60, color: Colors.white);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(Size size) {
    final titleProgress = ((_controller.value - 0.75) / 0.08).clamp(0.0, 1.0);
    final subtitleProgress = ((_controller.value - 0.80) / 0.08).clamp(0.0, 1.0);
    final buttonProgress = ((_controller.value - 0.88) / 0.12).clamp(0.0, 1.0);
    
    return Positioned(
      left: 0,
      right: 0,
      top: size.height * 0.50,
      child: Column(
        children: [
          Opacity(
            opacity: titleProgress,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - titleProgress)),
              child: Transform.scale(
                scale: 0.95 + (titleProgress * 0.05),
                child: const Text(
                  'LiftAway',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F1F1F),
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: subtitleProgress,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - subtitleProgress)),
              child: Text(
                'Fast. Simple. Reliable Waste Removal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1F1F1F).withOpacity(0.8),
                  letterSpacing: 0.5 + (subtitleProgress * 0.5),
                  shadows: const [
                    Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Opacity(
            opacity: buttonProgress,
            child: Transform.scale(
              scale: 0.85 + (Curves.easeOutBack.transform(buttonProgress) * 0.15),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F5132).withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasSeenIntro', true);
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5132),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
