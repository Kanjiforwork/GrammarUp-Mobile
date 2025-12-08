import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);

  static const TextStyle heading3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Button text
  static const TextStyle buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textWhite);

  static const TextStyle buttonTextOutlined = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  // App title
  static const TextStyle appTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 1.2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
