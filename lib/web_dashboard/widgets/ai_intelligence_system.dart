import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'progress_journey_animation_widget.dart';

class AIIntelligenceSystem extends StatefulWidget {
  const AIIntelligenceSystem({super.key});

  @override
  State<AIIntelligenceSystem> createState() => _AIIntelligenceSystemState();
}

class _AIIntelligenceSystemState extends State<AIIntelligenceSystem> with TickerProviderStateMixin {
  bool _showDrawer = false;
  late AnimationController _pulseController;
  late AnimationController _drawerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _drawerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() => _showDrawer = !_showDrawer);
    if (_showDrawer) {
      _drawerController.forward();
    } else {
      _drawerController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'AI Intelligence System',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _toggleDrawer,
              icon: Icon(_showDrawer ? Icons.close : Icons.auto_awesome),
              label: Text(_showDrawer ? 'Close Insights' : 'View AI Insights'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            Column(
              children: [
                _IntelligenceTiles(),
                const SizedBox(height: 32),
                const ProgressJourneyAnimationWidget(autoPlay: true),
                const SizedBox(height: 32),
                _AIBrainMap(pulseController: _pulseController),
              ],
            ),
            if (_showDrawer)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: _AISideDrawer(animation: _drawerController),
              ),
          ],
        ),
      ],
    );
  }
}

class _IntelligenceTiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _IntelligenceTile(
              icon: Icons.currency_rupee,
              title: 'Predicted Price',
              value: '₹285',
              subtitle: '+12% from avg',
              gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
              sparkline: true,
            ),
            _IntelligenceTile(
              icon: Icons.category,
              title: 'Recommended Category',
              value: 'Household',
              subtitle: '94% confidence',
              gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
            ),
            _IntelligenceTile(
              icon: Icons.schedule,
              title: 'Best Pickup Time',
              value: '10:30 AM',
              subtitle: 'Low traffic period',
              gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
            ),
            _IntelligenceTile(
              icon: Icons.local_shipping,
              title: 'Driver Availability',
              value: '3 nearby',
              subtitle: 'Avg ETA: 8 min',
              gradient: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
              liveIndicator: true,
            ),
          ],
        );
      },
    );
  }
}

class _IntelligenceTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final List<Color> gradient;
  final bool sparkline;
  final bool liveIndicator;

  const _IntelligenceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    this.sparkline = false,
    this.liveIndicator = false,
  });

  @override
  State<_IntelligenceTile> createState() => _IntelligenceTileState();
}

class _IntelligenceTileState extends State<_IntelligenceTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 240,
        padding: const EdgeInsets.all(20),
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient.map((c) => c.withOpacity(0.1)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.gradient[0].withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? widget.gradient[0].withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: _isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.gradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                if (widget.liveIndicator)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.gradient[0],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.sparkline)
                  Icon(Icons.trending_up, color: widget.gradient[0], size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBrainMap extends StatelessWidget {
  final AnimationController pulseController;

  const _AIBrainMap({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0E27) : const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _NodeConnectionPainter(isDark: isDark),
          ),
          Center(
            child: _AINode(
              label: 'AI Core',
              icon: Icons.psychology,
              color: Color(0xFF667EEA),
              size: 80,
              isPulsing: true,
              pulseController: pulseController,
            ),
          ),
          Positioned(
            left: 60,
            top: 80,
            child: _AINode(label: 'Category\nMatch', icon: Icons.category, color: Color(0xFF11998E), size: 60),
          ),
          Positioned(
            right: 60,
            top: 80,
            child: _AINode(label: 'Weight\nEstimate', icon: Icons.scale, color: Color(0xFFFF6B6B), size: 60),
          ),
          Positioned(
            left: 80,
            bottom: 60,
            child: _AINode(label: 'Traffic\nAnalysis', icon: Icons.traffic, color: Color(0xFFFF9800), size: 60),
          ),
          Positioned(
            right: 80,
            bottom: 60,
            child: _AINode(label: 'Price\nOptimizer', icon: Icons.attach_money, color: Color(0xFF4E54C8), size: 60),
          ),
        ],
      ),
    );
  }
}

class _NodeConnectionPainter extends CustomPainter {
  final bool isDark;

  _NodeConnectionPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.cyan : Colors.blue).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    
    canvas.drawLine(center, Offset(60 + 30, 80 + 30), paint);
    canvas.drawLine(center, Offset(size.width - 60 - 30, 80 + 30), paint);
    canvas.drawLine(center, Offset(80 + 30, size.height - 60 - 30), paint);
    canvas.drawLine(center, Offset(size.width - 80 - 30, size.height - 60 - 30), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AINode extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double size;
  final bool isPulsing;
  final AnimationController? pulseController;

  const _AINode({
    required this.label,
    required this.icon,
    required this.color,
    required this.size,
    this.isPulsing = false,
    this.pulseController,
  });

  @override
  State<_AINode> createState() => _AINodeState();
}

class _AINodeState extends State<_AINode> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isPulsing && widget.pulseController != null
                ? AnimatedBuilder(
                    animation: widget.pulseController!,
                    builder: (context, child) {
                      return Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.5),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.6 * (1 - widget.pulseController!.value)),
                              blurRadius: 30 * widget.pulseController!.value,
                              spreadRadius: 10 * widget.pulseController!.value,
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.4),
                      );
                    },
                  )
                : Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [widget.color, widget.color.withOpacity(0.7)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isHovered ? widget.color.withOpacity(0.5) : widget.color.withOpacity(0.3),
                          blurRadius: _isHovered ? 20 : 10,
                          spreadRadius: _isHovered ? 5 : 2,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.4),
                  ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AISideDrawer extends StatelessWidget {
  final AnimationController animation;

  const _AISideDrawer({required this.animation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: Container(
        width: 380,
        height: 700,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D2E).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Smart AI Insights',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DrawerSection(
                      title: 'Predicted Price',
                      child: Column(
                        children: [
                          Text(
                            '₹285',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ExpandableReasoning(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DrawerSection(
                      title: 'Category Recommendation',
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF11998E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.home, color: Color(0xFF11998E)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Household Waste', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                Text('94% confidence', style: theme.textTheme.bodySmall?.copyWith(color: Color(0xFF11998E))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DrawerSection(
                      title: 'Best Pickup Time',
                      child: Text('Tomorrow at 10:30 AM\nLow traffic, optimal route', style: theme.textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 20),
                    _DrawerSection(
                      title: 'Driver Availability',
                      child: Text('3 drivers nearby\nAverage ETA: 8 minutes', style: theme.textTheme.bodyMedium),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF667EEA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Apply Suggestions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DrawerSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ExpandableReasoning extends StatefulWidget {
  @override
  State<_ExpandableReasoning> createState() => _ExpandableReasoningState();
}

class _ExpandableReasoningState extends State<_ExpandableReasoning> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Why this price?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReasonItem('Base rate: ₹180'),
                _ReasonItem('Distance (3.2 km): ₹45'),
                _ReasonItem('Weight estimate: ₹40'),
                _ReasonItem('Peak time: ₹20'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ReasonItem extends StatelessWidget {
  final String text;

  const _ReasonItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
