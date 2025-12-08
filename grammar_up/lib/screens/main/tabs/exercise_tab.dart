import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/cards/exercise_card.dart';
import '../exercise_screen.dart';

class ExerciseTab extends StatelessWidget {
  const ExerciseTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tĩnh cho các bài tập
    final List<Map<String, String>> exercises = [
      {'title': 'Exercise Unit 1', 'difficulty': 'Easy'},
      {'title': 'Exercise Unit 2', 'difficulty': 'Hard'},
      {'title': 'Exercise Unit 3', 'difficulty': 'Medium'},
      {'title': 'Exercise Unit 4', 'difficulty': 'Easy'},
      {'title': 'Exercise Unit 5', 'difficulty': 'Easy'},
      {'title': 'Exercise Unit 6', 'difficulty': 'Medium'},
      {'title': 'Exercise Unit 7', 'difficulty': 'Hard'},
      {'title': 'Exercise Unit 8', 'difficulty': 'Medium'},
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExerciseScreen(title: exercise['title']!)),
              );
            },
          );
        },
      ),
    );
  }
}
