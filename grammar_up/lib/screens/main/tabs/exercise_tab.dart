import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/cards/exercise_card.dart';
import '../exercise_play_screen.dart';
import '../../../data/sample_questions.dart';

class ExerciseTab extends StatelessWidget {
  const ExerciseTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tĩnh cho các bài tập
    final List<Map<String, String>> exercises = [
      {'title': 'Present Simple Practice', 'difficulty': 'Easy'},
      {'title': 'Mixed Exercise', 'difficulty': 'Medium'},
      {'title': 'Grammar Challenge', 'difficulty': 'Hard'},
      {'title': 'A1 Level Practice', 'difficulty': 'Easy'},
      {'title': 'A2 Level Practice', 'difficulty': 'Medium'},
      {'title': 'Translation Focus', 'difficulty': 'Medium'},
      {'title': 'Word Order Practice', 'difficulty': 'Easy'},
      {'title': 'Complete Exercise', 'difficulty': 'Hard'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Exercise',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return ExerciseCard(
            title: exercise['title']!,
            difficulty: exercise['difficulty']!,
            onTap: () {
              // Lấy sample questions cho bài tập
              final questions = SampleQuestions.getSampleQuestions();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExercisePlayScreen(
                    title: exercise['title']!,
                    questions: questions,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
