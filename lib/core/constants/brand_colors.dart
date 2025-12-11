import 'package:flutter/material.dart';

class BrandColors {
  // LiftAway Brand Colors
  static const Color primaryGreen = Color(0xFF0F5132); // Deep Forest Green
  static const Color secondaryGreen = Color(0xFFD1E7DD); // Sage Green
  static const Color accentBeige = Color(0xFFFAF7F2); // Soft Beige
  static const Color textDark = Color(0xFF1F1F1F); // Dark Charcoal
  
  // Gradient for CTA buttons
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [Color(0xFF0F5132), Color(0xFF198754)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
