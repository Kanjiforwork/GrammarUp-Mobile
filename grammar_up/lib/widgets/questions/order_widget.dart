import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/question_model.dart';
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

class _OrderWidgetState extends State<OrderWidget> {
  late List<String> _availableTokens;
  final List<String> _orderedTokens = [];

  @override
  void initState() {
    super.initState();
    _availableTokens = widget.question.shuffledTokens;
  }

  @override
  void didUpdateWidget(OrderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      // Reset state when question changes
      setState(() {
        _availableTokens = widget.question.shuffledTokens;
        _orderedTokens.clear();
      });
    }
  }

  void _notifyAnswerChanged() {
    widget.onAnswerChanged(_orderedTokens);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dolphin with instruction
        DolphinMascot(
          message: 'Drag & Drop: Kéo thả từ vào đúng vị trí.',
          isQuestionType: true,
        ),
        const SizedBox(height: 16),
        
        // Câu trả lời của bạn
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasAnswered
                  ? (widget.isCorrect! ? AppColors.success : AppColors.error)
                  : const Color.fromARGB(255, 255, 255, 255),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CÂU TRẢ LỜI CỦA BẠN:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Drop zone
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
                    return Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? AppColors.primary
                              : AppColors.divider,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: _orderedTokens.isEmpty
                          ? Center(
                              child: Text(
                                'Kéo thả từ vào đây...',
                                style: TextStyle(
                                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _orderedTokens
                                  .asMap()
                                  .entries
                                  .map((entry) => _buildOrderedToken(
                                      entry.value, entry.key))
                                  .toList(),
                            ),
                    );
                  },
                ),
              
              // Kết quả sau khi trả lời
              if (widget.hasAnswered)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _orderedTokens
                      .map((token) => _buildAnsweredToken(token))
                      .toList(),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Chọn từ
        const Text(
          'CHỌN TỪ:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        
        // Available tokens
        if (!widget.hasAnswered)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableTokens
                .map((token) => _buildDraggableToken(token))
                .toList(),
          ),
        
        const SizedBox(height: 16),
        
        // Feedback
        if (widget.hasAnswered) ...[
          _buildFeedback(),
        ],
      ],
    );
  }

  Widget _buildDraggableToken(String token) {
    return Draggable<String>(
      data: token,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            token,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          token,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Text(
          token,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderedToken(String token, int index) {
    return Draggable<String>(
      data: token,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            token,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
        // Khi kéo ra ngoài drop zone
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            token,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnsweredToken(String token) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isCorrect!
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isCorrect! ? AppColors.success : AppColors.error,
          width: 1.5,
        ),
      ),
      child: Text(
        token,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: widget.isCorrect! ? AppColors.success : AppColors.error,
        ),
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

