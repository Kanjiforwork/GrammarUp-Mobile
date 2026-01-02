import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// GrammarUp Typography System
/// Using Nunito font for a friendly, approachable feel (Duolingo-inspired)
class AppTextStyles {
  // ============================================
  // FONT FAMILY
  // ============================================
  static String get fontFamily => GoogleFonts.nunito().fontFamily!;

  static TextStyle _baseStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ============================================
  // DISPLAY STYLES
  // ============================================
  static TextStyle get display => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle get displaySmall => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  // ============================================
  // HEADING STYLES
  // ============================================
  static TextStyle get heading1 => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get heading2 => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get heading3 => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  static TextStyle get heading4 => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ============================================
  // BODY STYLES
  // ============================================
  static TextStyle get bodyLarge => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  // ============================================
  // LABEL STYLES
  // ============================================
  static TextStyle get labelLarge => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      );

  // ============================================
  // BUTTON STYLES
  // ============================================
  static TextStyle get buttonLarge => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSmall => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonText => buttonLarge;

  static TextStyle get buttonTextOutlined => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.5,
      );

  // ============================================
  // SPECIAL STYLES
  // ============================================
  static TextStyle get appTitle => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: 1.5,
      );

  static TextStyle get caption => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get overline => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        height: 1.5,
      );

  // ============================================
  // NAVIGATION STYLES
  // ============================================
  static TextStyle get navLabel => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get navLabelActive => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // ============================================
  // INPUT STYLES
  // ============================================
  static TextStyle get inputText => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get inputLabel => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get inputHint => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray400,
      );

  static TextStyle get inputError => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );

  // ============================================
  // HELPER METHODS
  // ============================================
  /// Get a text style with a custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get a text style for dark mode
  static TextStyle forDarkMode(TextStyle style) {
    return style.copyWith(color: AppColors.darkTextPrimary);
  }
}
