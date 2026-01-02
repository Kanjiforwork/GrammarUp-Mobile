import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../common/dolphin_mascot.dart';

class OrderWidget extends StatefulWidget {
  final OrderQuestion question;
  final Function(dynamic answer) onAnswerChanged;
  final bool hasAnswered;
  final bool? isCorrect;

  const OrderWidget({
    super.key,
    required this.question,
    required this.onAnswerChanged,
    required this.hasAnswered,
    required this.isCorrect,
  });

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget>
    with SingleTickerProviderStateMixin {
  late List<String> _availableTokens;
  final List<String> _orderedTokens = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _availableTokens = List.from(widget.question.shuffledTokens);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(OrderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      setState(() {
        _availableTokens = List.from(widget.question.shuffledTokens);
        _orderedTokens.clear();
      });
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
    _shakeController.dispose();
    super.dispose();
  }

  void _notifyAnswerChanged() {
    widget.onAnswerChanged(_orderedTokens);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with instruction
        const DolphinMascot(
          message: 'Sắp xếp các từ theo thứ tự đúng',
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
                Icons.swap_horiz_rounded,
                size: 14,
                color: isDark ? AppColors.darkTeal : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Word Order',
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

        // Answer area
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
          child: _buildAnswerArea(),
        ),

        const SizedBox(height: 20),

        // Available tokens section
        if (!widget.hasAnswered) ...[
          Text(
            'Chọn từ:',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          _buildAvailableTokens(),
        ],

        // Feedback
        if (widget.hasAnswered && widget.isCorrect != null) ...[
          const SizedBox(height: 16),
          _buildFeedback(),
        ],
      ],
    );
  }

  Widget _buildAnswerArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine border color based on state
    Color borderColor;
    Color? bottomBorderColor;

    if (widget.hasAnswered && widget.isCorrect != null) {
      borderColor = widget.isCorrect! ? AppColors.success : AppColors.error;
      bottomBorderColor =
          widget.isCorrect! ? AppColors.successDark : AppColors.errorDark;
    } else {
      borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 100),
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
          // Label
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: 16,
                color: isDark ? AppColors.darkTextTertiary : AppColors.gray500,
              ),
              const SizedBox(width: 6),
              Text(
                'Câu trả lời của bạn:',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.darkTextTertiary : AppColors.gray500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Drop zone or answer display
          if (!widget.hasAnswered)
            DragTarget<String>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                setState(() {
                  _orderedTokens.add(details.data);
                  _availableTokens.remove(details.data);
                });
                _notifyAnswerChanged();
              },
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? (isDark
                            ? AppColors.darkTeal.withAlpha(26)
                            : AppColors.teal50)
                        : (isDark
                            ? AppColors.darkBackground
                            : AppColors.gray50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHovering
                          ? (isDark ? AppColors.darkTeal : AppColors.primary)
                          : (isDark ? AppColors.darkBorder : AppColors.gray300),
                      width: isHovering ? 2 : 1.5,
                      style:
                          isHovering ? BorderStyle.solid : BorderStyle.solid,
                    ),
                  ),
                  child: _orderedTokens.isEmpty
                      ? Center(
                          child: Text(
                            'Kéo thả hoặc chạm để thêm từ...',
                            style: GoogleFonts.nunito(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.gray400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _orderedTokens
                              .asMap()
                              .entries
                              .map((entry) =>
                                  _buildOrderedToken(entry.value, entry.key))
                              .toList(),
                        ),
                );
              },
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _orderedTokens.map((token) => _buildAnsweredToken(token)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailableTokens() {
    if (_availableTokens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _availableTokens.map((token) => _buildDraggableToken(token)).toList(),
    );
  }

  Widget _buildDraggableToken(String token) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Draggable<String>(
      data: token,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkTeal : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.teal800 : AppColors.teal600)
                    .withAlpha(128),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            token,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          token,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (!widget.hasAnswered) {
            setState(() {
              _orderedTokens.add(token);
              _availableTokens.remove(token);
            });
            _notifyAnswerChanged();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkTeal.withAlpha(26)
                : AppColors.teal50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkTeal : AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isDark ? AppColors.teal800 : AppColors.teal600).withAlpha(77),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Text(
            token,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTeal : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderedToken(String token, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Draggable<String>(
      data: token,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkTeal : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            token,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      onDragCompleted: () {
        setState(() {
          _orderedTokens.removeAt(index);
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _orderedTokens.removeAt(index);
          _availableTokens.add(token);
        });
        _notifyAnswerChanged();
      },
      child: GestureDetector(
        onTap: () {
          if (!widget.hasAnswered) {
            setState(() {
              _orderedTokens.removeAt(index);
              _availableTokens.add(token);
            });
            _notifyAnswerChanged();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkTeal : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    (isDark ? AppColors.teal800 : AppColors.teal600).withAlpha(128),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                token,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.white.withAlpha(179),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnsweredToken(String token) {
    final isCorrect = widget.isCorrect!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withAlpha(26)
            : AppColors.error.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Text(
        token,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isCorrect ? AppColors.success : AppColors.error,
        ),
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
