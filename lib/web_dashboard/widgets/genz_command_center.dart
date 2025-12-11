import 'dart:ui';
import 'package:flutter/material.dart';

class GenZCommandCenter extends StatefulWidget {
  const GenZCommandCenter({Key? key}) : super(key: key);

  @override
  State<GenZCommandCenter> createState() => _GenZCommandCenterState();
}

class _GenZCommandCenterState extends State<GenZCommandCenter> {
  int? _hoveredIndex;

  final List<_ActionData> _actions = [
    _ActionData(
      icon: Icons.add_alert,
      label: 'Raise Issue',
      color: const Color(0xFFFF006E),
    ),
    _ActionData(
      icon: Icons.track_changes,
      label: 'Track Pickup',
      color: const Color(0xFF3A86FF),
    ),
    _ActionData(
      icon: Icons.phone,
      label: 'Call Driver',
      color: const Color(0xFF06FFA5),
    ),
    _ActionData(
      icon: Icons.assessment,
      label: 'Eco-Score',
      color: const Color(0xFFFB5607),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_actions.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < _actions.length - 1 ? 16 : 0),
            child: _buildActionButton(index),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(int index) {
    final action = _actions[index];
    final isHovered = _hoveredIndex == index;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: isHovered ? 1.05 : 1),
          duration: const Duration(milliseconds: 200),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Stack(
            children: [
              // Ripple Effect
              if (isHovered)
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _RipplePainter(action.color, value),
                      );
                    },
                    onEnd: () => setState(() {}),
                  ),
                ),
              
              // Button
              ClipPath(
                clipper: _ActionButtonClipper(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          action.color.withOpacity(0.3),
                          action.color.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: action.color.withOpacity(isHovered ? 0.8 : 0.4),
                        width: isHovered ? 3 : 2,
                      ),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: action.color.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: isHovered ? 0.2 : 0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, warp, child) {
                            return Transform.scale(
                              scale: 1 + warp,
                              child: Icon(
                                action.icon,
                                size: 32,
                                color: action.color,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action.label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
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

class _ActionData {
  final IconData icon;
  final String label;
  final Color color;

  _ActionData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _ActionButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(12, 0);
    path.lineTo(size.width - 12, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RipplePainter extends CustomPainter {
  final Color color;
  final double animation;

  _RipplePainter(this.color, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4 * (1 - animation))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = (size.width * 0.5) * animation;

    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius + (i * 15),
        paint..color = color.withOpacity(0.3 * (1 - animation) / (i + 1)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
