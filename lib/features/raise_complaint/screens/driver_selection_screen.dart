import 'dart:async';
import 'package:flutter/material.dart';
import '../../user/screens/track_complaint_screen.dart';

class DriverSelectionScreen extends StatefulWidget {
  final double price;
  final String location;

  const DriverSelectionScreen({
    super.key,
    required this.price,
    required this.location,
  });

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Simulate searching for drivers then auto-navigate
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TrackComplaintScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Driver'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _buildSearchingView(theme),
    );
  }

  Widget _buildSearchingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3 * _pulseController.value),
                      blurRadius: 40 * _pulseController.value,
                      spreadRadius: 20 * _pulseController.value,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_shipping,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Searching for nearby drivers...',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Finding the best driver for you',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
