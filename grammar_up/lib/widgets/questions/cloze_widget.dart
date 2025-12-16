import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/question_model.dart';
import '../common/dolphin_mascot.dart';

class ClozeWidget extends StatefulWidget {
  final ClozeQuestion question;
  final Function(dynamic answer) onAnswerChanged;
  final bool hasAnswered;
  final bool? isCorrect;

  const ClozeWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.hasAnswered,
    required this.isCorrect,
  });

  @override
  State<ClozeWidget> createState() => _ClozeWidgetState();
}

class _ClozeWidgetState extends State<ClozeWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didUpdateWidget(ClozeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      // Reset state when question changes
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onAnswerChanged(_controller.text.trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with instruction
        DolphinMascot(
          message: 'Fill in the blank: Gõ từ vào ô trống.',
          isQuestionType: true,
        ),
        const SizedBox(height: 16),
        
        // Template with blank
        _buildTemplateWithInput(),
        
        const SizedBox(height: 16),
        
        // Feedback
        if (widget.hasAnswered) ...[
          const SizedBox(height: 16),
          _buildFeedback(),
        ],
      ],
    );
  }

  Widget _buildTemplateWithInput() {
    // Tách template thành các phần
    final parts = widget.question.template.split(RegExp(r'\{\{\d+\}\}'));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (parts.isNotEmpty)
            Text(
              parts[0],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          
          // Input field for the blank
          Container(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _controller,
              enabled: !widget.hasAnswered,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.hasAnswered && widget.isCorrect != null
                    ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                    : AppColors.primary,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập từ...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.hasAnswered && widget.isCorrect != null
                        ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.divider,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isCorrect != null
                        ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                        : AppColors.divider,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          
          if (parts.length > 1)
            Text(
              parts[1],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCorrect!
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isCorrect! ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.isCorrect! ? Icons.check_circle : Icons.cancel,
            color: widget.isCorrect! ? AppColors.success : AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCorrect! ? 'Chính xác!' : 'Chưa đúng!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isCorrect! ? AppColors.success : AppColors.error,
                  ),
                ),
                if (!widget.isCorrect!)
                  Text(
                    'Đáp án đúng: ${widget.question.correctAnswer}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

