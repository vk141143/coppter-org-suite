// Translatable button wrapper for CustomButton
import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'auto_text.dart';

class TranslatableButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const TranslatableButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      icon: icon,
    );
  }
}
