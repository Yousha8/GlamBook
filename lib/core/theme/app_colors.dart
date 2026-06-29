import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Glamour Palette (Based on Reference Image)
  static const Color vibrantPink = Color(0xFFE91E63);   // Primary Brand Color
  static const Color hotPink = Color(0xFFFF4081);      // Action/Button Color
  static const Color deepMagenta = Color(0xFF880E4F);  // Header / Dark Contrast
  static const Color lightPink = Color(0xFFFCE4EC);    // Card Background
  static const Color ultraLightPink = Color(0xFFFFF5F8); // Page Background
  
  static const Color white = Colors.white;
  static const Color black = Color(0xFF121212);

  // Aliases for backward compatibility with existing code
  static const Color roseGold = vibrantPink;
  static const Color lightRoseGold = hotPink;
  static const Color cream = Color(0xFFFFF1F5);
  static const Color softCream = ultraLightPink;
  static const Color mauve = hotPink;
  static const Color deepMauve = deepMagenta;
  static const Color gold = vibrantPink; // Replacing gold with pink as per image
  static const Color lightGold = lightPink;

  // Backgrounds
  static const Color background = ultraLightPink;
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = deepMagenta;
  static const Color textSecondary = Color(0xFFAD1457); // Medium Magenta
  static const Color textLight = Color(0xFFC2185B);    // Light Magenta

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Gradients (Vibrant & Strong)
  static const LinearGradient luxuryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [vibrantPink, deepMagenta],
  );

  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [hotPink, vibrantPink],
  );
}
