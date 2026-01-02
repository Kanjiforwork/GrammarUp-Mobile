import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Exercise Card Widget - Duolingo-inspired with difficulty indicator
class ExerciseCard extends StatefulWidget {
  final String title;
  final String difficulty;
  final String? questionCount;
  final IconData? icon;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.difficulty,
    this.questionCount,
    this.icon,
    required this.onTap,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  bool _isPressed = false;

  Color _getDifficultyColor() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.easy;
      case 'medium':
        return AppColors.medium;
      case 'hard':
        return AppColors.hard;
      default:
        return AppColors.gray500;
    }
  }

  Color _getDifficultyShadowColor() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.successDark;
      case 'medium':
        return AppColors.warningDark;
      case 'hard':
        return AppColors.errorDark;
      default:
        return AppColors.gray600;
    }
  }

  String _getDifficultyLabel() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return widget.difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final difficultyColor = _getDifficultyColor();
    final shadowColor = _getDifficultyShadowColor();
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.gray900;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.gray600;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: isDark ? Colors.black26 : AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Left accent bar
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Row(
                      children: [
                        // Icon container with 3D effect
                        _buildIconContainer(difficultyColor, shadowColor, isDark),
                        const SizedBox(width: 16),

                        // Title and info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Difficulty badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: difficultyColor.withAlpha(26),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getDifficultyLabel(),
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: difficultyColor,
                                      ),
                                    ),
                                  ),
                                  if (widget.questionCount != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.questionCount!,
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: subtitleColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Arrow icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurfaceHighlight
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, Color shadowColor, bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          widget.icon ?? Icons.fitness_center_rounded,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }
}

/// Compact Exercise List Item
class ExerciseListItem extends StatelessWidget {
  final String title;
  final String difficulty;
  final VoidCallback onTap;

  const ExerciseListItem({
    super.key,
    required this.title,
    required this.difficulty,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.easy;
      case 'medium':
        return AppColors.medium;
      case 'hard':
        return AppColors.hard;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getDifficultyColor();

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
        ),
      ),
      subtitle: Text(
        difficulty,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
      ),
    );
  }
}
