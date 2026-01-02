import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
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

class _ClozeWidgetState extends State<ClozeWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onAnswerChanged(_controller.text.trim());
    });

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(ClozeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _controller.clear();
    }
    // Play shake animation on wrong answer
    if (widget.hasAnswered && widget.isCorrect == false && !oldWidget.hasAnswered) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with instruction
        const DolphinMascot(
          message: 'Điền từ còn thiếu vào chỗ trống',
          isQuestionType: true,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_rounded,
                size: 14,
                color: isDark ? AppColors.darkTeal : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Fill in the blank',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTeal : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Template with input
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shakeOffset = _shakeAnimation.value *
                10 *
                (1 - _shakeAnimation.value) *
                ((_shakeAnimation.value * 10).floor().isEven ? 1 : -1);
            return Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            );
          },
          child: _buildTemplateCard(),
        ),

        const SizedBox(height: 16),

        // Feedback
        if (widget.hasAnswered && widget.isCorrect != null) ...[
          const SizedBox(height: 8),
          _buildFeedback(),
        ],
      ],
    );
  }

  Widget _buildTemplateCard() {
    final parts = widget.question.template.split(RegExp(r'\{\{\d+\}\}'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine border color based on state
    Color borderColor;
    Color? bottomBorderColor;

    if (widget.hasAnswered && widget.isCorrect != null) {
      borderColor = widget.isCorrect! ? AppColors.success : AppColors.error;
      bottomBorderColor = widget.isCorrect! ? AppColors.successDark : AppColors.errorDark;
    } else if (_focusNode.hasFocus) {
      borderColor = isDark ? AppColors.darkTeal : AppColors.primary;
      bottomBorderColor = isDark ? AppColors.teal800 : AppColors.teal600;
    } else {
      borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: bottomBorderColor?.withAlpha(128) ??
                (isDark ? Colors.black26 : AppColors.shadow),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: [
          if (parts.isNotEmpty)
            Text(
              parts[0],
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                height: 1.5,
              ),
            ),

          // Input field for the blank
          Container(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {});
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.hasAnswered,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: widget.hasAnswered && widget.isCorrect != null
                      ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                      : (isDark ? AppColors.darkTeal : AppColors.primary),
                ),
                decoration: InputDecoration(
                  hintText: '...',
                  hintStyle: GoogleFonts.nunito(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.gray400,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.gray50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.gray300,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkTeal : AppColors.primary,
                      width: 2,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isCorrect != null
                          ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                          : (isDark ? AppColors.darkBorder : AppColors.gray300),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (parts.length > 1)
            Text(
              parts[1],
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = widget.isCorrect!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withAlpha(26)
            : AppColors.error.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Chính xác!' : 'Chưa đúng!',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
                if (!isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đáp án: ${widget.question.correctAnswer}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
