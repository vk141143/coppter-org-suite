import 'package:flutter/material.dart';

class OtpTransitionController extends ChangeNotifier {
  bool _isOtpMode = false;
  bool _isPanelExpanded = false;
  bool _isSheetVisible = false;

  bool get isOtpMode => _isOtpMode;
  bool get isPanelExpanded => _isPanelExpanded;
  bool get isSheetVisible => _isSheetVisible;

  Future<void> activateOtpMode() async {
    _isOtpMode = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 50));
    _isPanelExpanded = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _isSheetVisible = true;
    notifyListeners();
  }

  void reset() {
    _isOtpMode = false;
    _isPanelExpanded = false;
    _isSheetVisible = false;
    notifyListeners();
  }
}
