import 'package:flutter/material.dart';

class AISuggestionsSection extends StatefulWidget {
  const AISuggestionsSection({super.key});

  @override
  State<AISuggestionsSection> createState() => _AISuggestionsSectionState();
}

class _AISuggestionsSectionState extends State<AISuggestionsSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> suggestions = [
    {
      'icon': Icons.home,
      'title': 'Recommended for You',
      'subtitle': 'You frequently raise Household Waste complaints',
      'match': '92%',
      'color': Colors.blue,
    },
    {
      'icon': Icons.computer,
      'title': 'E-Waste Pickup',
      'subtitle': 'Based on your recent electronics disposal',
      'match': '87%',
      'color': Colors.purple,
    },
    {
      'icon': Icons.recycling,
      'title': 'Recyclables Collection',
      'subtitle': 'Trending in your area this week',
      'match': '85%',
      'color': Colors.green,
    },
    {
      'icon': Icons.delete_sweep,
      'title': 'Bulk Waste Removal',
      'subtitle': 'Popular service for your location',
      'match': '78%',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'AI Recommendations',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) => _SuggestionCard(
                suggestion: suggestions[index],
                delay: index * 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final Map<String, dynamic> suggestion;
  final int delay;

  const _SuggestionCard({required this.suggestion, required this.delay});

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
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
        width: 320,
        margin: const EdgeInsets.only(right: 16),
        transform: _isHovered ? (Matrix4.identity()..translate(0.0, -8.0)) : Matrix4.identity(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.suggestion['color'].withOpacity(0.1),
                widget.suggestion['color'].withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.suggestion['color'].withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.08),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.suggestion['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.suggestion['icon'],
                      color: widget.suggestion['color'],
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.suggestion['match']} match',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.suggestion['title'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.suggestion['subtitle'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
