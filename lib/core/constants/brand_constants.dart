import 'package:flutter/material.dart';

/// LiftAway Brand Identity & Theme
/// 
/// Brand Style: Premium, clean, modern
/// Tagline: Fast. Simple. Reliable Waste Removal.

class BrandConstants {
  // Brand Identity
  static const String appName = 'LiftAway';
  static const String tagline = 'Fast. Simple. Reliable Waste Removal.';
  static const String fullName = 'LiftAway - Waste Management';
  
  // Color Palette
  static const Color primaryColor = Color(0xFF0F5132); // Deep Forest Green
  static const Color secondaryColor = Color(0xFFD1E7DD); // Sage Green
  static const Color accentColor = Color(0xFFFAF7F2); // Soft Beige
  static const Color textColor = Color(0xFF1F1F1F); // Dark Charcoal
  static const Color ctaGradientStart = Color(0xFF0F5132); // Deep Forest Green
  static const Color ctaGradientEnd = Color(0xFF198754); // Lighter Green
  
  // Alert Colors
  static const Color errorColor = Color(0xFFFF6F00); // Orange
  static const Color warningColor = Color(0xFFFF6F00); // Orange
  static const Color successColor = Color(0xFF0F5132); // Deep Forest Green
  
  // Gradient for CTA Buttons
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [ctaGradientStart, ctaGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: -0.5,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    color: textColor,
    height: 1.5,
  );
  
  static const TextStyle taglineStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Shadows
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
}
