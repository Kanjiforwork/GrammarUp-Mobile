import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../widgets/cards/exercise_card.dart';
import '../../../widgets/common/dolphin_mascot.dart';
import '../exercise_play_screen.dart';
import '../../../services/exercise_service.dart';
import '../../../models/exercise_model.dart';

class ExerciseTab extends StatefulWidget {
  const ExerciseTab({super.key});

  @override
  State<ExerciseTab> createState() => _ExerciseTabState();
}

class _ExerciseTabState extends State<ExerciseTab> {
  final ExerciseService _exerciseService = ExerciseService();
  late Future<List<ExerciseModel>> _exercisesFuture;
  String _selectedDifficulty = 'All';

  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _exerciseService.getExercises();
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = _exerciseService.getExercises();
    });
  }

  List<ExerciseModel> _filterExercises(List<ExerciseModel> exercises) {
    if (_selectedDifficulty == 'All') return exercises;
    return exercises
        .where((e) =>
            e.difficultyText.toLowerCase() ==
            _selectedDifficulty.toLowerCase())
        .toList();
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
          l10n?.translate('exercises_title') ?? 'Exercises',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
            ),
            onPressed: _refreshExercises,
          ),
        ],
      ),
      body: Column(
        children: [
          // Difficulty Filter Chips
          Container(
            color: isDark ? AppColors.darkBackground : AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _difficulties.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  String displayText;
                  switch (difficulty) {
                    case 'All':
                      displayText = l10n?.all ?? 'All';
                      break;
                    case 'Easy':
                      displayText = l10n?.easy ?? 'Easy';
                      break;
                    case 'Medium':
                      displayText = l10n?.medium ?? 'Medium';
                      break;
                    case 'Hard':
                      displayText = l10n?.hard ?? 'Hard';
                      break;
                    default:
                      displayText = difficulty;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        displayText,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.gray600),
                        ),
                      ),
                      backgroundColor:
                          isDark ? AppColors.darkSurface : AppColors.gray100,
                      selectedColor: primaryColor,
                      checkmarkColor: AppColors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      onSelected: (selected) {
                        setState(() {
                          _selectedDifficulty = difficulty;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Exercise List
          Expanded(
            child: FutureBuilder<List<ExerciseModel>>(
              future: _exercisesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return _buildEmptyState(context);
                }

                final exercises = _filterExercises(snapshot.data!);

                if (exercises.isEmpty) {
                  return _buildNoResultsState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async => _refreshExercises(),
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExerciseCard(
                          title: exercise.title,
                          difficulty: exercise.difficultyText,
                          questionCount: '${exercise.numQuestions} questions',
                          onTap: () => _navigateToExercise(context, exercise),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
              l10n?.noExercisesYet ?? 'No exercises yet',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Exercises will be added soon.\nPull down to refresh.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _refreshExercises,
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

  Widget _buildNoResultsState(BuildContext context) {
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
                color: primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No exercises found',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different difficulty level',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDifficulty = 'All';
                });
              },
              icon: Icon(Icons.clear_rounded, color: primaryColor),
              label: Text(
                'Clear Filter',
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

  void _navigateToExercise(BuildContext context, ExerciseModel exercise) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    soundService.playClick();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExercisePlayScreen(exercise: exercise),
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
    );
  }
}
