import 'package:flutter/material.dart';
import '../../features/user/screens/raise_complaint_screen.dart';
import '../../features/user/screens/track_complaint_screen.dart';
import '../../features/user/screens/complaint_history_screen.dart';
import '../../core/utils/image_selector.dart';
import '../../features/raise_complaint/widgets/premium_complaint_dialog.dart';
import '../../features/instant_estimate/widgets/instant_estimate_flow.dart';

class QuickActionsWeb extends StatelessWidget {
  const QuickActionsWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  title: 'Take a Photo',
                  subtitle: 'Capture waste image',
                  icon: Icons.camera_alt,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF198754)],
                  ),
                  onTap: () async {
                    final image = await ImageSelector.pickImage(context);
                    if (image != null && context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => PremiumComplaintDialog(image: image),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  title: 'Get Instant Estimate',
                  subtitle: 'Calculate pickup cost',
                  icon: Icons.calculate,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D7A4F), Color(0xFF5A9F6E)],
                  ),
                  onTap: () => InstantEstimateFlow.show(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  title: 'Book Pickup',
                  subtitle: 'Schedule collection',
                  icon: Icons.event_available,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF198754)],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RaiseComplaintScreen())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionCard(
                  title: 'Track Driver',
                  subtitle: 'Monitor live location',
                  icon: Icons.location_on,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D7A4F), Color(0xFF5A9F6E)],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackComplaintScreen())),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          transform: _isHovered ? (Matrix4.identity()..translate(0.0, -4.0)) : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
