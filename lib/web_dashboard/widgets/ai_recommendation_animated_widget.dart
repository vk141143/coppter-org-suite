import 'package:flutter/material.dart';
import 'dart:math' as math;

class AiRecommendationAnimatedWidget extends StatelessWidget {
  const AiRecommendationAnimatedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'AI Recommendations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return Column(
                children: [
                  _SmartPickupCard(),
                  const SizedBox(height: 16),
                  _AIPriceCard(),
                  const SizedBox(height: 16),
                  _PatternInsightCard(),
                  const SizedBox(height: 16),
                  _EcoTipsCard(),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: _SmartPickupCard()),
                const SizedBox(width: 16),
                Expanded(child: _AIPriceCard()),
                const SizedBox(width: 16),
                Expanded(child: _PatternInsightCard()),
                const SizedBox(width: 16),
                Expanded(child: _EcoTipsCard()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SmartPickupCard extends StatefulWidget {
  @override
  State<_SmartPickupCard> createState() => _SmartPickupCardState();
}

class _SmartPickupCardState extends State<_SmartPickupCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedRecommendationCard(
      title: 'Smart Pickup',
      description: 'Tomorrow at 10:30 AM',
      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
      isHovered: _isHovered,
      isHighlighted: true,
      onHover: (hover) => setState(() => _isHovered = hover),
      onTap: () {},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _TruckAnimationPainter(_controller.value, _isHovered),
            size: const Size(double.infinity, 120),
          );
        },
      ),
    );
  }
}

class _TruckAnimationPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _TruckAnimationPainter(this.progress, this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final truckX = size.width * 0.1 + (size.width * 0.6 * progress);
    final workerX = truckX + 40;

    // Cityscape background
    final buildingPaint = Paint()..color = Colors.white.withOpacity(0.1);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * 60.0, size.height * 0.3, 40, size.height * 0.4),
        buildingPaint,
      );
    }

    // Truck body
    final truckPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(truckX, size.height * 0.6, 50, 25),
        const Radius.circular(4),
      ),
      truckPaint,
    );

    // Truck wheels
    final wheelPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(truckX + 15, size.height * 0.85 + 5), 6, wheelPaint);
    canvas.drawCircle(Offset(truckX + 40, size.height * 0.85 + 5), 6, wheelPaint);

    // Headlights (glow when hovered)
    if (isHovered) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(truckX + 50, size.height * 0.7), 4, glowPaint);
    }

    // Worker
    final workerPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(Offset(workerX, size.height * 0.65), 8, workerPaint);
    canvas.drawLine(
      Offset(workerX, size.height * 0.73),
      Offset(workerX, size.height * 0.85),
      workerPaint..strokeWidth = 3,
    );

    // Thumbs up (when progress > 0.7)
    if (progress > 0.7) {
      final thumbPaint = Paint()..color = Colors.greenAccent.withOpacity(0.8);
      canvas.drawCircle(Offset(workerX + 15, size.height * 0.6), 6, thumbPaint);
    }

    // Badge pulse
    if (isHovered) {
      final badgePaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.3 * (1 - (progress % 0.5) * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.3),
        15 + (10 * (progress % 0.5) * 2),
        badgePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AIPriceCard extends StatefulWidget {
  @override
  State<_AIPriceCard> createState() => _AIPriceCardState();
}

class _AIPriceCardState extends State<_AIPriceCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedRecommendationCard(
      title: 'AI Pricing',
      description: '₹285 estimated',
      gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
      isHovered: _isHovered,
      onHover: (hover) => setState(() => _isHovered = hover),
      onTap: () {},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PricingAnimationPainter(_controller.value, _isHovered),
            size: const Size(double.infinity, 120),
          );
        },
      ),
    );
  }
}

class _PricingAnimationPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _PricingAnimationPainter(this.progress, this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    // Floating coins
    for (int i = 0; i < 5; i++) {
      final coinProgress = (progress + i * 0.2) % 1.0;
      final x = size.width * 0.2 + i * 40;
      final y = size.height * 0.7 - (coinProgress * size.height * 0.4);
      final rotation = isHovered ? coinProgress * math.pi * 2 : 0.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final coinPaint = Paint()..color = Colors.amber.withOpacity(0.8 * (1 - coinProgress));
      canvas.drawCircle(Offset.zero, 8, coinPaint);
      canvas.drawCircle(Offset.zero, 5, Paint()..color = Colors.white.withOpacity(0.3));

      canvas.restore();
    }

    // Character with tablet
    final charPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), 12, charPaint);

    // Tablet
    final tabletPaint = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.6, 30, 20),
        const Radius.circular(2),
      ),
      tabletPaint,
    );

    // Tablet glow when hovered
    if (isHovered) {
      final glowPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.65, size.height * 0.6, 30, 20),
          const Radius.circular(2),
        ),
        glowPaint,
      );
    }

    // Graph curve
    final graphPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.8);
    for (double i = 0; i <= progress; i += 0.1) {
      final x = size.width * 0.1 + (size.width * 0.4 * i);
      final y = size.height * 0.8 - (size.height * 0.3 * i);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, graphPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PatternInsightCard extends StatefulWidget {
  @override
  State<_PatternInsightCard> createState() => _PatternInsightCardState();
}

class _PatternInsightCardState extends State<_PatternInsightCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedRecommendationCard(
      title: 'Pattern Insights',
      description: 'Household waste trend',
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      isHovered: _isHovered,
      onHover: (hover) => setState(() => _isHovered = hover),
      onTap: () {},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PatternAnimationPainter(_controller.value, _isHovered),
            size: const Size(double.infinity, 120),
          );
        },
      ),
    );
  }
}

