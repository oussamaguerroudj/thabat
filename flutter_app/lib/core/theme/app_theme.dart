import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the single `ThemeData` every screen in the app uses. Feature
/// screens should pull colors/text styles from `Theme.of(context)` (or the
/// `AppColors`/`AppTypography` tokens directly for anything not modeled by
/// Material's `ThemeData`) rather than hardcoding values.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.pageBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.greenDeep,
        brightness: Brightness.light,
        primary: AppColors.greenDeep,
        secondary: AppColors.gold,
        surface: AppColors.cream,
        error: const Color(0xFFB3261E),
      ),
      fontFamily: GoogleFontsFamily.cairo,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.charcoal,
        displayColor: AppColors.greenDeep,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.pageBackground,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        titleTextStyle: AppTypography.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDeep,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: AppTypography.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    );
  }
}

/// `ThemeData.fontFamily` wants a plain family-name string; `google_fonts`
/// exposes the matching name via `GoogleFonts.cairo().fontFamily`, resolved
/// once here so `AppTheme.light` doesn't reach into `google_fonts` directly.
abstract final class GoogleFontsFamily {
  static String get cairo => AppTypography.cairo().fontFamily!;
}
