import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../../controllers/exercise_controller.dart';
import '../../widgets/questions/mcq_widget.dart';
import '../../widgets/questions/cloze_widget.dart';
import '../../widgets/questions/order_widget.dart';
import '../../widgets/questions/translate_widget.dart';
import '../../core/services/ai_explanation_service.dart';
import '../../widgets/common/ai_explanation_widget.dart';

class ExercisePlayScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;

  const ExercisePlayScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<ExercisePlayScreen> createState() => _ExercisePlayScreenState();
}

class _ExercisePlayScreenState extends State<ExercisePlayScreen> {
  late ExerciseController _controller;
  dynamic _currentAnswer;
  bool _hasAnswered = false;
  bool? _isCorrect;
  String _aiExplanation = '';
  bool _isLoadingExplanation = false;

  @override
  void initState() {
    super.initState();
    _controller = ExerciseController(questions: widget.questions);
    _controller.startTimer();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
    
    // Kiểm tra nếu hoàn thành
    if (_controller.isCompleted) {
      _showResultDialog();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  bool _canCheckAnswer() {
    if (_hasAnswered) return true; // Đã trả lời -> hiện nút "Tiếp theo"
    return _currentAnswer != null; // Chưa trả lời -> có answer thì enable nút
  }

  bool _shouldShowNext() {
    return _hasAnswered;
  }

  void _handleCheckAnswer() {
    if (_hasAnswered) {
      // Chuyển sang câu tiếp theo
      _controller.nextQuestion();
      setState(() {
        _currentAnswer = null;
        _hasAnswered = false;
        _isCorrect = null;
        _aiExplanation = '';
        _isLoadingExplanation = false;
      });
    } else {
      // Kiểm tra câu trả lời
      final question = _controller.currentQuestion;
      bool isCorrect = false;
      
      if (question is MCQQuestion) {
        isCorrect = _currentAnswer == question.answerIndex;
      } else if (question is ClozeQuestion) {
        isCorrect = question.validateAnswer(_currentAnswer as String);
      } else if (question is OrderQuestion) {
        isCorrect = question.validateAnswer(_currentAnswer as List<String>);
      } else if (question is TranslateQuestion) {
        isCorrect = question.validateAnswer(_currentAnswer as String);
      }

      setState(() {
        _hasAnswered = true;
        _isCorrect = isCorrect;
      });

      _controller.submitAnswer(
        userAnswer: _currentAnswer,
        isCorrect: isCorrect,
      );

      // Nếu trả lời sai, gọi AI để giải thích
      if (!isCorrect) {
        _getAIExplanation(question);
      }
    }
  }

  Future<void> _getAIExplanation(Question question) async {
    setState(() {
      _isLoadingExplanation = true;
    });

    try {
      final explanation = await AIExplanationService.explainAnswer(
        question: question,
        userAnswer: _currentAnswer,
        isCorrect: false,
      );

      setState(() {
        _aiExplanation = explanation;
        _isLoadingExplanation = false;
      });
    } catch (e) {
      setState(() {
        _aiExplanation = 'Không thể tải giải thích lúc này. Vui lòng thử lại sau.';
        _isLoadingExplanation = false;
      });
    }
  }

  void _handleAnswerChanged(dynamic answer) {
    setState(() {
      _currentAnswer = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar and question number
            _buildHeader(),
            
            // Question content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildQuestionWidget(),
              ),
            ),
            
            // Bottom bar with timer and buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer ở hàng trên
                  _buildTimer(),
                  const SizedBox(height: 12),
                  // Buttons ở hàng dưới
                  Row(
                    children: [
                      // Skip button - bên trái
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _hasAnswered ? null : () {
                            _controller.skipQuestion();
                          },
                          icon: Icon(
                            Icons.skip_next,
                            color: _hasAnswered ? AppColors.divider : AppColors.textSecondary,
                            size: 18,
                          ),
                          label: Text(
                            'Bỏ qua',
                            style: TextStyle(
                              color: _hasAnswered ? AppColors.divider : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: _hasAnswered ? AppColors.divider.withValues(alpha: 0.3) : AppColors.divider,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Check button - bên phải
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canCheckAnswer() ? _handleCheckAnswer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.divider,
                            disabledForegroundColor: AppColors.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            _shouldShowNext() ? 'Tiếp theo' : 'Kiểm tra',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _controller.progress,
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_controller.currentQuestionIndex + 1}/${_controller.totalQuestions}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Score display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreChip(
                icon: Icons.stars,
                label: 'Điểm',
                value: _controller.score.toString(),
                color: AppColors.warning,
              ),
              _buildScoreChip(
                icon: Icons.check_circle,
                label: 'Đúng',
                value: _controller.correctAnswers.toString(),
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget() {
    final question = _controller.currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Câu hỏi ${_controller.currentQuestionIndex + 1}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Question type widget
        if (question is MCQQuestion)
          MCQWidget(
            question: question,
            onAnswerChanged: _handleAnswerChanged,
            hasAnswered: _hasAnswered,
            isCorrect: _isCorrect,
          )
        else if (question is ClozeQuestion)
          ClozeWidget(
            question: question,
            onAnswerChanged: _handleAnswerChanged,
            hasAnswered: _hasAnswered,
            isCorrect: _isCorrect,
          )
        else if (question is OrderQuestion)
          OrderWidget(
            question: question,
            onAnswerChanged: _handleAnswerChanged,
            hasAnswered: _hasAnswered,
            isCorrect: _isCorrect,
          )
        else if (question is TranslateQuestion)
          TranslateWidget(
            question: question,
            onAnswerChanged: _handleAnswerChanged,
            hasAnswered: _hasAnswered,
            isCorrect: _isCorrect,
          ),
        
        // AI Explanation widget - hiển thị khi trả lời sai
        if (_hasAnswered && _isCorrect == false)
          AIExplanationWidget(
            explanation: _aiExplanation,
            isLoading: _isLoadingExplanation,
          ),
      ],
    );
  }

  Widget _buildTimer() {
    // Màu cố định cho timer đếm tiến
    const timerColor = AppColors.primary;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: timerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: timerColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: timerColor, size: 20),
            const SizedBox(width: 8),
            Text(
              _controller.formattedTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: timerColor,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Thoát bài tập?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Bạn có chắc muốn thoát? Tiến độ sẽ không được lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close exercise screen
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog() {
    final accuracy = _controller.accuracy;
    String message = '';
    Color messageColor = AppColors.primary;

    if (accuracy >= 80) {
      message = 'Xuất sắc! 🎉';
      messageColor = AppColors.success;
    } else if (accuracy >= 60) {
      message = 'Tốt lắm! 👏';
      messageColor = AppColors.primary;
    } else if (accuracy >= 40) {
      message = 'Cố gắng hơn nữa! 💪';
      messageColor = AppColors.warning;
    } else {
      message = 'Hãy thử lại nhé! 📚';
      messageColor = AppColors.error;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: messageColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                accuracy >= 60 ? Icons.celebration : Icons.lightbulb,
                color: messageColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: messageColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats
            _buildResultStat(
              'Điểm số',
              _controller.score.toString(),
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildResultStat(
              'Số câu đúng',
              '${_controller.correctAnswers}/${_controller.totalQuestions}',
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildResultStat(
              'Độ chính xác',
              '${accuracy.toStringAsFixed(1)}%',
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildResultStat(
              'Thời gian',
              _controller.formattedTotalTime,
              AppColors.secondary,
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close exercise screen
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Thoát'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.restart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Làm lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
