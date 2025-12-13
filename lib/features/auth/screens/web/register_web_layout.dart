import 'package:flutter/material.dart';
import 'register_form_panel.dart';
import 'login_right_panel.dart';
import 'otp/otp_transition_controller.dart';
import 'otp/curved_otp_sheet.dart';
import '../../../user/screens/user_dashboard.dart';

class RegisterWebLayout extends StatefulWidget {
  const RegisterWebLayout({super.key});

  @override
  State<RegisterWebLayout> createState() => _RegisterWebLayoutState();
}

class _RegisterWebLayoutState extends State<RegisterWebLayout> {
  final _otpController = OtpTransitionController();
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _otpController,
        builder: (context, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: screenWidth * 0.55,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _otpController.isOtpMode ? 0 : 1,
                  child: IgnorePointer(
                    ignoring: _otpController.isOtpMode,
                    child: const LoginRightPanel(),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                right: 0,
                top: 0,
                bottom: 0,
                width: _otpController.isPanelExpanded ? screenWidth : screenWidth * 0.45,
                child: RegisterFormPanel(
                  onOtpRequested: (phone) {
                    _phoneNumber = phone;
                    _otpController.activateOtpMode();
                  },
                ),
              ),
              if (_otpController.isSheetVisible)
                CurvedOtpSheet(
                  phoneNumber: _phoneNumber,
                  userType: 'user',
                  onVerified: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const UserDashboard()),
                      (route) => false,
                    );
                  },
                  onBack: () {
                    _otpController.reset();
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
