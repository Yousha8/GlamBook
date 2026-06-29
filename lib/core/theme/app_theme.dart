import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.vibrantPink,
        primary: AppColors.vibrantPink,
        secondary: AppColors.deepMagenta,
        tertiary: AppColors.hotPink,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      // Typography
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),

      // Button Decoration
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantPink,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.vibrantPink.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppColors.deepMagenta),
        hintStyle: TextStyle(color: AppColors.deepMagenta.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.vibrantPink.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.vibrantPink.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.vibrantPink, width: 2),
        ),
        contentPadding: const EdgeInsets.all(18),
      ),

      // Card Decoration
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: AppColors.deepMagenta.withOpacity(0.1),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // AppBar Decoration
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.deepMagenta,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        foregroundColor: AppColors.deepMagenta,
      ),
    );
  }

  // Common Shadows (More pronounced for vibrancy)
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.vibrantPink.withOpacity(0.12),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];

  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: AppColors.deepMagenta.withOpacity(0.15),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
      ];
}
