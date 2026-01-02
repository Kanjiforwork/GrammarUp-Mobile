import 'package:flutter/material.dart';

/// GrammarUp Color Palette
/// Duolingo-inspired design with Teal accent
class AppColors {
  // ============================================
  // PRIMARY TEAL PALETTE
  // ============================================
  static const Color teal50 = Color(0xFFE0F7F5);
  static const Color teal100 = Color(0xFFB3ECE7);
  static const Color teal200 = Color(0xFF80DED3);
  static const Color teal300 = Color(0xFF4DD0C5);
  static const Color teal400 = Color(0xFF26C6B8); // Primary
  static const Color teal500 = Color(0xFF1DB9AA);
  static const Color teal600 = Color(0xFF18A89A); // Primary Dark
  static const Color teal700 = Color(0xFF14958A);
  static const Color teal800 = Color(0xFF0F7B72);
  static const Color teal900 = Color(0xFF0A615A);

  // Primary aliases
  static const Color primary = teal400;
  static const Color primaryLight = teal100;
  static const Color primaryDark = teal600;
  static const Color accent = teal300;

  // ============================================
  // NEUTRAL COLORS (Light Mode)
  // ============================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Background & Surface (Light)
  static const Color background = white;
  static const Color surface = white;
  static const Color surfaceLight = gray100;

  // Text colors (Light)
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray500;
  static const Color textWhite = white;

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  // Success (Duolingo green)
  static const Color success = Color(0xFF58CC02);
  static const Color successLight = Color(0xFFD7FFBD);
  static const Color successDark = Color(0xFF46A302);

  // Error
  static const Color error = Color(0xFFFF4B4B);
  static const Color errorLight = Color(0xFFFFDFDF);
  static const Color errorDark = Color(0xFFE63939);

  // Warning (Duolingo gold/streak)
  static const Color warning = Color(0xFFFFC800);
  static const Color warningLight = Color(0xFFFFF5CC);
  static const Color warningDark = Color(0xFFE6B400);

  // Info
  static const Color info = Color(0xFF1CB0F6);
  static const Color infoLight = Color(0xFFDFF4FF);
  static const Color infoDark = Color(0xFF0A9AD9);

  // Difficulty colors
  static const Color easy = success;
  static const Color medium = warning;
  static const Color hard = error;

  // ============================================
  // DARK MODE COLORS
  // ============================================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceElevated = Color(0xFF2A2A2A);
  static const Color darkSurfaceHighlight = Color(0xFF333333);
  static const Color darkBorder = Color(0xFF3D3D3D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);
  static const Color darkTeal = Color(0xFF4DD0C5); // Slightly brighter for dark mode

  // ============================================
  // UI ELEMENT COLORS
  // ============================================
  static const Color divider = gray200;
  static const Color border = gray300;
  static const Color shadow = Color(0x14000000); // 8% black
  static const Color shadowMedium = Color(0x1F000000); // 12% black
  static const Color shadowDark = Color(0x29000000); // 16% black

  // Button shadow (Duolingo 3D effect)
  static const Color buttonShadow = teal600;
  static const Color successButtonShadow = successDark;
  static const Color errorButtonShadow = errorDark;

  // ============================================
  // LEGACY ALIASES (for backward compatibility)
  // ============================================
  static const Color secondary = gray800;
}
