import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../common/dolphin_mascot.dart';

class TranslateWidget extends StatefulWidget {
  final TranslateQuestion question;
  final Function(dynamic answer) onAnswerChanged;
  final bool hasAnswered;
  final bool? isCorrect;

  const TranslateWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.hasAnswered,
    required this.isCorrect,
  });

  @override
  State<TranslateWidget> createState() => _TranslateWidgetState();
}

class _TranslateWidgetState extends State<TranslateWidget>
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
  void didUpdateWidget(TranslateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _controller.clear();
    }
    // Play shake animation on wrong answer
    if (widget.hasAnswered &&
        widget.isCorrect == false &&
        !oldWidget.hasAnswered) {
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
          message: 'Dịch câu sau sang tiếng Anh',
          isQuestionType: true,
        ),
        const SizedBox(height: 24),

        // Question type label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkTeal.withAlpha(26) : AppColors.teal50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 14,
                color: isDark ? AppColors.darkTeal : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Translation',
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

        // Source text card
        _buildSourceCard(),
        const SizedBox(height: 20),

        // Translation input area
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
          child: _buildTranslationInput(),
        ),

        // Feedback
        if (widget.hasAnswered && widget.isCorrect != null) ...[
          const SizedBox(height: 16),
          _buildFeedback(),
        ],
      ],
    );
  }

  Widget _buildSourceCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.teal800, AppColors.teal900]
              : [AppColors.primary, AppColors.teal600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.teal900 : AppColors.teal600).withAlpha(77),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Language badge
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiếng Việt',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withAlpha(179),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.question.vietnameseText,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine border color based on state
    Color borderColor;
    Color? bottomBorderColor;

    if (widget.hasAnswered && widget.isCorrect != null) {
      borderColor = widget.isCorrect! ? AppColors.success : AppColors.error;
      bottomBorderColor =
          widget.isCorrect! ? AppColors.successDark : AppColors.errorDark;
    } else if (_focusNode.hasFocus) {
      borderColor = isDark ? AppColors.darkTeal : AppColors.primary;
      bottomBorderColor = isDark ? AppColors.teal800 : AppColors.teal600;
    } else {
      borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTeal.withAlpha(26)
                      : AppColors.teal50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: isDark ? AppColors.darkTeal : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bản dịch tiếng Anh',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Text input
          Focus(
            onFocusChange: (hasFocus) {
              setState(() {});
            },
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.hasAnswered,
              maxLines: 3,
              minLines: 2,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.hasAnswered && widget.isCorrect != null
                    ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.gray900),
              ),
              decoration: InputDecoration(
                hintText: 'Nhập bản dịch của bạn...',
                hintStyle: GoogleFonts.nunito(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkBackground : AppColors.gray50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.gray300,
                    width: 1.5,
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
                        ? (widget.isCorrect!
                            ? AppColors.success
                            : AppColors.error)
                        : (isDark ? AppColors.darkBorder : AppColors.gray300),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    if (widget.isCorrect == null) return const SizedBox.shrink();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(
                isCorrect ? 'Tuyệt vời!' : 'Chưa chính xác',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Text(
              'Đáp án tham khảo:',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.gray200,
                ),
              ),
              child: Text(
                widget.question.correctAnswer,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
