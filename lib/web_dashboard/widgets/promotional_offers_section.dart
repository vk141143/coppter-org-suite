import 'package:flutter/material.dart';
import 'dart:async';

class PromotionalOffersSection extends StatefulWidget {
  const PromotionalOffersSection({super.key});

  @override
  State<PromotionalOffersSection> createState() => _PromotionalOffersSectionState();
}

class _PromotionalOffersSectionState extends State<PromotionalOffersSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> offers = [
    {
      'title': '30% OFF',
      'subtitle': 'on Bulk Pickup',
      'description': 'Limited-time seasonal cleaning offer',
      'cta': 'Book Now',
      'gradient': [Color(0xFF0F5132), Color(0xFF198754)],
      'icon': '🚛',
    },
    {
      'title': 'FREE',
      'subtitle': 'E-Waste Collection',
      'description': 'Dispose electronics responsibly',
      'cta': 'Schedule',
      'gradient': [Color(0xFF2D7A4F), Color(0xFF5A9F6E)],
      'icon': '💻',
    },
    {
      'title': '£10 OFF',
      'subtitle': 'First Pickup',
      'description': 'New user exclusive discount',
      'cta': 'Claim Offer',
      'gradient': [Color(0xFF0F5132), Color(0xFF198754)],
      'icon': '🎁',
    },
    {
      'title': '20% OFF',
      'subtitle': 'Recyclables',
      'description': 'Go green and save more',
      'cta': 'Get Started',
      'gradient': [Color(0xFF2D7A4F), Color(0xFF5A9F6E)],
      'icon': '♻️',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentPage < offers.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Offers',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: offers.length,
            itemBuilder: (context, index) => _OfferBanner(offer: offers[index]),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              offers.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferBanner extends StatefulWidget {
  final Map<String, dynamic> offer;

  const _OfferBanner({required this.offer});

  @override
  State<_OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<_OfferBanner> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.offer['gradient']),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.offer['gradient'][0].withOpacity(0.4),
                blurRadius: _isHovered ? 30 : 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.offer['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      widget.offer['subtitle'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.offer['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isHovered
                              ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)]
                              : [],
                        ),
                        child: Text(
                          widget.offer['cta'],
                          style: TextStyle(
                            color: widget.offer['gradient'][0],
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    widget.offer['icon'],
                    style: const TextStyle(fontSize: 100),
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
