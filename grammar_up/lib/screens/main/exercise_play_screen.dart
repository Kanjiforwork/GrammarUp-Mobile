import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../core/constants/app_colors.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/sound_service.dart';
import '../../models/question_model.dart';
import '../../models/exercise_model.dart';
import '../../controllers/exercise_controller.dart';
import '../../widgets/questions/mcq_widget.dart';
import '../../widgets/questions/cloze_widget.dart';
import '../../widgets/questions/order_widget.dart';
import '../../widgets/questions/translate_widget.dart';
import '../../core/services/ai_explanation_service.dart';
import '../../widgets/common/ai_explanation_widget.dart';
import '../../widgets/common/dolphin_mascot.dart';
import '../../widgets/common/buttons.dart';
import '../../services/exercise_service.dart';
import '../../services/statistics_service.dart';

class ExercisePlayScreen extends StatefulWidget {
  final ExerciseModel? exercise;
  final String? title;
  final List<Question>? questions;

  const ExercisePlayScreen({
    super.key,
    this.exercise,
    this.title,
    this.questions,
  }) : assert(exercise != null || (title != null && questions != null),
            'Either exercise or (title and questions) must be provided');

  @override
  State<ExercisePlayScreen> createState() => _ExercisePlayScreenState();
}

class _ExercisePlayScreenState extends State<ExercisePlayScreen> {
  ExerciseController? _controller;
  final SoundService _soundService = SoundService();
  final ExerciseService _exerciseService = ExerciseService();
  final StatisticsService _statisticsService = StatisticsService();

  dynamic _currentAnswer;
  bool _hasAnswered = false;
  bool? _isCorrect;
  String _aiExplanation = '';
  bool _isLoadingExplanation = false;
  bool _isLoadingQuestions = true;
  bool _isShowingResultDialog = false;
  List<Question> _questions = [];

  String get _screenTitle =>
      widget.exercise?.title ?? widget.title ?? 'Exercise';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    if (widget.questions != null) {
      _questions = widget.questions!;
      _initController();
      return;
    }

    if (widget.exercise != null) {
      final questions =
          await _exerciseService.getQuestionsForExercise(widget.exercise!);
      _questions = questions;
    }

    if (_questions.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No questions available for this exercise'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    _initController();
  }

  void _initController() {
    if (!mounted) return;
    setState(() {
      _controller = ExerciseController(questions: _questions);
      _controller!.startTimer();
      _controller!.addListener(_onControllerUpdate);
      _isLoadingQuestions = false;
    });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {});

    if (_controller?.isCompleted == true && !_isShowingResultDialog) {
      _isShowingResultDialog = true;
      _showResultDialog();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _playSound() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
  }

  bool _canCheckAnswer() {
    if (_hasAnswered) return true;
    return _currentAnswer != null;
  }

  bool _shouldShowNext() {
    return _hasAnswered;
  }

