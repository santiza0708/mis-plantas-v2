import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema cromático oficial de "Mis Plantas" según DESIGN.md
class AppColors {
  // Surface Grounds (Obsidian Dark)
  static const Color surface = Color(0xFF111412);
  static const Color surfaceDim = Color(0xFF111412);
  static const Color surfaceBright = Color(0xFF373A37);
  static const Color surfaceContainerLowest = Color(0xFF0C0F0D);
  static const Color surfaceContainerLow = Color(0xFF191C1A);
  static const Color surfaceContainer = Color(0xFF1D201E);
  static const Color surfaceContainerHigh = Color(0xFF282B28);
  static const Color surfaceContainerHighest = Color(0xFF323533);
  
  // On-surface & Texts
  static const Color onSurface = Color(0xFFE1E3DF);
  static const Color onSurfaceVariant = Color(0xFFBBCABF);
  static const Color outline = Color(0xFF86948A);

  // Primary (Botanic Emerald)
  static const Color primary = Color(0xFF4EDEA3);
  static const Color onPrimary = Color(0xFF003824);
  static const Color primaryContainer = Color(0xFF10B981);
  static const Color onPrimaryContainer = Color(0xFF00422B);

  // Secondary (Terracotta & Nutrition)
  static const Color secondary = Color(0xFFFFB77D);
  static const Color onSecondary = Color(0xFF4D2600);
  static const Color secondaryContainer = Color(0xFFD97707);
  static const Color onSecondaryContainer = Color(0xFF432100);

  // Tertiary (Hydration Aqua)
  static const Color tertiary = Color(0xFF7BD0FF);
  static const Color onTertiary = Color(0xFF00354A);
  static const Color tertiaryContainer = Color(0xFF19AEE8);
  static const Color onTertiaryContainer = Color(0xFF003E55);

  // Alert & Error
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);
}

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
