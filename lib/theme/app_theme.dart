import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Greens
  static const Color primaryDark = Color(0xFF1A4331);
  static const Color primary = Color(0xFF2D765C);
  static const Color primaryLight = Color(0xFFE8F3EE);
  static const Color primaryAccent = Color(0xFF3E8E72);

  // Actions & Highlights
  static const Color secondaryOrange = Color(0xFFFF8D20);
  static const Color orangeLight = Color(0xFFFFF3E6);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8E4);

  // Text
  static const Color textMain = Color(0xFF13202B);
  static const Color textMuted = Color(0xFF66737C);
  static const Color textLight = Color(0xFF9EABB2);

  // Status Indicators
  static const Color usefulGreen = Color(0xFF5FAE3B);
  static const Color usefulGreenBg = Color(0xFFEDF8E9);
  static const Color partlyUsefulYellow = Color(0xFFF0B323);
  static const Color partlyUsefulYellowBg = Color(0xFFFFF8E6);
  static const Color notUsefulRed = Color(0xFFD7262E);
  static const Color notUsefulRedBg = Color(0xFFFFECEE);
  static const Color infoBlue = Color(0xFF2F5FB3);
  static const Color infoBlueBg = Color(0xFFEAF1FF);

  // GIS Map Plots
  static const Color mapRecognisedCfr = Color(0xFF7C3AED);
  static const Color mapForestCandidate = Color(0xFF15803D);
  static const Color mapGovtCandidate = Color(0xFFCA8A04);
  static const Color mapOther = Color(0xFFA8A29E);
  static const Color mapWater = Color(0xFF0284C7);
  static const Color mapGrazing = Color(0xFF84CC16);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondaryOrange,
        surface: AppColors.surface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          height: 1.25,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: AppColors.textMain,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13.5,
          color: AppColors.textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
