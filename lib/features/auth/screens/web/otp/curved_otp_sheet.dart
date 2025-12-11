import 'package:flutter/material.dart';
import 'otp_code_input.dart';

class CurvedOtpSheet extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const CurvedOtpSheet({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 0.4;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: screenHeight, end: screenHeight - sheetHeight),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Positioned(
          left: 0,
          right: 0,
          top: value,
          bottom: 0,
          child: child!,
        );
      },
      child: ClipPath(
        clipper: CurvedTopClipper(),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: const Color(0xFF1B5E20),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verify OTP',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Enter the 6-digit code sent to $phoneNumber',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OtpCodeInput(
                  length: 6,
                  onCompleted: (code) {
                    Future.delayed(const Duration(milliseconds: 500), onVerified);
                  },
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 60);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
