import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../common/dolphin_mascot.dart';

class MCQWidget extends StatefulWidget {
  final MCQQuestion question;
  final Function(dynamic answer) onAnswerChanged;
  final bool hasAnswered;
  final bool? isCorrect;

  const MCQWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.hasAnswered,
    required this.isCorrect,
  });

  @override
  State<MCQWidget> createState() => _MCQWidgetState();
}

class _MCQWidgetState extends State<MCQWidget> with TickerProviderStateMixin {
  int? _selectedIndex;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _scaleControllers = List.generate(
      widget.question.choices.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
      ),
    );
    _scaleAnimations = _scaleControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(MCQWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      setState(() {
        _selectedIndex = null;
      });
      // Dispose old controllers and create new ones
      for (var controller in _scaleControllers) {
        controller.dispose();
      }
      _initAnimations();
    }
  }

  @override
  void dispose() {
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with question
        DolphinMascot(
          message: widget.question.prompt,
          isQuestionType: false,
        ),
        const SizedBox(height: 24),

        // Question type label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkTeal.withAlpha(26)
                : AppColors.teal50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Chọn đáp án đúng',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTeal : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Choices
        ...List.generate(
          widget.question.choices.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard(int index) {
    final choice = widget.question.choices[index];
    final isSelected = _selectedIndex == index;
    final isCorrectAnswer = index == widget.question.answerIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color? bottomBorderColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (widget.hasAnswered) {
      if (isCorrectAnswer) {
        backgroundColor = AppColors.success;
        borderColor = AppColors.success;
        bottomBorderColor = AppColors.successDark;
        textColor = AppColors.white;
        trailingIcon = Icons.check_circle_rounded;
        iconColor = AppColors.white;
      } else if (isSelected && !isCorrectAnswer) {
        backgroundColor = AppColors.error;
        borderColor = AppColors.error;
        bottomBorderColor = AppColors.errorDark;
        textColor = AppColors.white;
        trailingIcon = Icons.cancel_rounded;
        iconColor = AppColors.white;
      } else {
        backgroundColor = isDark ? AppColors.darkSurface : AppColors.white;
        borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
        textColor = isDark ? AppColors.darkTextSecondary : AppColors.gray500;
      }
    } else if (isSelected) {
      backgroundColor = isDark
          ? AppColors.darkTeal.withAlpha(26)
          : AppColors.teal50;
      borderColor = isDark ? AppColors.darkTeal : AppColors.primary;
      bottomBorderColor = isDark ? AppColors.teal800 : AppColors.teal600;
      textColor = isDark ? AppColors.darkTeal : AppColors.primary;
    } else {
      backgroundColor = isDark ? AppColors.darkSurface : AppColors.white;
      borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
      textColor = isDark ? AppColors.darkTextPrimary : AppColors.gray900;
    }

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: GestureDetector(
            onTapDown: (_) {
              if (!widget.hasAnswered) {
                _scaleControllers[index].forward();
              }
            },
            onTapUp: (_) {
              if (!widget.hasAnswered) {
                _scaleControllers[index].reverse();
                _handleSelect(index);
              }
            },
            onTapCancel: () {
              if (!widget.hasAnswered) {
                _scaleControllers[index].reverse();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (widget.hasAnswered && isCorrectAnswer) ? 2 : 1.5,
                ),
                boxShadow: [
                  if (!widget.hasAnswered || isSelected || isCorrectAnswer)
                    BoxShadow(
                      color: bottomBorderColor?.withAlpha(128) ??
                          (isDark ? Colors.black26 : AppColors.shadow),
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Option letter badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.hasAnswered && (isCorrectAnswer || (isSelected && !isCorrectAnswer))
                          ? AppColors.white.withAlpha(51)
                          : (isSelected
                              ? (isDark ? AppColors.darkTeal : AppColors.primary)
                              : (isDark ? AppColors.darkBorder : AppColors.gray200)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D...
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.hasAnswered && (isCorrectAnswer || (isSelected && !isCorrectAnswer))
                              ? AppColors.white
                              : (isSelected
                                  ? AppColors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.gray600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Choice text
                  Expanded(
                    child: Text(
                      choice,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: isSelected || (widget.hasAnswered && isCorrectAnswer)
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),

                  // Trailing icon
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      color: iconColor,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSelect(int index) {
    if (!widget.hasAnswered) {
      setState(() {
        _selectedIndex = index;
      });
      widget.onAnswerChanged(index);
    }
  }
}
