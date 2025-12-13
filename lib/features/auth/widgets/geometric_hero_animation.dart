import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeometricHeroAnimation extends StatefulWidget {
  final Function(String)? onTextChange;
  
  const GeometricHeroAnimation({super.key, this.onTextChange});

  @override
  State<GeometricHeroAnimation> createState() => _GeometricHeroAnimationState();
}

class _GeometricHeroAnimationState extends State<GeometricHeroAnimation> with TickerProviderStateMixin {
  late AnimationController _shapeController;
  late AnimationController _sweepController;
  int _currentShapeIndex = 0;
  
  final List<String> _captions = [
    'Optimize Operations',
    'Track Drivers in Real-Time',
    'Smart Bin Alerts',
    'Actionable Insights',
    'Faster, Cleaner Collections',
  ];

  @override
  void initState() {
    super.initState();
    _shapeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _sweepController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    
    _startAnimationCycle();
  }

  void _startAnimationCycle() async {
    await Future.delayed(const Duration(seconds: 1));
    while (mounted) {
      await _sweepController.forward();
      _sweepController.reset();
      
      setState(() {
        _currentShapeIndex = (_currentShapeIndex + 1) % 5;
      });
      widget.onTextChange?.call(_captions[_currentShapeIndex]);
      
      await _shapeController.forward();
      _shapeController.reset();
      
      await Future.delayed(const Duration(milliseconds: 2300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shapeController, _sweepController]),
      builder: (context, child) {
        final scale = 1.0 + (math.sin(_shapeController.value * math.pi) * 0.05);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F5132).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(250, 250),
                    painter: _ShapePainter(_currentShapeIndex, _shapeController.value),
                  ),
                ),
                if (_sweepController.isAnimating)
                  Positioned.fill(
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _SweepPainter(_sweepController.value),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _shapeController.dispose();
    _sweepController.dispose();
    super.dispose();
  }
}

class _ShapePainter extends CustomPainter {
  final int shapeIndex;
  final double morphProgress;

  _ShapePainter(this.shapeIndex, this.morphProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F5132)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = const Color(0xFFD1E7DD).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    Path path;
    switch (shapeIndex) {
      case 0: // Pentagon
        path = _createPolygon(center, radius, 5);
        break;
      case 1: // Hexagon
        path = _createPolygon(center, radius, 6);
        break;
      case 2: // Triangle
        path = _createPolygon(center, radius, 3);
        break;
      case 3: // Circle
        path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
        break;
      case 4: // Square
        path = _createPolygon(center, radius, 4);
        break;
      default:
        path = _createPolygon(center, radius, 5);
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
  }

  Path _createPolygon(Offset center, double radius, int sides) {
    final path = Path();
    final angle = (2 * math.pi) / sides;
    
    for (int i = 0; i <= sides; i++) {
      final x = center.dx + radius * math.cos(i * angle - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SweepPainter extends CustomPainter {
  final double progress;

  _SweepPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(35 * math.pi / 180);
    canvas.translate(-size.width / 2, -size.height / 2);

    final sweepX = -size.width + (progress * size.width * 2);
    canvas.drawRect(
      Rect.fromLTWH(sweepX, 0, size.width * 0.3, size.height),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GeometricHeroSection extends StatefulWidget {
  const GeometricHeroSection({super.key});

  @override
  State<GeometricHeroSection> createState() => _GeometricHeroSectionState();
}

class _GeometricHeroSectionState extends State<GeometricHeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  String _currentText = 'Optimize Operations';
  String _currentSubtext = 'Streamline your waste management with intelligent automation';

  final Map<String, String> _subtexts = {
    'Optimize Operations': 'Streamline your waste management with intelligent automation',
    'Track Drivers in Real-Time': 'Monitor every pickup with live GPS tracking and updates',
    'Smart Bin Alerts': 'Get instant notifications when bins need attention',
    'Actionable Insights': 'Make data-driven decisions with powerful analytics',
    'Faster, Cleaner Collections': 'Reduce response times and improve service quality',
  };

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  void _onTextChange(String newText) async {
    await _textController.reverse();
    setState(() {
      _currentText = newText;
      _currentSubtext = _subtexts[newText] ?? '';
    });
    _textController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Container(
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAF7F2), Color(0xFFD1E7DD)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
          child: isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GeometricHeroAnimation(onTextChange: _onTextChange),
                    const SizedBox(height: 40),
                    _buildTextSection(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: GeometricHeroAnimation(onTextChange: _onTextChange),
                      ),
                    ),
                    const SizedBox(width: 80),
                    Expanded(child: _buildTextSection()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _textController.value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F1F1F),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentSubtext,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1F1F1F).withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5132),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Get Started', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F5132),
                        side: const BorderSide(color: Color(0xFF0F5132), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
