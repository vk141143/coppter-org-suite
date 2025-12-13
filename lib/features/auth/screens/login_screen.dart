import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../user/screens/user_dashboard.dart';
import '../../driver/screens/driver_dashboard.dart';
import '../../admin/screens/admin_dashboard.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';
import 'customer_email_login_screen.dart';
import 'web/login_web_layout.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedUserType = 'Customer';

  final List<String> _userTypes = ['Customer', 'Driver', 'Admin'];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return const LoginWebLayout();
    }
    
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD1E7DD),
              Color(0xFFFAF7F2),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            'assets/images/logo.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0F5132), Color(0xFF2D7A4F)],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.recycling,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to LiftAway',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fast. Simple. Reliable Waste Removal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF0F5132),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Login Form
                CustomCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // User Type Selector
                        DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          decoration: const InputDecoration(
                            labelText: 'Login as',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: _userTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Phone Field
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: 'Enter your mobile number',
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your mobile number';
                            }
                            if (value!.length < 10) {
                              return 'Please enter a valid mobile number';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Login Button
                        CustomButton(
                          text: 'Send OTP',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Email Login Link for Customers
                if (_selectedUserType == 'Customer')
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerEmailLoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.email),
                      label: const Text('Login with Email & Password'),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
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

  void _handleLogin() async {
    if (kDebugMode) print('🔴 LOGIN BUTTON PRESSED!');
    
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) print('❌ Form validation failed');
      return;
    }

    if (kDebugMode) print('🔴 Setting loading state...');
    setState(() => _isLoading = true);

    try {
      if (kDebugMode) print('🔴 Creating AuthService...');
      final authService = AuthService();
      
      if (kDebugMode) print('🔴 Calling login API...');
      final result = await authService.login(
        _phoneController.text,
        _selectedUserType,
        password: _selectedUserType == 'Admin' ? 'admin123' : null,
      );
      
      if (kDebugMode) print('✅ Login API completed: $result');
      if (kDebugMode) print('🔴 CHECKPOINT 1: After API call');
      if (kDebugMode) print('🔴 CHECKPOINT 2: About to check mounted state');
      if (kDebugMode) print('🔍 About to navigate to OTP screen...');
      
      if (mounted) {
        if (kDebugMode) print('🔴 Widget is mounted, proceeding...');
        setState(() => _isLoading = false);
        if (kDebugMode) print('🚀 Navigating to OTP screen for $_selectedUserType');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (kDebugMode) print('🏗️ Building OTP screen...');
              return OTPScreen(
                phoneNumber: _phoneController.text,
                userType: _selectedUserType,
              );
            },
          ),
        );
        if (kDebugMode) print('✅ Navigation call completed');
      } else {
        if (kDebugMode) print('❌ Widget not mounted - cannot navigate');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print('❌ Login error: $e');
      if (kDebugMode) print('❌ Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    if (kDebugMode) print('🔴 _handleLogin method completed');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}