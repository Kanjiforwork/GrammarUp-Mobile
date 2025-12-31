import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../widgets/cards/exercise_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshExercises,
          ),
        ],
      ),
      body: FutureBuilder<List<ExerciseModel>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state hoặc empty - hiển thị empty state
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context);
          }

          // Success - hiển thị exercises từ Supabase
          final exercises = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshExercises(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ExerciseCard(
                  title: exercise.title,
                  difficulty: exercise.difficultyText,
                  onTap: () => _navigateToExercise(context, exercise),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Empty state khi không có data từ Supabase
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có bài tập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các bài tập sẽ được cập nhật sớm.\nKéo xuống để tải lại.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshExercises,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToExercise(BuildContext context, ExerciseModel exercise) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    soundService.playClick();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisePlayScreen(
          exercise: exercise,
        ),
      ),
    );
  }
}
