import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/achievement_model.dart';
import '../models/user_achievement_model.dart';

class AchievementService {
  final SupabaseClient _supabase = SupabaseService.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[AchievementService] $message');
    }
  }

  // ============== ACHIEVEMENTS ==============

  // Lấy tất cả achievements
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching achievements: $e');
      return [];
    }
  }

  // Lấy achievements theo category
  Future<List<AchievementModel>> getAchievementsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .eq('category', category)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching achievements by category: $e');
      return [];
    }
  }

  // ============== USER ACHIEVEMENTS ==============

  // Lấy tất cả achievements của user với trạng thái earned
  Future<List<UserAchievementWithDetails>> getUserAchievements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Lấy tất cả achievements
      final achievements = await getAllAchievements();

      // Lấy achievements đã earned của user
      final earnedResponse = await _supabase
          .from('user_achievements')
          .select()
          .eq('user_id', userId);

      final Map<String, UserAchievementModel> earnedMap = {};
      for (final json in earnedResponse as List) {
        final earned = UserAchievementModel.fromJson(json);
        earnedMap[earned.achievementId] = earned;
      }

      // Kết hợp
      return achievements.map((achievement) {
        return UserAchievementWithDetails(
          userAchievement: earnedMap[achievement.id],
          achievementId: achievement.id,
          name: achievement.name,
          description: achievement.description,
          iconUrl: achievement.iconUrl,
          category: achievement.category,
          criteria: achievement.criteria,
          pointsReward: achievement.pointsReward,
        );
      }).toList();
    } catch (e) {
      _log('❌ Error fetching user achievements: $e');
      return [];
    }
  }

  // Lấy achievements đã earned
  Future<List<UserAchievementWithDetails>> getEarnedAchievements() async {
    final allAchievements = await getUserAchievements();
    return allAchievements.where((a) => a.isEarned).toList();
  }

  // Đếm achievements đã earned
  Future<int> getEarnedCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('user_achievements')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      _log('❌ Error counting earned achievements: $e');
      return 0;
    }
  }

  // Earn/unlock achievement
  Future<bool> earnAchievement(String achievementId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Check if already earned
      final existing = await _supabase
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .maybeSingle();

      if (existing != null) {
        _log('⚠️ Achievement already earned');
        return false;
      }

      // Insert new earned achievement
      await _supabase.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
      });

      _log('✅ Earned achievement $achievementId');
      return true;
    } catch (e) {
      _log('❌ Error earning achievement: $e');
      return false;
    }
  }

  // Check và unlock achievements dựa trên các điều kiện
  Future<List<String>> checkAndEarnAchievements({
    int? lessonsCompleted,
    int? exercisesCompleted,
    int? vocabularyLearned,
    int? currentStreak,
    int? totalPoints,
  }) async {
    final List<String> newlyEarned = [];

    try {
      final achievements = await getAllAchievements();
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      // Get already earned
      final earnedResponse = await _supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_id', userId);

      final earnedIds = (earnedResponse as List)
          .map((e) => e['achievement_id'] as String)
          .toSet();

      for (final achievement in achievements) {
        // Skip if already earned
        if (earnedIds.contains(achievement.id)) continue;

        // Check criteria
        final criteria = achievement.criteria;
        bool shouldEarn = false;

        if (criteria.containsKey('lessons_completed') && lessonsCompleted != null) {
          shouldEarn = lessonsCompleted >= (criteria['lessons_completed'] as int);
        } else if (criteria.containsKey('exercises_completed') && exercisesCompleted != null) {
          shouldEarn = exercisesCompleted >= (criteria['exercises_completed'] as int);
        } else if (criteria.containsKey('vocabulary_learned') && vocabularyLearned != null) {
          shouldEarn = vocabularyLearned >= (criteria['vocabulary_learned'] as int);
        } else if (criteria.containsKey('streak_days') && currentStreak != null) {
          shouldEarn = currentStreak >= (criteria['streak_days'] as int);
        } else if (criteria.containsKey('total_points') && totalPoints != null) {
          shouldEarn = totalPoints >= (criteria['total_points'] as int);
        }

        if (shouldEarn) {
          final earned = await earnAchievement(achievement.id);
          if (earned) {
            newlyEarned.add(achievement.name);
          }
        }
      }

      if (newlyEarned.isNotEmpty) {
        _log('🏆 Newly earned: ${newlyEarned.join(", ")}');
      }
    } catch (e) {
      _log('❌ Error checking achievements: $e');
    }

    return newlyEarned;
  }
}