  void _handleCheckAnswer() {
    if (_controller == null) return;

    _playSound();

    if (_hasAnswered) {
      _soundService.playClick();
      _controller!.nextQuestion();
      setState(() {
        _currentAnswer = null;
        _hasAnswered = false;
        _isCorrect = null;
        _aiExplanation = '';
        _isLoadingExplanation = false;
      });
    } else {
      final question = _controller!.currentQuestion;
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

      if (isCorrect) {
        _soundService.playCorrect();
      } else {
        _soundService.playWrong();
      }

      setState(() {
        _hasAnswered = true;
        _isCorrect = isCorrect;
      });

      _controller!.submitAnswer(
        userAnswer: _currentAnswer,
        isCorrect: isCorrect,
      );

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

      if (!mounted) return;
      setState(() {
        _aiExplanation = explanation;
        _isLoadingExplanation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiExplanation = 'Could not load explanation. Please try again later.';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    if (_isLoadingQuestions || _controller == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
        appBar: AppBar(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _screenTitle,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          _screenTitle,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildQuestionWidget(context),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final controller = _controller!;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                    value: controller.progress,
                    minHeight: 10,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceHighlight
                        : AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.currentQuestionIndex + 1}/${controller.totalQuestions}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                icon: Icons.star_rounded,
                value: controller.score.toString(),
                label: 'Score',
                color: AppColors.warning,
                isDark: isDark,
              ),
              _buildStatChip(
                icon: Icons.check_circle_rounded,
                value: controller.correctAnswers.toString(),
                label: 'Correct',
                color: AppColors.success,
                isDark: isDark,
              ),
              _buildStatChip(
                icon: Icons.timer_outlined,
                value: controller.formattedTime,
                label: 'Time',
                color: primaryColor,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final controller = _controller!;
    final question = controller.currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Question ${controller.currentQuestionIndex + 1}',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 20),

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

        // Feedback banner
        if (_hasAnswered) ...[
          const SizedBox(height: 20),
          _buildFeedbackBanner(context),
        ],

        // AI Explanation
        if (_hasAnswered && _isCorrect == false)
          AIExplanationWidget(
            explanation: _aiExplanation,
            isLoading: _isLoadingExplanation,
          ),
      ],
    );
  }

  Widget _buildFeedbackBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = _isCorrect ?? false;
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? 'Correct!' : 'Incorrect',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  isCorrect
                      ? 'Great job! Keep it up!'
                      : 'Don\'t worry, check the explanation below.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Skip button
          Expanded(
            child: OutlinedPrimaryButton(
              text: 'Skip',
              icon: Icons.skip_next_rounded,
              onPressed: _hasAnswered
                  ? null
                  : () {
                      _playSound();
                      _soundService.playClick();
                      _controller?.skipQuestion();
                    },
            ),
          ),
          const SizedBox(width: 12),
          // Check/Next button
          Expanded(
            child: _shouldShowNext()
                ? SuccessButton(
                    text: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _handleCheckAnswer,
                  )
                : PrimaryButton(
                    text: 'Check',
                    icon: Icons.check_rounded,
                    onPressed: _canCheckAnswer() ? _handleCheckAnswer : null,
                  ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Exercise?',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        content: Text(
          'Your progress will not be saved.',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Exit',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _saveResult() async {
    final controller = _controller;
    final exercise = widget.exercise;

    if (controller == null || exercise == null) return 0;

    await _exerciseService.saveExerciseResult(
      exerciseId: exercise.id,
      totalQuestions: controller.totalQuestions,
      correctAnswers: controller.correctAnswers,
      scorePoints: controller.score,
      scorePercentage: controller.accuracy.round(),
      timeSpent: controller.totalElapsedSeconds,
      passingScore: exercise.passingScore,
    );

    // Cộng điểm random 5-10 khi hoàn thành exercise
    final pointsEarned = 5 + Random().nextInt(6); // 5-10 điểm
    await _statisticsService.recordExerciseCompletion(
      timeSpent: controller.totalElapsedSeconds,
      pointsEarned: pointsEarned,
    );

    return pointsEarned;
  }

  void _showResultDialog() async {
    final controller = _controller;
    if (controller == null) return;

    final pointsEarned = await _saveResult();

    // Reload user profile to update stats on Profile tab (fire and forget, don't wait)
    if (mounted) {
      Provider.of<AuthProvider>(context, listen: false).reloadUserProfile();
    }

    if (!mounted) {
      _isShowingResultDialog = false;
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final accuracy = controller.accuracy;

    String message = '';
    Color messageColor = primaryColor;
    MascotMood mascotMood = MascotMood.happy;

    if (accuracy >= 80) {
      message = 'Excellent!';
      messageColor = AppColors.success;
      mascotMood = MascotMood.celebrating;
    } else if (accuracy >= 60) {
      message = 'Good Job!';
      messageColor = primaryColor;
      mascotMood = MascotMood.happy;
    } else if (accuracy >= 40) {
      message = 'Keep Practicing!';
      messageColor = AppColors.warning;
      mascotMood = MascotMood.thinking;
    } else {
      message = 'Try Again!';
      messageColor = AppColors.error;
      mascotMood = MascotMood.curious;
    }

    _playSound();
    if (accuracy >= 60) {
      _soundService.playSuccess();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accuracy >= 60)
                const CelebrationMascot(size: 100)
              else
                DolphinMascot(size: 100, mood: mascotMood),
              const SizedBox(height: 16),

              Text(
                message,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: messageColor,
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildResultRow(
                      'Score',
                      controller.score.toString(),
                      AppColors.warning,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      'Points Earned',
                      '+$pointsEarned',
                      AppColors.success,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      'Correct',
                      '${controller.correctAnswers}/${controller.totalQuestions}',
                      AppColors.success,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      'Accuracy',
                      '${accuracy.toStringAsFixed(0)}%',
                      primaryColor,
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildResultRow(
                      'Time',
                      controller.formattedTotalTime,
                      isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedPrimaryButton(
                      text: 'Exit',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Try Again',
                      icon: Icons.refresh_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                        controller.restart();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
      String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
