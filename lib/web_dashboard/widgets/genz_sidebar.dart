import 'package:flutter/material.dart';
import 'dart:math' as math;

class GenZSidebar extends StatefulWidget {
  const GenZSidebar({Key? key}) : super(key: key);

  @override
  State<GenZSidebar> createState() => _GenZSidebarState();
}

class _GenZSidebarState extends State<GenZSidebar> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _geometryController;
  late AnimationController _glowController;

  final List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.dashboard, label: 'Dashboard', color: const Color(0xFFFF006E)),
    _MenuItem(icon: Icons.assignment, label: 'Requests', color: const Color(0xFF8338EC)),
    _MenuItem(icon: Icons.local_shipping, label: 'Drivers', color: const Color(0xFF3A86FF)),
    _MenuItem(icon: Icons.recycling, label: 'Recycling', color: const Color(0xFF06FFA5)),
    _MenuItem(icon: Icons.eco, label: 'Eco Score', color: const Color(0xFFFB5607)),
    _MenuItem(icon: Icons.settings, label: 'Settings', color: const Color(0xFFFFBE0B)),
  ];

  @override
  void initState() {
    super.initState();
    _geometryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _geometryController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      child: Stack(
        children: [
          // Diagonal Background
          ClipPath(
            clipper: _DiagonalClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A0E27),
                    const Color(0xFF1A1F3A),
                    const Color(0xFF0F1729),
                  ],
                ),
              ),
            ),
          ),
          
          // Animated Geometric Patterns
          AnimatedBuilder(
            animation: _geometryController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _GeometricPatternPainter(_geometryController.value),
              );
            },
          ),
          
          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(height: 60),
                
                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(index);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Active Indicator Triangle
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            top: 140 + (_selectedIndex * 70.0),
            left: 10,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(30, 30),
                  painter: _TriangleIndicatorPainter(
                    _menuItems[_selectedIndex].color,
                    _glowController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        CustomPaint(
          size: const Size(40, 40),
          painter: _LogoTrianglePainter(),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ECO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF06FFA5), Color(0xFF3A86FF)],
                  ).createShader(const Rect.fromLTWH(0, 0, 100, 30)),
              ),
            ),
            Text(
              'COMMAND',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index) {
    final item = _menuItems[index];
    final isSelected = _selectedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: isSelected ? 1 : 0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 0.05,
                child: Transform.scale(
                  scale: 1 + (value * 0.05),
                  child: ClipPath(
                    clipper: _MenuItemClipper(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [item.color.withOpacity(0.3), item.color.withOpacity(0.1)]
                              : [Colors.white.withOpacity(0.05), Colors.transparent],
                        ),
                        border: Border.all(
                          color: isSelected ? item.color : Colors.white.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: item.color.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? item.color : Colors.white.withOpacity(0.6),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;

  _MenuItem({required this.icon, required this.label, required this.color});
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 30, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MenuItemClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(8, 0);
    path.lineTo(size.width - 8, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _GeometricPatternPainter extends CustomPainter {
  final double animation;

  _GeometricPatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.cyan.withOpacity(0.1);

    for (var i = 0; i < 5; i++) {
      final y = (size.height / 5) * i + (50 * math.sin(animation * 2 * math.pi + i));
      final path = Path();
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y + 30);
      path.lineTo(size.width * 0.6, y - 20);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TriangleIndicatorPainter extends CustomPainter {
  final Color color;
  final double glow;

  _TriangleIndicatorPainter(this.color, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 * glow)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * glow);

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LogoTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF06FFA5), Color(0xFF3A86FF), Color(0xFF8338EC)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
