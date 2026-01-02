import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// GrammarUp Theme Configuration
/// Duolingo-inspired design with elegant, minimalistic styling
class AppTheme {
  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.gray50,
      fontFamily: GoogleFonts.nunito().fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.teal100,
        secondary: AppColors.teal300,
        secondaryContainer: AppColors.teal50,
        surface: AppColors.white,
        error: AppColors.error,
        errorContainer: AppColors.errorLight,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onError: AppColors.white,
        outline: AppColors.gray300,
        outlineVariant: AppColors.gray200,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.gray800),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button Theme (Primary 3D style)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.nunito(
          color: AppColors.gray400,
          fontSize: 16,
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppColors.gray600,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.nunito(
          color: AppColors.gray600,
          fontSize: 14,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.teal100,
        labelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.gray700,
          fontSize: 16,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray900,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.gray200,
        circularTrackColor: AppColors.gray200,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray300;
        }),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: AppColors.gray700,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.nunito(
          color: AppColors.gray600,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.nunito(
          color: AppColors.gray900,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.nunito(
          color: AppColors.gray700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.nunito(
          color: AppColors.gray600,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.gray700,
        size: 24,
      ),
    );
  }

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkTeal,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: GoogleFonts.nunito().fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkTeal,
        primaryContainer: AppColors.teal800,
        secondary: AppColors.teal300,
        secondaryContainer: AppColors.teal900,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        errorContainer: AppColors.errorDark,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.white,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkSurfaceHighlight,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTeal,
          foregroundColor: AppColors.darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTeal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: AppColors.darkTeal, width: 2),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkTeal,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.nunito(
          color: AppColors.darkTextTertiary,
          fontSize: 16,
        ),
        labelStyle: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        iconColor: AppColors.darkTextSecondary,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        selectedColor: AppColors.teal800,
        labelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 16,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceElevated,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkTeal,
        linearTrackColor: AppColors.darkSurfaceHighlight,
        circularTrackColor: AppColors.darkSurfaceHighlight,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkBackground;
          }
          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkTeal;
          }
          return AppColors.darkSurfaceHighlight;
        }),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        displayMedium: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.nunito(
          color: AppColors.darkTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.nunito(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.nunito(
          color: AppColors.darkTextTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 24,
      ),
    );
  }
}
