import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../models/lesson_model.dart';
import '../../../models/lesson_progress_model.dart';
import '../../../services/lesson_service.dart';
import '../../../widgets/cards/lesson_card.dart';
import '../../../widgets/common/dolphin_mascot.dart';
import '../lesson_detail_screen.dart';

class LessonTab extends StatefulWidget {
  const LessonTab({super.key});

  @override
  State<LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<LessonTab> {
  final LessonService _lessonService = LessonService();
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final lessons = await _lessonService.getLessons();
    final progressMap = await _lessonService.getAllProgress();
    return {
      'lessons': lessons,
      'progress': progressMap,
    };
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.gray50;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n?.translate('lessons_title') ?? 'Lessons',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // Streak badge placeholder
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: GoogleFonts.nunito(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          final lessons =
              snapshot.data?['lessons'] as List<LessonModel>? ?? [];
          final progressMap = snapshot.data?['progress']
                  as Map<String, LessonProgressModel>? ??
              {};

          if (lessons.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildLessonList(context, lessons, progressMap);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DolphinMascot(
              size: 120,
              mood: MascotMood.curious,
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.noLessonsYet ?? 'No lessons yet',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.lessonsWillAppear ?? 'Lessons will appear here once available',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _refreshData,
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
              label: Text(
                l10n?.refresh ?? 'Refresh',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _refreshData,
              icon: Icon(Icons.refresh_rounded, color: primaryColor),
              label: Text(
                'Try Again',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonList(
    BuildContext context,
    List<LessonModel> lessons,
    Map<String, LessonProgressModel> progressMap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate stats
    int completedCount = 0;
    for (var lesson in lessons) {
      if (progressMap[lesson.id]?.isCompleted ?? false) {
        completedCount++;
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      color: isDark ? AppColors.darkTeal : AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: lessons.length + 1, // +1 for header
        itemBuilder: (context, index) {
          // Header
          if (index == 0) {
            return _buildHeader(
              context,
              completedCount: completedCount,
              totalCount: lessons.length,
            );
          }

          final lessonIndex = index - 1;
          final lesson = lessons[lessonIndex];
          final progress = progressMap[lesson.id];
          final isCompleted = progress?.isCompleted ?? false;
          final isLocked = lessonIndex > 0 &&
              !(progressMap[lessons[lessonIndex - 1].id]?.isCompleted ?? false);

          // Determine status
          LessonStatus status;
          if (isCompleted) {
            status = LessonStatus.completed;
          } else if (isLocked) {
            status = LessonStatus.locked;
          } else if (progress != null && !isCompleted) {
            status = LessonStatus.inProgress;
          } else {
            status = LessonStatus.available;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LessonCard(
              lessonNumber: lessonIndex + 1,
              title: lesson.title,
              subtitle: _getSubtitle(lesson),
              status: status,
              onTap: () => _navigateToLesson(context, lesson, isLocked),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required int completedCount,
    required int totalCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.teal800, AppColors.teal900]
              : [AppColors.primary, AppColors.teal600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.teal900 : AppColors.primary)
                .withAlpha(77),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withAlpha(204),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount of $totalCount lessons',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.white.withAlpha(51),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  String? _getSubtitle(LessonModel lesson) {
    // You can customize this based on your lesson model
    return lesson.description?.isNotEmpty == true
        ? lesson.description
        : null;
  }

  void _navigateToLesson(
    BuildContext context,
    LessonModel lesson,
    bool isLocked,
  ) {
    if (isLocked) return;

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    soundService.playClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LessonDetailScreen(lesson: lesson),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => _refreshData());
  }
}
