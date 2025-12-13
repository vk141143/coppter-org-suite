import 'package:flutter/material.dart';
import 'login_left_panel.dart';
import 'login_right_panel.dart';
import 'otp/otp_transition_controller.dart';
import 'otp/curved_otp_sheet.dart';
import '../../../user/screens/user_dashboard.dart';
import '../../../driver/screens/driver_main_screen.dart';
import '../../../admin/screens/admin_dashboard.dart';

class LoginWebLayout extends StatefulWidget {
  const LoginWebLayout({super.key});

  @override
  State<LoginWebLayout> createState() => _LoginWebLayoutState();
}

class _LoginWebLayoutState extends State<LoginWebLayout> {
  final _otpController = OtpTransitionController();
  String _phoneNumber = '';
  String _userType = 'Customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _otpController,
        builder: (context, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: 0,
                top: 0,
                bottom: 0,
                width: _otpController.isPanelExpanded ? screenWidth : screenWidth * 0.45,
                child: LoginLeftPanel(
                  onOtpRequested: (phone, userType) {
                    _phoneNumber = phone;
                    _userType = userType;
                    _otpController.activateOtpMode();
                  },
                ),
              ),
              Positioned(
                right: 0,
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
              if (_otpController.isSheetVisible)
                CurvedOtpSheet(
                  phoneNumber: _phoneNumber,
                  userType: _userType,
                  onVerified: () {
                    Widget dashboard;
                    if (_userType == 'Driver') {
                      dashboard = const DriverMainScreen();
                    } else if (_userType == 'Admin') {
                      dashboard = const AdminDashboard();
                    } else {
                      dashboard = const UserDashboard();
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => dashboard),
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
