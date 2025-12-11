import 'package:flutter/material.dart';

class WasteCategoryGridWeb extends StatelessWidget {
  const WasteCategoryGridWeb({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'icon': '🏠', 'name': 'Household', 'color': Color(0xFF0F5132)},
    {'icon': '♻️', 'name': 'Recyclables', 'color': Color(0xFF198754)},
    {'icon': '🌱', 'name': 'Garden', 'color': Color(0xFF28A745)},
    {'icon': '🏗️', 'name': 'C&D', 'color': Color(0xFF6C757D)},
    {'icon': '📱', 'name': 'E-Waste', 'color': Color(0xFFFF6F00)},
    {'icon': '🪑', 'name': 'Furniture', 'color': Color(0xFF8B4513)},
    {'icon': '⚠️', 'name': 'Hazardous', 'color': Color(0xFFDC3545)},
    {'icon': '🔩', 'name': 'Metal', 'color': Color(0xFF495057)},
    {'icon': '📺', 'name': 'Appliances', 'color': Color(0xFF17A2B8)},
    {'icon': '🗑️', 'name': 'Mixed Waste', 'color': Color(0xFF6C757D)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Waste Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 900 ? 4 : 3);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(
                  icon: _categories[index]['icon'],
                  name: _categories[index]['name'],
                  color: _categories[index]['color'],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String icon;
  final String name;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: 'Report ${widget.name} waste',
        child: GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? widget.color : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered ? widget.color.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            transform: _isHovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isHovered ? widget.color : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
