import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/sound_service.dart';
import '../../models/lesson_model.dart';
import '../../models/lesson_content_model.dart';
import '../../services/lesson_service.dart';
import '../../widgets/common/dolphin_mascot.dart';
import '../../widgets/common/buttons.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonService _lessonService = LessonService();
  final PageController _pageController = PageController();
  final SoundService _soundService = SoundService();

  List<LessonContentModel> _contents = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _startLesson();
  }

  Future<void> _loadContent() async {
    final contents = await _lessonService.getLessonContent(widget.lesson.id);
    setState(() {
      _contents = contents;
      _isLoading = false;
    });
  }

  Future<void> _startLesson() async {
    await _lessonService.startLesson(widget.lesson.id);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  void _playSound() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playClick();
  }

  void _nextPage() {
    _playSound();
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeLesson();
    }
  }

  void _previousPage() {
    _playSound();
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _completeLesson() async {
    _stopTimer();
    await _lessonService.completeLesson(
      lessonId: widget.lesson.id,
      timeSpent: _elapsedSeconds,
    );

    if (!mounted) return;

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playSuccess();

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

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
              const CelebrationMascot(size: 100),
              const SizedBox(height: 20),
              Text(
                'Lesson Complete!',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You finished "${widget.lesson.title}"',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.gray600,
                ),
              ),
              const SizedBox(height: 16),
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkBackground : AppColors.gray50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      value: _formatTime(_elapsedSeconds),
                      label: 'Time',
                      color: primaryColor,
                      isDark: isDark,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? AppColors.darkBorder : AppColors.gray200,
                    ),
                    _buildStatItem(
                      icon: Icons.menu_book_outlined,
                      value: '${_contents.length}',
                      label: 'Pages',
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: SuccessButton(
                  text: 'Continue',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

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
          onPressed: () => _showExitConfirmation(),
        ),
        title: Text(
          widget.lesson.title,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        centerTitle: true,
        actions: [
          // Timer display
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: primaryColor),
                const SizedBox(width: 4),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      _formatTime(_elapsedSeconds),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : _contents.isEmpty
              ? _buildEmptyState(context)
              : _buildContent(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DolphinMascot(
              size: 120,
              mood: MascotMood.thinking,
            ),
            const SizedBox(height: 24),
            Text(
              'No content yet',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lesson content will be available soon',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final progress =
        _contents.isEmpty ? 0.0 : (_currentIndex + 1) / _contents.length;

    return Column(
      children: [
        // Progress bar
        Container(
          color: isDark ? AppColors.darkBackground : AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? AppColors.darkSurfaceHighlight : AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_contents.length}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content pages
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _lessonService.updateProgress(
                lessonId: widget.lesson.id,
                questionIndex: _currentIndex,
                timeSpent: _elapsedSeconds,
              );
            },
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              return _buildContentCard(_contents[index], isDark);
            },
          ),
        ),

        // Navigation buttons
        Container(
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
          child: SafeArea(
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedPrimaryButton(
                      text: 'Previous',
                      icon: Icons.arrow_back_rounded,
                      onPressed: _previousPage,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                const SizedBox(width: 12),
                Expanded(
                  child: _currentIndex < _contents.length - 1
                      ? PrimaryButton(
                          text: 'Next',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _nextPage,
                        )
                      : SuccessButton(
                          text: 'Complete',
                          icon: Icons.check_rounded,
                          onPressed: _nextPage,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(LessonContentModel content, bool isDark) {
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _getContentTypeColor(content.contentType).withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getContentTypeLabel(content.contentType),
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _getContentTypeColor(content.contentType),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          if (content.title != null) ...[
            Text(
              content.title!,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black12 : AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              content.content ?? '',
              style: GoogleFonts.nunito(
                fontSize: 16,
                height: 1.7,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
          ),

          // Example correct
          if (content.exampleCorrect != null) ...[
            const SizedBox(height: 16),
            _buildExampleBox(
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              label: 'Correct',
              text: content.exampleCorrect!,
              isDark: isDark,
            ),
          ],

          // Example incorrect
          if (content.exampleIncorrect != null) ...[
            const SizedBox(height: 12),
            _buildExampleBox(
              icon: Icons.cancel_rounded,
              color: AppColors.error,
              label: 'Incorrect',
              text: content.exampleIncorrect!,
              isDark: isDark,
            ),
          ],

          // Explanation
          if (content.explanation != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded,
                          color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content.explanation!,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleBox({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'rule':
        return const Color(0xFF9C27B0);
      case 'example':
        return AppColors.primary;
      case 'tip':
        return AppColors.warning;
      case 'warning':
        return AppColors.error;
      case 'practice':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _getContentTypeLabel(String type) {
    switch (type) {
      case 'rule':
        return 'Rule';
      case 'example':
        return 'Example';
      case 'tip':
        return 'Tip';
      case 'warning':
        return 'Warning';
      case 'practice':
        return 'Practice';
      case 'text':
        return 'Content';
      default:
        return type.toUpperCase();
    }
  }

  void _showExitConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Lesson?',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        content: Text(
          'Your progress will be saved.',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Stay',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _lessonService.updateProgress(
                lessonId: widget.lesson.id,
                questionIndex: _currentIndex,
                timeSpent: _elapsedSeconds,
              );
              _stopTimer();
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
}
