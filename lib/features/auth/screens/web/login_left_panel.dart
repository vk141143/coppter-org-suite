import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../otp_screen.dart';
import '../register_screen.dart';
import '../../../../core/services/auth_service.dart';

class LoginLeftPanel extends StatefulWidget {
  final Function(String, String)? onOtpRequested;
  
  const LoginLeftPanel({super.key, this.onOtpRequested});

  @override
  State<LoginLeftPanel> createState() => _LoginLeftPanelState();
}

class _LoginLeftPanelState extends State<LoginLeftPanel> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedUserType = 'Customer';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [Color(0xFF0F1419), Color(0xFF1E1E1E)] : [Color(0xFFD1E7DD), Color(0xFFFAF7F2)],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFF0F5132).withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: const Icon(Icons.recycling, color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                      const SizedBox(height: 8),
                      Text('Sign in to continue', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                      const SizedBox(height: 40),
                      _buildSegmentSelector(isDark),
                      const SizedBox(height: 24),
                      _buildGlassTextField(isDark),
                      const SizedBox(height: 32),
                      _buildGradientButton(isDark),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ", style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 400),
                                  pageBuilder: (_, animation, __) {
                                    return SlideTransition(
                                      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
                                      child: FadeTransition(opacity: animation, child: const RegisterScreen()),
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text('Sign Up', style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['Customer', 'Driver', 'Admin'].map((type) {
          final isSelected = _selectedUserType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedUserType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
                ),
                child: Text(
                  type,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlassTextField(bool isDark) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        hintText: 'Enter your mobile number',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1E7DD).withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone_outlined, color: Color(0xFF0F5132), size: 20),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F5132), width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter your mobile number';
        if (value!.length < 10) return 'Please enter a valid mobile number';
        return null;
      },
    );
  }

  Widget _buildGradientButton(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isLoading ? null : _handleLogin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final authService = AuthService();
      await authService.login(
        _phoneController.text,
        _selectedUserType,
        password: _selectedUserType == 'Admin' ? 'admin123' : null,
      );
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (widget.onOtpRequested != null) {
        widget.onOtpRequested!(_phoneController.text, _selectedUserType);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(phoneNumber: _phoneController.text, userType: _selectedUserType)));
      }
    }
  }
}
