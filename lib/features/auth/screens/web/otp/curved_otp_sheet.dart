import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_code_input.dart';

class CurvedOtpSheet extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const CurvedOtpSheet({
    super.key,
    required this.phoneNumber,
    required this.userType,
    required this.onVerified,
    required this.onBack,
  });

  @override
  State<CurvedOtpSheet> createState() => _CurvedOtpSheetState();
}

class _CurvedOtpSheetState extends State<CurvedOtpSheet> {
  String _enteredOtp = '';
  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      if (kDebugMode) print('🧪 WEB OTP VERIFICATION: ${widget.userType}');
      if (kDebugMode) print('📱 Phone: ${widget.phoneNumber}');
      if (kDebugMode) print('🔢 OTP: $_enteredOtp');
      
      final url = Uri.parse('http://3.110.63.139:8001/api/auth/verify-login/driver');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': widget.phoneNumber, 'otp': _enteredOtp}),
      );
      
      if (kDebugMode) print('📥 Status: ${response.statusCode}');
      if (kDebugMode) print('📥 Body: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true && data['access_token'] != null) {
        if (kDebugMode) print('✅ OTP verified successfully!');
        widget.onVerified();
      } else {
        final errorMessage = data['message'] ?? data['error']?['error_message'] ?? 'Invalid OTP';
        if (kDebugMode) print('❌ OTP verification failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 0.5;

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
                    'Enter the 6-digit code sent to ${widget.phoneNumber}',
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
                    _enteredOtp = code;
                    if (kDebugMode) print('🔢 OTP entered: $code');
                  },
                ),
                const SizedBox(height: 24),
                // VERIFY BUTTON
                ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: widget.onBack,
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
