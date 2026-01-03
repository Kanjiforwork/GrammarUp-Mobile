import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/learning_statistics_model.dart';
import 'achievement_service.dart';

class StatisticsService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AchievementService _achievementService = AchievementService();

  void _log(String message) {
    if (kDebugMode) {
      print('[StatisticsService] $message');
    }
  }

  // Lấy statistics của user cho ngày hôm nay
  Future<LearningStatisticsModel?> getTodayStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from('learning_statistics')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (response == null) {
        return await _createTodayStatistics(userId, today);
      }

      return LearningStatisticsModel.fromJson(response);
    } catch (e) {
      _log('❌ Error fetching today statistics: $e');
      return null;
    }
  }

  // Tạo statistics cho ngày hôm nay
  Future<LearningStatisticsModel?> _createTodayStatistics(String userId, String date) async {
    try {
      final response = await _supabase
          .from('learning_statistics')
          .insert({
            'user_id': userId,
            'date': date,
            'lessons_completed': 0,
            'exercises_completed': 0,
            'total_score_points': 0,
            'time_spent': 0,
          })
          .select()
          .single();

      _log('✅ Created today statistics');
      return LearningStatisticsModel.fromJson(response);
    } catch (e) {
      _log('❌ Error creating today statistics: $e');
      return null;
    }
  }

  // Lấy aggregate statistics (tổng hợp tất cả ngày)
  Future<AggregateStatistics> getAggregateStatistics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return AggregateStatistics();
      }

      // Sum all daily stats
      final statsResponse = await _supabase
          .from('learning_statistics')
          .select('lessons_completed, exercises_completed, total_score_points, time_spent')
          .eq('user_id', userId);

      int totalLessons = 0;
      int totalExercises = 0;
      int totalPoints = 0;
      int totalTime = 0;

      for (final row in statsResponse as List) {
        totalLessons += (row['lessons_completed'] as int?) ?? 0;
        totalExercises += (row['exercises_completed'] as int?) ?? 0;
        totalPoints += (row['total_score_points'] as int?) ?? 0;
        totalTime += (row['time_spent'] as int?) ?? 0;
      }

      // Get streak and points from users table
      final userResponse = await _supabase
          .from('users')
          .select('learning_streak, total_points')
          .eq('id', userId)
          .single();

      return AggregateStatistics(
        totalLessonsCompleted: totalLessons,
        totalExercisesCompleted: totalExercises,
        totalScorePoints: totalPoints,
        totalTimeSpent: totalTime,
        currentStreak: userResponse['learning_streak'] as int? ?? 0,
        totalPoints: userResponse['total_points'] as int? ?? 0,
      );
    } catch (e) {
      _log('❌ Error fetching aggregate statistics: $e');
      return AggregateStatistics();
    }
  }

  // Cập nhật sau khi hoàn thành lesson
  Future<bool> recordLessonCompletion({
    required int timeSpent,
    required int pointsEarned,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final stats = await getTodayStatistics();
      if (stats == null) return false;

      final now = DateTime.now().toIso8601String();

      // Update today's stats
      await _supabase
          .from('learning_statistics')
          .update({
            'lessons_completed': stats.lessonsCompleted + 1,
            'total_score_points': stats.totalScorePoints + pointsEarned,
            'time_spent': stats.timeSpent + timeSpent,
            'updated_at': now,
          })
          .eq('id', stats.id);

      // Update user's total points and streak
      await _updateUserStats(userId, pointsEarned);

      // Check and earn achievements
      await _checkAchievements();

      _log('✅ Recorded lesson completion');
      return true;
    } catch (e) {
      _log('❌ Error recording lesson completion: $e');
      return false;
    }
  }

  // Cập nhật sau khi hoàn thành exercise
  Future<bool> recordExerciseCompletion({
    required int timeSpent,
    required int pointsEarned,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final stats = await getTodayStatistics();
      if (stats == null) return false;

      final now = DateTime.now().toIso8601String();

      // Update today's stats
      await _supabase
          .from('learning_statistics')
          .update({
            'exercises_completed': stats.exercisesCompleted + 1,
            'total_score_points': stats.totalScorePoints + pointsEarned,
            'time_spent': stats.timeSpent + timeSpent,
            'updated_at': now,
          })
          .eq('id', stats.id);

      // Update user's total points and streak
      await _updateUserStats(userId, pointsEarned);

      // Check and earn achievements
      await _checkAchievements();

      _log('✅ Recorded exercise completion');
      return true;
    } catch (e) {
      _log('❌ Error recording exercise completion: $e');
      return false;
    }
  }

  // Update user's total_points và learning_streak
  Future<void> _updateUserStats(String userId, int pointsEarned) async {
    try {
      // Get current user data
      final userResponse = await _supabase
          .from('users')
          .select('total_points, learning_streak, updated_at')
          .eq('id', userId)
          .single();

      final currentPoints = userResponse['total_points'] as int? ?? 0;
      int currentStreak = userResponse['learning_streak'] as int? ?? 0;

      // Check if we need to update streak
      final lastUpdate = userResponse['updated_at'] != null
          ? DateTime.parse(userResponse['updated_at'] as String)
          : null;

      if (lastUpdate != null) {
        final lastDate = DateTime(lastUpdate.year, lastUpdate.month, lastUpdate.day);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final diff = todayDate.difference(lastDate).inDays;

        if (diff == 1) {
          currentStreak++;
        } else if (diff > 1) {
          currentStreak = 1;
        }
        // diff == 0: same day, keep streak
      } else {
        currentStreak = 1;
      }

      await _supabase
          .from('users')
          .update({
            'total_points': currentPoints + pointsEarned,
            'learning_streak': currentStreak,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      _log('❌ Error updating user stats: $e');
    }
  }

  // Lấy statistics theo khoảng thời gian
  Future<List<LearningStatisticsModel>> getStatisticsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('learning_statistics')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: true);

      return (response as List)
          .map((json) => LearningStatisticsModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching statistics by date range: $e');
      return [];
    }
  }

  // Lấy statistics 7 ngày gần nhất
  Future<List<LearningStatisticsModel>> getWeeklyStatistics() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getStatisticsByDateRange(startDate: weekAgo, endDate: now);
  }

  // Check and earn achievements based on current stats
  Future<List<String>> _checkAchievements() async {
    try {
      final aggregateStats = await getAggregateStatistics();
      final newlyEarned = await _achievementService.checkAndEarnAchievements(
        lessonsCompleted: aggregateStats.totalLessonsCompleted,
        exercisesCompleted: aggregateStats.totalExercisesCompleted,
        currentStreak: aggregateStats.currentStreak,
        totalPoints: aggregateStats.totalPoints,
      );
      if (newlyEarned.isNotEmpty) {
        _log('🏆 New achievements earned: ${newlyEarned.join(", ")}');
      }
      return newlyEarned;
    } catch (e) {
      _log('❌ Error checking achievements: $e');
      return [];
    }
  }
}
