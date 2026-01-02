import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Lesson Card Widget - Minimalistic vertical list style
/// Replaces the old zigzag path with clean cards
enum LessonStatus {
  locked,
  available,
  inProgress,
  completed,
}

class LessonCard extends StatefulWidget {
  final int lessonNumber;
  final String title;
  final String? subtitle;
  final LessonStatus status;
  final double? progress; // 0.0 to 1.0 for in-progress lessons
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.subtitle,
    this.status = LessonStatus.available,
    this.progress,
    this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  bool _isPressed = false;

  Color _getStatusColor() {
    switch (widget.status) {
      case LessonStatus.completed:
        return AppColors.success;
      case LessonStatus.inProgress:
      case LessonStatus.available:
        return AppColors.primary;
      case LessonStatus.locked:
        return AppColors.gray400;
    }
  }

  Color _getShadowColor() {
    switch (widget.status) {
      case LessonStatus.completed:
        return AppColors.successDark;
      case LessonStatus.inProgress:
      case LessonStatus.available:
        return AppColors.primaryDark;
      case LessonStatus.locked:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case LessonStatus.completed:
        return Icons.check_rounded;
      case LessonStatus.locked:
        return Icons.lock_rounded;
      case LessonStatus.inProgress:
      case LessonStatus.available:
        return Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = widget.status == LessonStatus.locked;
    final statusColor = _getStatusColor();
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.gray900;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.gray600;

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isLocked ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isLocked ? null : () => setState(() => _isPressed = false),
      onTap: isLocked ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed || isLocked
                ? []
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black26
                          : AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Status Icon Container with 3D effect
                _buildIconContainer(statusColor, isLocked, isDark),
                const SizedBox(width: 16),

                // Title and Subtitle
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
                          color: isLocked
                              ? (isDark ? AppColors.darkTextTertiary : AppColors.gray500)
                              : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isLocked
                                ? (isDark ? AppColors.darkTextTertiary : AppColors.gray400)
                                : subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Progress bar for in-progress lessons
                      if (widget.status == LessonStatus.inProgress &&
                          widget.progress != null) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(isDark),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Trailing icon
                Icon(
                  isLocked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
                  color: isLocked
                      ? (isDark ? AppColors.darkTextTertiary : AppColors.gray400)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.gray500),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(Color color, bool isLocked, bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLocked
            ? []
            : [
                BoxShadow(
                  color: _getShadowColor(),
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked
              ? (isDark ? AppColors.darkSurfaceHighlight : AppColors.gray200)
              : color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: widget.status == LessonStatus.locked
              ? Icon(
                  _getStatusIcon(),
                  color: isDark ? AppColors.darkTextTertiary : AppColors.gray500,
                  size: 24,
                )
              : widget.status == LessonStatus.completed
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 28,
                    )
                  : Text(
                      '${widget.lessonNumber}',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: widget.progress ?? 0,
        minHeight: 6,
        backgroundColor: isDark ? AppColors.darkSurfaceHighlight : AppColors.gray200,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

/// Compact Lesson List Item - simpler version for smaller lists
class LessonListItem extends StatelessWidget {
  final int lessonNumber;
  final String title;
  final LessonStatus status;
  final VoidCallback? onTap;

  const LessonListItem({
    super.key,
    required this.lessonNumber,
    required this.title,
    this.status = LessonStatus.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = status == LessonStatus.locked;
    final isCompleted = status == LessonStatus.completed;

    Color statusColor;
    if (isCompleted) {
      statusColor = AppColors.success;
    } else if (isLocked) {
      statusColor = isDark ? AppColors.darkTextTertiary : AppColors.gray400;
    } else {
      statusColor = isDark ? AppColors.darkTeal : AppColors.primary;
    }

    return ListTile(
      onTap: isLocked ? null : onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLocked
              ? (isDark ? AppColors.darkSurfaceHighlight : AppColors.gray100)
              : statusColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isCompleted
              ? Icon(Icons.check_rounded, color: statusColor, size: 20)
              : isLocked
                  ? Icon(Icons.lock_rounded, color: statusColor, size: 18)
                  : Text(
                      '$lessonNumber',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLocked
              ? (isDark ? AppColors.darkTextTertiary : AppColors.gray500)
              : (isDark ? AppColors.darkTextPrimary : AppColors.gray900),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
      ),
    );
  }
}
