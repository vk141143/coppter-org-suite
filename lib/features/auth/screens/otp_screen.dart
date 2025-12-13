import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../user/screens/user_dashboard.dart';
import '../../driver/screens/driver_main_screen.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/customer_api_service.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String userType;
  final bool isRegistration;
  final String? email;
  final String? password;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.userType,
    this.isRegistration = false,
    this.email,
    this.password,
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
    if (kDebugMode) print('🔴 OTP SCREEN INITIALIZED for ${widget.userType}');
    if (kDebugMode) print('📱 Phone: ${widget.phoneNumber}');
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
                                    
                                    // DO NOT auto-submit - require manual button press
                                    if (kDebugMode && value.isNotEmpty) {
                                      final currentOtp = _controllers.map((c) => c.text).join();
                                      if (kDebugMode) print('🔢 Current OTP: "$currentOtp" (${currentOtp.length}/6)');
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
                        onPressed: () {
                          if (kDebugMode) print('🔴 VERIFY BUTTON TAPPED!');
                          _handleVerifyOTP();
                        },
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
    if (kDebugMode) print('\n=== OTP VERIFICATION TEST START ===');
    if (kDebugMode) print('🔴 BUTTON PRESSED - _handleVerifyOTP called!');
    if (kDebugMode) print('📱 Phone: ${widget.phoneNumber}');
    if (kDebugMode) print('👥 User Type: ${widget.userType}');
    
    if (_isLoading) {
      if (kDebugMode) print('⚠️ Already loading, returning early');
      return;
    }
    
    final otp = _controllers.map((c) => c.text).join();
    if (kDebugMode) print('🔢 Entered OTP: "$otp"');
    if (kDebugMode) print('🔢 OTP Length: ${otp.length}');
    
    if (otp.length != 6) {
      if (kDebugMode) print('❌ OTP length invalid: ${otp.length}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    // Clear any existing tokens first
    if (kDebugMode) print('🗑️ Clearing existing tokens before verification...');
    await _authService.logout();
    
    if (kDebugMode) print('🔄 Setting loading state to true...');
    setState(() => _isLoading = true);
    
    if (kDebugMode) print('\n--- CALLING API VERIFICATION ---');

    try {
      if (kDebugMode) print('🔍 Starting OTP verification: $otp for ${widget.userType}');
      
      // Force verification - no shortcuts
      if (kDebugMode) print('🔒 FORCING fresh verification - no cached tokens allowed');
      
      // DIRECT API TEST - Let's see what the backend actually returns
      if (kDebugMode) print('🧪 TESTING: Making direct API call to see backend response...');
      
      final url = Uri.parse('http://3.110.63.139:8001/api/auth/verify-login/driver');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': widget.phoneNumber, 'otp': otp}),
      );
      
      if (kDebugMode) print('🧪 DIRECT API RESULT:');
      if (kDebugMode) print('  Status: ${response.statusCode}');
      if (kDebugMode) print('  Body: ${response.body}');
      
      final directData = jsonDecode(response.body);
      if (kDebugMode) print('  Success field: ${directData['success']}');
      if (kDebugMode) print('  Has access_token: ${directData['access_token'] != null}');
      
      // Now call the service method
      if (kDebugMode) print('\n📡 Now calling _authService.verifyLogin...');
      final success = await _authService.verifyLogin(
        phoneNumber: widget.phoneNumber,
        otp: otp,
        userType: widget.userType,
      );
      if (kDebugMode) print('📥 verifyLogin returned: $success');
      
      if (kDebugMode) print('\n--- API VERIFICATION RESULT ---');
      if (kDebugMode) print('🔍 Raw verification result: $success (type: ${success.runtimeType})');
      
      if (success != true) {
        if (kDebugMode) print('❌ Verification returned false/null - throwing exception');
        if (kDebugMode) print('=== VERIFICATION FAILED - SHOULD NOT NAVIGATE ===\n');
        throw Exception('OTP verification failed');
      }
      
      if (!mounted) {
        if (kDebugMode) print('⚠️ Widget not mounted - returning early');
        return;
      }
      
      if (kDebugMode) print('\n=== VERIFICATION SUCCESS - NAVIGATING ===');
      if (kDebugMode) print('✅ SUCCESS! Navigating to dashboard...');
      _resendTimer = 0;

      final dashboard = widget.userType.toLowerCase() == 'driver'
          ? const DriverMainScreen()
          : widget.userType.toLowerCase() == 'admin'
              ? const AdminDashboard()
              : const UserDashboard();
      
      if (kDebugMode) print('🚀 Pushing dashboard route...');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dashboard),
        (route) => false,
      );
      if (kDebugMode) print('✅ Navigation completed');
      if (kDebugMode) print('=== OTP VERIFICATION TEST END ===\n');
    } catch (e) {
      if (kDebugMode) print('\n=== EXCEPTION CAUGHT ===');
      if (kDebugMode) print('❌ CAUGHT EXCEPTION IN OTP SCREEN: $e');
      if (kDebugMode) print('❌ Exception type: ${e.runtimeType}');
      if (kDebugMode) print('❌ This should prevent navigation!');
      if (kDebugMode) print('=== VERIFICATION FAILED - NO NAVIGATION ===\n');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Handle specific error cases
      if (errorMessage.toLowerCase().contains('expired')) {
        errorMessage = 'OTP has expired. Please request a new one.';
        // Auto-trigger resend for expired OTP
        setState(() {
          _canResend = true;
          _resendTimer = 0;
        });
      } else if (errorMessage.toLowerCase().contains('invalid')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
        // Clear OTP fields for invalid OTP
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
      
      if (kDebugMode) print('📱 Showing error snackbar: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: errorMessage.contains('expired') 
              ? SnackBarAction(
                  label: 'Resend',
                  textColor: Colors.white,
                  onPressed: _handleResendOTP,
                )
              : null,
        ),
      );
      if (kDebugMode) print('❌ ERROR HANDLING COMPLETED - should NOT navigate');
      if (kDebugMode) print('=== OTP VERIFICATION TEST END (ERROR) ===\n');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleResendOTP() async {
    try {
      if (kDebugMode) print('📤 Resending OTP for ${widget.userType}');
      
      await _authService.resendOTP(
        widget.phoneNumber,
        userType: widget.userType,
      );
      
      if (kDebugMode) print('✅ OTP resent successfully');
      
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