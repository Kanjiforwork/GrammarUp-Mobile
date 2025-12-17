import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LessonNode extends StatelessWidget {
  final int unitNumber;
  final String title;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback onTap;

  const LessonNode({
    super.key,
    required this.unitNumber,
    required this.title,
    this.isCompleted = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked
                  ? (isDark ? const Color(0xFF2A2A2A) : AppColors.surfaceLight)
                  : isCompleted
                  ? AppColors.success
                  : AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: isLocked
                  ? Icon(
                      Icons.lock,
                      color: isDark ? const Color(0xFFB0B0B0) : AppColors.textSecondary,
                      size: 28,
                    )
                  : isCompleted
                  ? const Icon(Icons.check, color: AppColors.textWhite, size: 32)
                  : Text(
                      '$unitNumber',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isLocked
                  ? (isDark ? const Color(0xFFB0B0B0) : AppColors.textSecondary)
                  : (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
