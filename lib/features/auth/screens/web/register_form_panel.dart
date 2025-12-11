import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../otp_screen.dart';
import '../login_screen.dart';
import '../driver_registration_screen.dart';
import '../../../../core/blocs/auth/auth_bloc.dart';
import '../../../../core/blocs/auth/auth_event.dart';
import '../../../../core/blocs/auth/auth_state.dart';
import '../../../../core/services/auth_service.dart';
import '../../../user/screens/user_dashboard.dart';

class RegisterFormPanel extends StatefulWidget {
  final Function(String)? onOtpRequested;
  
  const RegisterFormPanel({super.key, this.onOtpRequested});

  @override
  State<RegisterFormPanel> createState() => _RegisterFormPanelState();
}

class _RegisterFormPanelState extends State<RegisterFormPanel> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _selectedUserType = 'Customer';
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Join Us Today', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F1F1F))),
                      const SizedBox(height: 8),
                      Text('Create your account', style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                      const SizedBox(height: 32),
                      _buildSegmentSelector(isDark),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 400,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField(_nameController, 'Full Name', Icons.person_outline, isDark, false),
                              const SizedBox(height: 16),
                              _buildTextField(_emailController, 'Email Address', Icons.email_outlined, isDark, false, isEmail: true),
                              const SizedBox(height: 16),
                              _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, isDark, false, isPhone: true),
                              const SizedBox(height: 16),
                              _buildTextField(_addressController, 'Address', Icons.location_on_outlined, isDark, false, maxLines: 2),
                              const SizedBox(height: 16),
                              _buildTextField(_passwordController, 'Password', Icons.lock_outline, isDark, _obscurePassword, isPassword: true, onToggle: () => setState(() => _obscurePassword = !_obscurePassword)),
                              const SizedBox(height: 16),
                              _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock_outline, isDark, _obscureConfirmPassword, isConfirm: true, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                              activeColor: const Color(0xFF0F5132),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('I agree to Terms & Conditions', style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildGradientButton(isDark),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (_, animation, __) {
                                    return FadeTransition(opacity: animation, child: const LoginScreen());
                                  },
                                ),
                              );
                            },
                            child: const Text('Login', style: TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.w700, fontSize: 13)),
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
        children: ['Customer', 'Driver'].map((type) {
          final isSelected = _selectedUserType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (type == 'Driver') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverRegistrationScreen()));
                } else {
                  setState(() => _selectedUserType = type);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
                ),
                child: Text(type, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF64748B)))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, bool obscure, {bool isPassword = false, bool isConfirm = false, bool isEmail = false, bool isPhone = false, int maxLines = 1, VoidCallback? onToggle}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF212121)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFD1E7DD).withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF0F5132), size: 20),
        ),
        suffixIcon: (isPassword || isConfirm) ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: onToggle) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0F5132), width: 2)),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter ${label.toLowerCase()}';
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Please enter a valid email';
        if (isPassword && value!.length < 6) return 'Password must be at least 6 characters';
        if (isConfirm && value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildGradientButton(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (_isLoading || !_acceptTerms) ? null : _handleRegister,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: (_acceptTerms && !_isLoading) ? const LinearGradient(colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)]) : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _acceptTerms ? [BoxShadow(color: const Color(0xFF0F5132).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))] : null,
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final authService = AuthService();
      final response = await authService.registerCustomer(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        if (response['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneController.text.trim(),
                userType: 'customer',
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'OTP sent to your phone'), backgroundColor: Color(0xFF0F5132)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
