import 'package:flutter/material.dart';
import '../../../core/constants/brand_colors.dart';

class CancelAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const CancelAnimation({super.key, required this.onComplete});

  @override
  State<CancelAnimation> createState() => _CancelAnimationState();
}

class _CancelAnimationState extends State<CancelAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _showCheck = true);
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showCheck)
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 5, color: BrandColors.primaryGreen),
                )
              else
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: BrandColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                _showCheck ? 'Cancelled!' : 'Cancelling...',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
