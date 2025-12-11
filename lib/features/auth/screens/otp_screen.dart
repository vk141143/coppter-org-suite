import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../user/screens/user_dashboard.dart';
import '../../driver/screens/driver_main_screen.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../../core/services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final bool isRegistration;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.userType,
    this.isRegistration = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWeb = MediaQuery.of(context).size.width > 600;
                  return Container(
                    constraints: BoxConstraints(maxWidth: isWeb ? 500 : double.infinity),
                    child: Column(
                      children: [
                const SizedBox(height: 40),
                
                // Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.sms_outlined,
                    color: theme.colorScheme.primary,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title and Description
                Text(
                  'Verify Your Phone',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // OTP Input
                CustomCard(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final availableWidth = constraints.maxWidth - 40;
                          final boxSize = (availableWidth / 6 - 2).clamp(35.0, 50.0);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) {
                              return Container(
                                width: boxSize,
                                height: boxSize,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      CustomButton(
                        text: 'Verify OTP',
                        isLoading: _isLoading,
                        onPressed: _handleVerifyOTP,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Resend OTP
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth > 400 ? 24 : 8,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Didn't receive code?",
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: _canResend ? _handleResendOTP : null,
                            child: Text(
                              _canResend ? 'Resend' : 'Resend in ${_resendTimer}s',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String endpoint;
      if (widget.userType.toLowerCase() == 'admin') {
        endpoint = widget.isRegistration ? '/auth/verify/admin' : '/auth/verify-login/admin';
      } else if (widget.userType.toLowerCase() == 'driver') {
        endpoint = '/auth/verify/driver';
      } else {
        endpoint = widget.isRegistration ? '/auth/verify-register-otp/' : '/auth/verify-login-otp/';
      }
      
      print('🔐 Verifying OTP for ${widget.userType} at $endpoint');
      
      final response = await _authService.verifyOTP(
        widget.phoneNumber,
        otp,
        endpoint,
        userType: widget.userType,
      );
      
      print('✅ OTP verified successfully');
      print('📦 Response: $response');
      
      // Verify token was saved
      final savedToken = await _authService.getToken();
      print('🔍 Token check after verification: ${savedToken != null ? "Token exists (${savedToken.length} chars)" : "NO TOKEN"}');

      if (!mounted) return;

      Widget dashboard;
      switch (widget.userType.toLowerCase()) {
        case 'driver':
          dashboard = const DriverMainScreen();
          break;
        case 'admin':
          dashboard = const AdminDashboard();
          break;
        default:
          dashboard = const UserDashboard();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => dashboard),
        (route) => false,
      );
    } catch (e) {
      print('❌ OTP verification failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResendOTP() async {
    try {
      await _authService.resendOTP(
        widget.phoneNumber,
        userType: widget.userType,
      );
      
      if (!mounted) return;
      
      setState(() {
        _canResend = false;
        _resendTimer = 30;
      });
      _startTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _authService.dispose();
    super.dispose();
  }
}