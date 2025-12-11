import 'package:flutter/material.dart';
import 'dart:math' as math;

class Support2025Web extends StatefulWidget {
  const Support2025Web({super.key});

  @override
  State<Support2025Web> createState() => _Support2025WebState();
}

class _Support2025WebState extends State<Support2025Web> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  late AnimationController _blobController;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Account & Login', 'desc': 'Access and authentication help', 'icon': Icons.person_outline, 'color': Color(0xFF6366F1), 'issues': 7},
    {'title': 'Waste Pickup', 'desc': 'Schedule and manage pickups', 'icon': Icons.delete_outline, 'color': Color(0xFF10B981), 'issues': 12},
    {'title': 'Tracking & Status', 'desc': 'Monitor your requests', 'icon': Icons.location_on_outlined, 'color': Color(0xFFF59E0B), 'issues': 8},
    {'title': 'Payment & Billing', 'desc': 'Charges and refunds', 'icon': Icons.credit_card, 'color': Color(0xFFEC4899), 'issues': 6},
    {'title': 'App & Technical', 'desc': 'Technical issues and bugs', 'icon': Icons.phone_android, 'color': Color(0xFF8B5CF6), 'issues': 9},
    {'title': 'Safety & Behavior', 'desc': 'Report safety concerns', 'icon': Icons.security, 'color': Color(0xFFEF4444), 'issues': 5},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(),
                const SizedBox(height: 80),
                _buildCategoryGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          _buildAIFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFF5F7FA), Colors.white],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, child) {
              return CustomPaint(
                painter: _BlobPainter(_blobController.value),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 28),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          Text(
                            'Support Center',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B5E20),
                              letterSpacing: -2,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'What can we help you solve today?',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildSmartSearchBar(),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _isSearchFocused ? Color(0xFF1B5E20).withOpacity(0.2) : Colors.black.withOpacity(0.08),
            blurRadius: _isSearchFocused ? 40 : 20,
            offset: Offset(0, _isSearchFocused ? 12 : 8),
          ),
        ],
        border: Border.all(
          color: _isSearchFocused ? Color(0xFF1B5E20) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSearchFocused ? Color(0xFF76FF03).withOpacity(0.2) : Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search,
                size: 28,
                color: _isSearchFocused ? Color(0xFF1B5E20) : Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search for help, issues, or topics...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: () => setState(() => _searchController.clear()),
                icon: Icon(Icons.close, color: Color(0xFF94A3B8)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by Category',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a category to explore solutions',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 32,
                mainAxisSpacing: 32,
                childAspectRatio: 1.3,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) => _buildCategoryCard(_categories[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return _HoverCard(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Color(0xFFE2E8F0), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category['color'], category['color'].withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: category['color'].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(category['icon'], size: 36, color: Colors.white),
              ),
              const Spacer(),
              Text(
                category['title'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['desc'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${category['issues']} topics',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: category['color'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIFloatingButton() {
    return Positioned(
      right: 32,
      bottom: 32,
      child: _HoverCard(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1B5E20).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.support_agent, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.08),
                blurRadius: _isHovered ? 30 : 15,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double animation;
  _BlobPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    final blob1 = Offset(
      size.width * 0.2 + math.sin(animation * 2 * math.pi) * 100,
      size.height * 0.3 + math.cos(animation * 2 * math.pi) * 80,
    );
    paint.color = Color(0xFF76FF03).withOpacity(0.15);
    canvas.drawCircle(blob1, 200, paint);

    final blob2 = Offset(
      size.width * 0.8 + math.cos(animation * 2 * math.pi + 1) * 120,
      size.height * 0.6 + math.sin(animation * 2 * math.pi + 1) * 100,
    );
    paint.color = Color(0xFF1B5E20).withOpacity(0.1);
    canvas.drawCircle(blob2, 250, paint);

    final blob3 = Offset(
      size.width * 0.5 + math.sin(animation * 2 * math.pi + 2) * 80,
      size.height * 0.5 + math.cos(animation * 2 * math.pi + 2) * 60,
    );
    paint.color = Color(0xFF76FF03).withOpacity(0.08);
    canvas.drawCircle(blob3, 180, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) => true;
}
