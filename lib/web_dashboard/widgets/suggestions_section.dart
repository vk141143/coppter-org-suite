import 'dart:async';
import 'package:flutter/material.dart';

class SuggestionsSection extends StatefulWidget {
  const SuggestionsSection({super.key});

  @override
  State<SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends State<SuggestionsSection> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _suggestions = [
    {
      'title': 'Recycle More',
      'subtitle': 'Earn rewards by recycling',
      'image': 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
      'color': Colors.green,
    },
    {
      'title': 'Schedule Pickup',
      'subtitle': 'Book your next pickup today',
      'image': 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
      'color': Colors.blue,
    },
    {
      'title': 'E-Waste Disposal',
      'subtitle': 'Safely dispose electronics',
      'image': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400',
      'color': Colors.orange,
    },
    {
      'title': 'Composting Tips',
      'subtitle': 'Learn to compost at home',
      'image': 'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?w=400',
      'color': Colors.brown,
    },
    {
      'title': 'Bulk Waste',
      'subtitle': 'Dispose large items easily',
      'image': 'https://images.unsplash.com/photo-1604328698692-f76ea9498e76?w=400',
      'color': Colors.purple,
    },
    {
      'title': 'Green Living',
      'subtitle': 'Tips for sustainable lifestyle',
      'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=400',
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 1) {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions for You',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 2,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, pageIndex) {
              final startIndex = pageIndex * 3;
              return Row(
                children: List.generate(3, (index) {
                  final suggestionIndex = startIndex + index;
                  if (suggestionIndex >= _suggestions.length) {
                    return const Expanded(child: SizedBox());
                  }
                  final suggestion = _suggestions[suggestionIndex];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < 2 ? 16 : 0,
                      ),
                      child: _buildSuggestionCard(
                        context,
                        suggestion['title'],
                        suggestion['subtitle'],
                        suggestion['image'],
                        suggestion['color'],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(2, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    String title,
    String subtitle,
    String imageUrl,
    Color overlayColor,
  ) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: overlayColor.withOpacity(0.3),
                child: Icon(Icons.image, size: 50, color: overlayColor),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    overlayColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: overlayColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
