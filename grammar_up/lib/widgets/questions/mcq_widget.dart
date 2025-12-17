import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/question_model.dart';
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

class _MCQWidgetState extends State<MCQWidget> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(MCQWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset state khi chuyển sang câu hỏi mới
    if (oldWidget.question != widget.question) {
      setState(() {
        _selectedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with question
        DolphinMascot(
          message: widget.question.prompt,
          isQuestionType: false, // MCQ hiển thị câu hỏi trực tiếp
        ),
        const SizedBox(height: 16),
        
        // Choices
        ...List.generate(
          widget.question.choices.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceButton(index),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(int index) {
    final choice = widget.question.choices[index];
    final isSelected = _selectedIndex == index;
    final isCorrectAnswer = index == widget.question.answerIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color borderColor = isDark ? const Color(0xFF333333) : AppColors.divider;
    Color backgroundColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    List<BoxShadow>? shadows;

    if (widget.hasAnswered) {
      if (isCorrectAnswer) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
      } else if (isSelected && !isCorrectAnswer) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primary.withValues(alpha: 0.1);
      textColor = AppColors.primary;
    }
    
    if (!widget.hasAnswered) {
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: shadows,
        borderRadius: BorderRadius.circular(12),
      ),
      child: OutlinedButton(
        onPressed: () => _handleSelect(index),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  choice,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (widget.hasAnswered && isCorrectAnswer)
              const Icon(Icons.check_circle, color: AppColors.success, size: 24),
            if (widget.hasAnswered && isSelected && !isCorrectAnswer)
              const Icon(Icons.cancel, color: AppColors.error, size: 24),
          ],
        ),
      ),
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
