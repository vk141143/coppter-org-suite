import 'package:flutter/material.dart';
import 'dart:math' as math;

class GenZTriangleCards extends StatefulWidget {
  const GenZTriangleCards({Key? key}) : super(key: key);

  @override
  State<GenZTriangleCards> createState() => _GenZTriangleCardsState();
}

class _GenZTriangleCardsState extends State<GenZTriangleCards> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  int? _hoveredIndex;

  final List<_CardData> _cards = [
    _CardData(
      icon: Icons.assignment,
      value: '47',
      label: 'My Requests',
      color: const Color(0xFFFF006E),
    ),
    _CardData(
      icon: Icons.pending_actions,
      value: '12',
      label: 'Pending Pickups',
      color: const Color(0xFF8338EC),
    ),
    _CardData(
      icon: Icons.local_shipping,
      value: '8',
      label: 'Active Drivers',
      color: const Color(0xFF3A86FF),
    ),
    _CardData(
      icon: Icons.recycling,
      value: '94%',
      label: 'Recycling Score',
      color: const Color(0xFF06FFA5),
    ),
    _CardData(
      icon: Icons.stars,
      value: '2,450',
      label: 'Eco Points',
      color: const Color(0xFFFB5607),
    ),
    _CardData(
      icon: Icons.eco,
      value: '156kg',
      label: 'Carbon Offset',
      color: const Color(0xFFFFBE0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _cards.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (index * 100)),
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 400), () {
      for (var controller in _controllers) {
        controller.forward();
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.3,
      ),
      itemCount: _cards.length,
      itemBuilder: (context, index) {
        return _buildTriangleCard(index);
      },
    );
  }

  Widget _buildTriangleCard(int index) {
    final card = _cards[index];
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          final dropValue = _controllers[index].value;
          
          return Transform.translate(
            offset: Offset(0, -100 * (1 - dropValue)),
            child: Transform.rotate(
              angle: (1 - dropValue) * 0.5,
              child: Opacity(
                opacity: dropValue,
                child: child,
              ),
            ),
          );
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: isHovered ? 1.08 : 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: isHovered ? 0.03 : 0,
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // Pulse Background
              if (isHovered)
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _PulseTrianglePainter(card.color, value),
                      );
                    },
                    onEnd: () => setState(() {}),
                  ),
                ),
              
              // Main Card
              ClipPath(
                clipper: _CardTriangleClipper(index),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        card.color.withOpacity(0.2),
                        card.color.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: card.color.withOpacity(isHovered ? 0.8 : 0.4),
                      width: isHovered ? 3 : 2,
                    ),
                    boxShadow: isHovered
                        ? [
                            BoxShadow(
                              color: card.color.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 1, end: isHovered ? 1.2 : 1),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, iconScale, child) {
                            return Transform.scale(
                              scale: iconScale,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      card.color.withOpacity(0.3),
                                      card.color.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  card.icon,
                                  size: 40,
                                  color: card.color,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Value
                        Text(
                          card.value,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: card.color,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Label
                        Text(
                          card.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _CardData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _CardTriangleClipper extends CustomClipper<Path> {
  final int index;

  _CardTriangleClipper(this.index);

  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Alternate triangle shapes
    if (index % 3 == 0) {
      // Upward triangle
      path.moveTo(size.width * 0.5, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else if (index % 3 == 1) {
      // Polygon shard
      path.moveTo(size.width * 0.2, 0);
      path.lineTo(size.width, size.height * 0.3);
      path.lineTo(size.width * 0.8, size.height);
      path.lineTo(0, size.height * 0.7);
    } else {
      // Asymmetric triangle
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height * 0.2);
      path.lineTo(size.width * 0.7, size.height);
      path.lineTo(size.width * 0.1, size.height);
    }
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PulseTrianglePainter extends CustomPainter {
  final Color color;
  final double animation;

  _PulseTrianglePainter(this.color, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - animation))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final scale = 1 + (animation * 0.3);
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final path = Path();
    path.moveTo(centerX, centerY - (size.height * 0.4 * scale));
    path.lineTo(centerX + (size.width * 0.4 * scale), centerY + (size.height * 0.4 * scale));
    path.lineTo(centerX - (size.width * 0.4 * scale), centerY + (size.height * 0.4 * scale));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
