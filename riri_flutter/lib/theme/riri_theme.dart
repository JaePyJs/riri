import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiriTheme {
  // Brand Color Palettes (Rich HSL tailored dark theme)
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF252538);
  static const Color primaryPurple = Color(0xFF7C5CBF);
  static const Color secondaryAmber = Color(0xFFF5A623);
  static const Color offWhite = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0B0C5);
  static const Color textMuted = Color(0xFF707085);
  static const Color hotPink = Color(0xFFFF6B9D);
  static const Color dangerRed = Color(0xFFFF4D4D);
  static const Color successGreen = Color(0xFF2ECC71);

  // Brand Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [hotPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [secondaryAmber, Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF24243A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Modern Gen Z Typography using Outfit & Inter
  static ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryPurple,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryAmber,
        surface: cardBg,
        error: dangerRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: offWhite,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: offWhite,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: offWhite,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: offWhite,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: offWhite,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
        ),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2F2F4A), width: 1.5),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryPurple,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
