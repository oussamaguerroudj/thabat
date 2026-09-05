import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Every font choice in the app goes through this file — never call
/// `GoogleFonts.cairo(...)` from a feature widget directly. Per ADR-011,
/// this isolation is what makes swapping to bundled asset fonts later a
/// one-file change instead of a codebase-wide hunt.
abstract final class AppTypography {
  /// Body/UI text — matches the prototype's `font-family:'Cairo'`.
  static TextStyle cairo({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.charcoal,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Display/brand text (the "ثبات" wordmark, headline moments) — matches
  /// the prototype's `font-family:'Aref Ruqaa'`.
  static TextStyle arefRuqaa({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.greenDeep,
  }) =>
      GoogleFonts.arefRuqaa(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
