import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExerciseScreen extends StatelessWidget {
  final String title;

  const ExerciseScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tĩnh cho câu hỏi
    final List<String> options = [
      'A. has been working',
      'B. have been working',
      'C. had been working',
      'D. were working',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.3,
                        minHeight: 8,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '3/10',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Question number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Question 3',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              // Question text
              const Text(
                'Choose the correct form of the verb to complete the sentence:',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                '"She _____ at the company for five years before she got promoted."',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 32),
              // Options
              ...options.map(
                (option) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildOptionButton(option)),
              ),
              const Spacer(),
              // Timer placeholder
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.timer, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '02:30',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Placeholder - không có logic xử lý
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