class _PatternAnimationPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _PatternAnimationPainter(this.progress, this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    // Hologram cube
    final cubeSize = isHovered ? 35.0 : 30.0;
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.5;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(progress * 2 * math.pi);

    final cubePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw cube wireframe
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: cubeSize, height: cubeSize), cubePaint);
    canvas.drawLine(Offset(-cubeSize / 2, -cubeSize / 2), Offset(-cubeSize / 3, -cubeSize / 3), cubePaint);
    canvas.drawLine(Offset(cubeSize / 2, -cubeSize / 2), Offset(cubeSize / 3, -cubeSize / 3), cubePaint);

    canvas.restore();

    // Orbiting icons
    final icons = ['📄', '🧴', '🍽️'];
    final orbitSpeed = isHovered ? 1.5 : 1.0;
    for (int i = 0; i < icons.length; i++) {
      final angle = (progress * orbitSpeed + i * (2 * math.pi / 3)) * 2 * math.pi;
      final radius = 50.0;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(text: icons[i], style: const TextStyle(fontSize: 20)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, y - 10));
    }

    // Scan beam
    final beamY = size.height * progress;
    final beamPaint = Paint()
      ..color = (isHovered ? Colors.cyanAccent : Colors.blueAccent).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(Offset(0, beamY), Offset(size.width, beamY), beamPaint..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EcoTipsCard extends StatefulWidget {
  @override
  State<_EcoTipsCard> createState() => _EcoTipsCardState();
}

class _EcoTipsCardState extends State<_EcoTipsCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedRecommendationCard(
      title: 'Eco Tips',
      description: 'Reduce plastic by 30%',
      gradient: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
      isHovered: _isHovered,
      onHover: (hover) => setState(() => _isHovered = hover),
      onTap: () {},
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _EcoAnimationPainter(_controller.value, _isHovered),
            size: const Size(double.infinity, 120),
          );
        },
      ),
    );
  }
}

class _EcoAnimationPainter extends CustomPainter {
  final double progress;
  final bool isHovered;

  _EcoAnimationPainter(this.progress, this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    // Eco buddy character
    final buddyPaint = Paint()..color = Colors.greenAccent.withOpacity(0.8);
    final buddyX = size.width * 0.7;
    final buddyY = size.height * 0.6;

    // Head
    canvas.drawCircle(Offset(buddyX, buddyY), 15, buddyPaint);

    // Wave animation when hovered
    if (isHovered) {
      final armAngle = math.sin(progress * 4 * math.pi) * 0.5;
      canvas.save();
      canvas.translate(buddyX + 15, buddyY);
      canvas.rotate(armAngle);
      canvas.drawLine(Offset.zero, const Offset(10, -10), buddyPaint..strokeWidth = 3);
      canvas.restore();
    }

    // Growing plants
    final plantHeight = isHovered ? 40.0 + (20 * progress) : 40.0;
    final plantPaint = Paint()..color = Colors.green.withOpacity(0.7)..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final x = size.width * 0.2 + i * 30;
      canvas.drawLine(
        Offset(x, size.height * 0.8),
        Offset(x, size.height * 0.8 - plantHeight),
        plantPaint,
      );

      // Leaves
      canvas.drawCircle(Offset(x - 5, size.height * 0.8 - plantHeight + 10), 5, Paint()..color = Colors.lightGreen.withOpacity(0.7));
      canvas.drawCircle(Offset(x + 5, size.height * 0.8 - plantHeight + 10), 5, Paint()..color = Colors.lightGreen.withOpacity(0.7));
    }

    // Falling leaves
    for (int i = 0; i < 4; i++) {
      final leafProgress = (progress + i * 0.25) % 1.0;
      final x = size.width * 0.3 + i * 40 + math.sin(leafProgress * math.pi * 2) * 20;
      final y = leafProgress * size.height;

      final leafPaint = Paint()..color = Colors.lightGreen.withOpacity(0.6 * (1 - leafProgress));
      canvas.drawCircle(Offset(x, y), 4, leafPaint);
    }

    // Glow effect when hovered
    if (isHovered) {
      final glowPaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 60, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnimatedRecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Color> gradient;
  final bool isHovered;
  final bool isHighlighted;
  final Function(bool) onHover;
  final VoidCallback onTap;
  final Widget child;

  const _AnimatedRecommendationCard({
    required this.title,
    required this.description,
    required this.gradient,
    required this.isHovered,
    this.isHighlighted = false,
    required this.onHover,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 200,
          padding: const EdgeInsets.all(20),
          transform: isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHighlighted
                  ? gradient[0].withOpacity(0.5)
                  : gradient[0].withOpacity(0.2),
              width: isHighlighted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered ? gradient[0].withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: gradient[0],
                    ),
                  ),
                  if (isHighlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: gradient[0].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Recommended',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: gradient[0],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
