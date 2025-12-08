import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Account',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withAlpha(76),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: const Icon(Icons.person, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            // User name
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text('john.doe@email.com', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            // Progress section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learning Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.35,
                            minHeight: 12,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '35%',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '7 of 20 lessons completed',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Achievements section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Achievements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  // Achievement badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAchievementBadge(icon: Icons.star, title: 'First Lesson', isUnlocked: true),
                      _buildAchievementBadge(
                        icon: Icons.local_fire_department,
                        title: '7 Day Streak',
                        isUnlocked: true,
                      ),
                      _buildAchievementBadge(icon: Icons.emoji_events, title: 'Top Scorer', isUnlocked: false),
                      _buildAchievementBadge(icon: Icons.school, title: 'Graduate', isUnlocked: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(icon: Icons.timer, value: '12h', label: 'Time Spent'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(icon: Icons.check_circle, value: '45', label: 'Exercises Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge({required IconData icon, required String title, required bool isUnlocked}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isUnlocked ? AppColors.warning : AppColors.divider),
          child: Icon(icon, color: isUnlocked ? AppColors.textWhite : AppColors.textSecondary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
