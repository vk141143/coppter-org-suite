import 'package:flutter/material.dart';
import 'dart:math' as math;

class DotRevealHero extends StatefulWidget {
  const DotRevealHero({super.key});

  @override
  State<DotRevealHero> createState() => _DotRevealHeroState();
}

class _DotRevealHeroState extends State<DotRevealHero> with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _textController;
  int _activeDot = 0;
  
  final List<Map<String, String>> _content = [
    {
      'title': 'Plan Smarter, Collect Faster.',
      'subtitle': 'Optimize routes effortlessly.',
      'cta': 'Get Started',
    },
    {
      'title': 'Track Drivers in Real-Time.',
      'subtitle': 'Total visibility across your fleet.',
      'cta': 'See Live Demo',
    },
    {
      'title': 'Insights That Drive Results.',
      'subtitle': 'Turn waste operations into intelligence.',
      'cta': 'Explore Features',
    },
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _startCarousel();
  }

  void _startCarousel() async {
    await Future.delayed(const Duration(seconds: 1));
    while (mounted) {
      await _expandController.forward();
      await _textController.forward();
      await Future.delayed(const Duration(milliseconds: 1800));
      await _textController.reverse();
      await _expandController.reverse();
      
      setState(() {
        _activeDot = (_activeDot + 1) % 3;
      });
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
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
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStaticGraphic(isMobile),
                      const SizedBox(height: 40),
                      _buildStaticText(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildStaticGraphic(isMobile)),
                      const SizedBox(width: 80),
                      Expanded(child: _buildStaticText()),
                    ],
                  ),
          ),
          
          AnimatedBuilder(
            animation: _expandController,
            builder: (context, child) {
              if (_expandController.value == 0) return const SizedBox.shrink();
              return _buildExpandingOverlay(size, isMobile);
            },
          ),
          
          Positioned(
            bottom: isMobile ? 40 : 60,
            right: isMobile ? 24 : 80,
            child: _buildDots(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticGraphic(bool isMobile) {
    return Center(
      child: Container(
        width: isMobile ? 200 : 300,
        height: isMobile ? 200 : 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F5132), width: 3),
          color: const Color(0xFFD1E7DD).withOpacity(0.3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isMobile ? 120 : 180,
              height: isMobile ? 120 : 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F5132).withOpacity(0.1),
              ),
            ),
            const Icon(Icons.eco, size: 80, color: Color(0xFF0F5132)),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'LiftAway',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F5132),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Smart Waste Management\nfor Modern Cities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1F1F1F).withOpacity(0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandingOverlay(Size size, bool isMobile) {
    final progress = Curves.easeInOutCubic.transform(_expandController.value);
    final dotPositions = _getDotPositions(size, isMobile);
    final startPos = dotPositions[_activeDot];
    
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final radius = 10 + (maxRadius * progress);

    return Positioned.fill(
      child: ClipPath(
        clipper: _CircleRevealClipper(
          center: startPos,
          radius: radius,
        ),
        child: Container(
          color: const Color(0xFFFAF7F2),
          child: Center(
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                final textProgress = Curves.easeOut.transform(_textController.value);
                return Opacity(
                  opacity: textProgress,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - textProgress)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _content[_activeDot]['title']!,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F5132),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _content[_activeDot]['subtitle']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F1F1F).withOpacity(0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F5132),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: Text(
                              _content[_activeDot]['cta']!,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        ),
      ),
    );
  }

  Widget _buildDots(bool isMobile) {
    return isMobile
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _buildDot(i),
            )),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildDot(i),
            )),
          );
  }

  Widget _buildDot(int index) {
    final isActive = _activeDot == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeDot = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0F5132),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFD1E7DD).withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  List<Offset> _getDotPositions(Size size, bool isMobile) {
    final baseX = size.width - (isMobile ? 36 : 92);
    final baseY = size.height - (isMobile ? 52 : 72);
    
    if (isMobile) {
      return [
        Offset(baseX, baseY - 36),
        Offset(baseX, baseY - 18),
        Offset(baseX, baseY),
      ];
    } else {
      return [
        Offset(baseX - 32, baseY),
        Offset(baseX - 16, baseY),
        Offset(baseX, baseY),
      ];
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircleRevealClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
