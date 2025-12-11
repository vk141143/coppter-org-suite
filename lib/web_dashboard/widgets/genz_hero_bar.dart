import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GenZHeroBar extends StatefulWidget {
  final VoidCallback onSearch;
  final VoidCallback onFilter;

  const GenZHeroBar({
    Key? key,
    required this.onSearch,
    required this.onFilter,
  }) : super(key: key);

  @override
  State<GenZHeroBar> createState() => _GenZHeroBarState();
}

class _GenZHeroBarState extends State<GenZHeroBar> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _gradientController;
  late AnimationController _textController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _gradientController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Triangular Clipped Background
          ClipPath(
            clipper: _HeroShardClipper(),
            child: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(const Color(0xFFFF006E), const Color(0xFF8338EC), _gradientController.value)!,
                        Color.lerp(const Color(0xFF3A86FF), const Color(0xFF06FFA5), _gradientController.value)!,
                        Color.lerp(const Color(0xFF0A0E27), const Color(0xFF1A1F3A), _gradientController.value)!,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Floating Triangle Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _TriangleParticlesPainter(_particleController.value),
              );
            },
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  _buildSkeletonLoader()
                else
                  _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: 0.3 + (0.4 * math.sin(value * math.pi * 4)),
              child: ClipPath(
                clipper: _SkeletonTriangleClipper(),
                child: Container(
                  width: 400,
                  height: 50,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            );
          },
          onEnd: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Split Text Reveal Title
        AnimatedBuilder(
          animation: _textController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -30 * (1 - _textController.value)),
              child: Opacity(
                opacity: _textController.value,
                child: Stack(
                  children: [
                    // Neon Stroke
                    Text(
                      'WASTE COMMAND CENTER',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = const Color(0xFF06FFA5),
                      ),
                    ),
                    // Fill
                    Text(
                      'WASTE COMMAND CENTER',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Subtitle
        AnimatedBuilder(
          animation: _textController,
          builder: (context, child) {
            return Opacity(
              opacity: _textController.value,
              child: Text(
                'Real-time eco operations • GEN-Z dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Command Bar
        _buildCommandBar(),
      ],
    );
  }

  Widget _buildCommandBar() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _textController.value)),
          child: Opacity(
            opacity: _textController.value,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: ClipPath(
              clipper: _SearchBarClipper(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: const Color(0xFF06FFA5).withOpacity(0.5), width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF06FFA5), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search operations...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          onChanged: (value) => widget.onSearch(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Filter Button
          _buildTriangleButton(
            icon: Icons.filter_list,
            label: 'FILTER',
            color: const Color(0xFFFF006E),
            onTap: widget.onFilter,
          ),
          
          const SizedBox(width: 12),
          
          // Export Button
          _buildTriangleButton(
            icon: Icons.download,
            label: 'EXPORT',
            color: const Color(0xFF8338EC),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTriangleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 1),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: ClipPath(
                clipper: _ButtonTriangleClipper(),
                child: Container(
                  width: 140,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroShardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);
    path.lineTo(size.width * 0.7, 0);
    path.lineTo(size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SearchBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(10, 0);
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ButtonTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(8, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 8, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _SkeletonTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(20, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TriangleParticlesPainter extends CustomPainter {
  final double animation;

  _TriangleParticlesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 12; i++) {
      final x = (size.width / 12) * i + (60 * math.sin(animation * 2 * math.pi + i));
      final y = (size.height * 0.5) + (40 * math.cos(animation * 2 * math.pi + i * 0.7));
      final triangleSize = 15 + (5 * math.sin(animation * 2 * math.pi + i));
      
      final path = Path();
      path.moveTo(x, y - triangleSize);
      path.lineTo(x + triangleSize, y + triangleSize);
      path.lineTo(x - triangleSize, y + triangleSize);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
