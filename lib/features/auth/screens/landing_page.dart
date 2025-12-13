import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import '../widgets/dot_reveal_hero.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(size),
                _buildProblemSection(size),
                _buildSolutionSection(size),
                _buildTrackingSection(size),
                _buildAnalyticsSection(size),
                _buildFeaturesSection(size),
                _buildTestimonialsSection(size),
                _buildFooter(size),
              ],
            ),
          ),
          _buildFloatingParticles(size),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size size) {
    return const SizedBox(
      child: DotRevealHero(),
    );
  }



  Widget _buildProblemSection(Size size) {
    final sectionOffset = (_scrollOffset - size.height * 0.5).clamp(0.0, size.height);
    final opacity = (1 - (sectionOffset / size.height)).clamp(0.0, 1.0);
    
    return Container(
      height: size.height * 0.8,
      color: Colors.grey.shade300,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _ProblemPatternPainter()),
            ),
          ),
          Center(
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 80, color: const Color(0xFFFF6F00)),
                    const SizedBox(height: 24),
                    Text(
                      'The Problem',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Overflowing bins. Missed pickups.\nInefficient routes. Frustrated citizens.',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade700, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildOverflowingBin(opacity),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowingBin(double opacity) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, size: 50, color: Colors.white),
            ),
            ...List.generate(5, (i) {
              final angle = (i / 5) * 2 * math.pi + _particleController.value * 2 * math.pi;
              final distance = 60 + math.sin(_particleController.value * 2 * math.pi + i) * 10;
              return Transform.translate(
                offset: Offset(math.cos(angle) * distance, math.sin(angle) * distance - 20),
                child: Icon(Icons.circle, size: 8, color: const Color(0xFFFF6F00).withOpacity(0.6)),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSolutionSection(Size size) {
    final sectionOffset = (_scrollOffset - size.height * 1.3).clamp(0.0, size.height);
    final progress = (sectionOffset / size.height).clamp(0.0, 1.0);
    
    return Container(
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFD1E7DD), const Color(0xFF0F5132).withOpacity(0.1)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.5 + (progress * 0.5),
                child: Opacity(
                  opacity: progress,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
                    ),
                    child: const Icon(Icons.eco, size: 60, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Opacity(
                opacity: progress,
                child: Text(
                  'The LiftAway Solution',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F5132)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: progress,
                child: Text(
                  'AI-powered route optimization.\nReal-time tracking. Smart scheduling.',
                  style: TextStyle(fontSize: 18, color: const Color(0xFF1F1F1F).withOpacity(0.8), height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              _buildRouteOptimization(progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteOptimization(double progress) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Opacity(
          opacity: progress,
          child: CustomPaint(
            size: const Size(200, 150),
            painter: _RouteOptimizationPainter(_particleController.value),
          ),
        );
      },
    );
  }

  Widget _buildTrackingSection(Size size) {
    final sectionOffset = (_scrollOffset - size.height * 2.3).clamp(0.0, size.height);
    final progress = (sectionOffset / size.height).clamp(0.0, 1.0);
    
    return Container(
      height: size.height,
      color: const Color(0xFFFAF7F2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: progress,
                child: const Text(
                  'Real-time Driver Tracking',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F5132)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: progress,
                child: Text(
                  'Know exactly when your waste will be collected',
                  style: TextStyle(fontSize: 18, color: const Color(0xFF1F1F1F).withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              _buildMapAnimation(progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapAnimation(double progress) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Opacity(
          opacity: progress,
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
            ),
            child: CustomPaint(
              painter: _MapTrackingPainter(_particleController.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection(Size size) {
    final sectionOffset = (_scrollOffset - size.height * 3.3).clamp(0.0, size.height);
    final progress = (sectionOffset / size.height).clamp(0.0, 1.0);
    
    return Container(
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFD1E7DD), const Color(0xFFFAF7F2)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: progress,
                child: const Text(
                  'Smart Collections & Analytics',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F5132)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              _buildStatsCards(progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(double progress) {
    final stats = [
      {'icon': Icons.trending_up, 'value': '95%', 'label': 'Efficiency'},
      {'icon': Icons.access_time, 'value': '2hrs', 'label': 'Avg Response'},
      {'icon': Icons.eco, 'value': '50K+', 'label': 'Tons Recycled'},
    ];
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: stats.map((stat) => Transform.translate(
        offset: Offset(0, 50 * (1 - progress)),
        child: Opacity(
          opacity: progress,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.1), blurRadius: 15, spreadRadius: 2)],
            ),
            child: Column(
              children: [
                Icon(stat['icon'] as IconData, size: 40, color: const Color(0xFF0F5132)),
                const SizedBox(height: 8),
                Text(stat['value'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
                Text(stat['label'] as String, style: TextStyle(fontSize: 12, color: const Color(0xFF1F1F1F).withOpacity(0.6))),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildFeaturesSection(Size size) {
    final features = [
      {'icon': Icons.schedule, 'title': 'Smart Scheduling', 'desc': 'AI-optimized pickup times'},
      {'icon': Icons.location_on, 'title': 'Live Tracking', 'desc': 'Real-time driver location'},
      {'icon': Icons.analytics, 'title': 'Analytics', 'desc': 'Detailed insights & reports'},
      {'icon': Icons.notifications_active, 'title': 'Instant Alerts', 'desc': 'Stay informed always'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFFAF7F2),
      child: Column(
        children: [
          const Text('Features', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F5132))),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: features.map((f) => Container(
              width: 160,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Icon(f['icon'] as IconData, size: 50, color: const Color(0xFF0F5132)),
                  const SizedBox(height: 12),
                  Text(f['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F))),
                  const SizedBox(height: 8),
                  Text(f['desc'] as String, style: TextStyle(fontSize: 12, color: const Color(0xFF1F1F1F).withOpacity(0.6)), textAlign: TextAlign.center),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(Size size) {
    final testimonials = [
      {'name': 'Sarah M.', 'text': 'LiftAway transformed our city\'s waste management!', 'role': 'City Manager'},
      {'name': 'John D.', 'text': 'Reliable, efficient, and eco-friendly. Highly recommend!', 'role': 'Business Owner'},
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFD1E7DD), const Color(0xFFFAF7F2)]),
      ),
      child: Column(
        children: [
          const Text('What People Say', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F5132))),
          const SizedBox(height: 40),
          ...testimonials.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"${t['text']}"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: const Color(0xFF1F1F1F).withOpacity(0.8))),
                const SizedBox(height: 12),
                Text('— ${t['name']}, ${t['role']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFooter(Size size) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF1F1F1F),
      child: Column(
        children: [
          const Text('LiftAway', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFD1E7DD))),
          const SizedBox(height: 16),
          Text('Transforming waste into intelligence', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5132),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Start Your Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Text('© 2024 LiftAway. All rights reserved.', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCTAButton(String text, bool isPrimary) {
    return ElevatedButton(
      onPressed: () {
        if (isPrimary) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          _scrollController.animateTo(MediaQuery.of(context).size.height, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF0F5132) : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF0F5132),
        side: isPrimary ? null : const BorderSide(color: Color(0xFF0F5132), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: isPrimary ? 8 : 0,
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return IgnorePointer(
          child: Stack(
            children: List.generate(8, (i) {
              final offset = _particleController.value * 2 * math.pi + i;
              final x = size.width * (0.1 + (i % 4) * 0.25);
              final y = (size.height * 0.3 + math.sin(offset) * 100) % size.height;
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(Icons.eco, size: 20, color: const Color(0xFF0F5132)),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class _ProblemPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade600..strokeWidth = 2;
    for (var i = 0; i < 10; i++) {
      canvas.drawLine(Offset(0, i * 50), Offset(size.width, i * 50), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RouteOptimizationPainter extends CustomPainter {
  final double progress;
  _RouteOptimizationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF0F5132)..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(20, size.height / 2)
      ..quadraticBezierTo(size.width / 3, 20, size.width / 2, size.height / 2)
      ..quadraticBezierTo(size.width * 2 / 3, size.height - 20, size.width - 20, size.height / 2);
    
    canvas.drawPath(path, paint);
    
    final dotPaint = Paint()..color = const Color(0xFF0F5132);
    final positions = [Offset(20, size.height / 2), Offset(size.width / 2, size.height / 2), Offset(size.width - 20, size.height / 2)];
    for (var pos in positions) {
      canvas.drawCircle(pos, 8, dotPaint);
    }
    
    final truckPos = path.computeMetrics().first.getTangentForOffset(path.computeMetrics().first.length * progress)?.position ?? Offset.zero;
    canvas.drawCircle(truckPos, 12, Paint()..color = const Color(0xFFFF6F00));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MapTrackingPainter extends CustomPainter {
  final double progress;
  _MapTrackingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(Offset(0, i * size.height / 4), Offset(size.width, i * size.height / 4), gridPaint);
      canvas.drawLine(Offset(i * size.width / 4, 0), Offset(i * size.width / 4, size.height), gridPaint);
    }
    
    final routePaint = Paint()..color = const Color(0xFF0F5132)..strokeWidth = 3..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(30, 30)
      ..lineTo(size.width / 2, size.height / 3)
      ..lineTo(size.width - 30, size.height - 30);
    canvas.drawPath(path, routePaint);
    
    final metrics = path.computeMetrics().first;
    final pos = metrics.getTangentForOffset(metrics.length * progress)?.position ?? Offset.zero;
    canvas.drawCircle(pos, 10, Paint()..color = const Color(0xFFFF6F00));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
