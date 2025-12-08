import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExerciseCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final VoidCallback onTap;

  const ExerciseCard({super.key, required this.title, required this.difficulty, required this.onTap});

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.easy;
      case 'medium':
        return AppColors.medium;
      case 'hard':
        return AppColors.hard;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Exercise icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              // Title and difficulty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _getDifficultyColor()),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
