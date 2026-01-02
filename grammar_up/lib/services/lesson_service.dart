import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/lesson_model.dart';
import '../models/lesson_content_model.dart';
import '../models/lesson_progress_model.dart';

class LessonService {
  final SupabaseClient _supabase = SupabaseService.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[LessonService] $message');
    }
  }

  // ============== LESSONS ==============

  // Lấy danh sách lessons public
  Future<List<LessonModel>> getLessons() async {
    try {
      _log('🔍 Fetching lessons...');
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('is_public', true)
          .order('order_index', ascending: true);

      _log('✅ Got ${(response as List).length} lessons');
      return (response as List)
          .map((json) => LessonModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      _log('❌ Error fetching lessons: $e');
      _log('Stack: $stackTrace');
      return [];
    }
  }

  // Lấy lessons theo category
  Future<List<LessonModel>> getLessonsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('category', category)
          .eq('is_public', true)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => LessonModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching lessons by category: $e');
      return [];
    }
  }

  // Lấy lessons theo level
  Future<List<LessonModel>> getLessonsByLevel(String level) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('level', level)
          .eq('is_public', true)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => LessonModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching lessons by level: $e');
      return [];
    }
  }

  // Lấy chi tiết 1 lesson
  Future<LessonModel?> getLessonById(String id) async {
    try {
      final response = await _supabase
          .from('lessons')
          .select()
          .eq('id', id)
          .single();

      return LessonModel.fromJson(response);
    } catch (e) {
      _log('❌ Error fetching lesson by id: $e');
      return null;
    }
  }

  // ============== LESSON CONTENT ==============

  // Lấy nội dung của lesson
  Future<List<LessonContentModel>> getLessonContent(String lessonId) async {
    try {
      final response = await _supabase
          .from('lesson_content')
          .select()
          .eq('lesson_id', lessonId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => LessonContentModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching lesson content: $e');
      return [];
    }
  }

  // ============== LESSON PROGRESS ==============

  // Lấy progress của user cho lesson
  Future<LessonProgressModel?> getProgress(String lessonId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      if (response == null) return null;
      return LessonProgressModel.fromJson(response);
    } catch (e) {
      _log('❌ Error getting progress: $e');
      return null;
    }
  }

  // Lấy tất cả progress của user
  Future<Map<String, LessonProgressModel>> getAllProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _supabase
          .from('lesson_progress')
          .select()
          .eq('user_id', userId);

      final Map<String, LessonProgressModel> progressMap = {};
      for (final json in response as List) {
        final progress = LessonProgressModel.fromJson(json);
        progressMap[progress.lessonId] = progress;
      }
      return progressMap;
    } catch (e) {
      _log('❌ Error getting all progress: $e');
      return {};
    }
  }

  // Bắt đầu lesson (tạo progress mới hoặc cập nhật)
  Future<LessonProgressModel?> startLesson(String lessonId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _log('⚠️ User not logged in');
        return null;
      }

      final existing = await getProgress(lessonId);
      final now = DateTime.now().toIso8601String();

      if (existing == null) {
        // Tạo mới
        final response = await _supabase
            .from('lesson_progress')
            .insert({
              'user_id': userId,
              'lesson_id': lessonId,
              'status': 'in_progress',
              'last_question_index': 0,
              'time_spent': 0,
              'started_at': now,
              'last_accessed_at': now,
            })
            .select()
            .single();

        _log('✅ Started lesson $lessonId');
        return LessonProgressModel.fromJson(response);
      } else if (existing.isNotStarted) {
        // Cập nhật status
        final response = await _supabase
            .from('lesson_progress')
            .update({
              'status': 'in_progress',
              'started_at': now,
              'last_accessed_at': now,
              'updated_at': now,
            })
            .eq('id', existing.id)
            .select()
            .single();

        _log('✅ Resumed lesson $lessonId');
        return LessonProgressModel.fromJson(response);
      } else {
        // Update last_accessed_at
        await _supabase
            .from('lesson_progress')
            .update({
              'last_accessed_at': now,
            })
            .eq('id', existing.id);
      }

      return existing;
    } catch (e) {
      _log('❌ Error starting lesson: $e');
      return null;
    }
  }

  // Cập nhật progress
  Future<bool> updateProgress({
    required String lessonId,
    required int questionIndex,
    required int timeSpent,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existing = await getProgress(lessonId);
      if (existing == null) {
        await startLesson(lessonId);
      }

      final now = DateTime.now().toIso8601String();

      await _supabase
          .from('lesson_progress')
          .update({
            'last_question_index': questionIndex,
            'time_spent': timeSpent,
            'last_accessed_at': now,
            'updated_at': now,
          })
          .eq('user_id', userId)
          .eq('lesson_id', lessonId);

      _log('✅ Updated progress: question $questionIndex');
      return true;
    } catch (e) {
      _log('❌ Error updating progress: $e');
      return false;
    }
  }

  // Hoàn thành lesson
  Future<bool> completeLesson({
    required String lessonId,
    required int timeSpent,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final now = DateTime.now().toIso8601String();

      await _supabase
          .from('lesson_progress')
          .update({
            'status': 'completed',
            'time_spent': timeSpent,
            'completed_at': now,
            'last_accessed_at': now,
            'updated_at': now,
          })
          .eq('user_id', userId)
          .eq('lesson_id', lessonId);

      _log('✅ Completed lesson $lessonId');
      return true;
    } catch (e) {
      _log('❌ Error completing lesson: $e');
      return false;
    }
  }

  // Đếm số lessons đã hoàn thành
  Future<int> getCompletedLessonsCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('lesson_progress')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'completed');

      return (response as List).length;
    } catch (e) {
      _log('❌ Error counting completed lessons: $e');
      return 0;
    }
  }

  // Lấy lessons đang học (in_progress)
  Future<List<LessonModel>> getInProgressLessons() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final progressResponse = await _supabase
          .from('lesson_progress')
          .select('lesson_id')
          .eq('user_id', userId)
          .eq('status', 'in_progress');

      final lessonIds = (progressResponse as List)
          .map((e) => e['lesson_id'] as String)
          .toList();

      if (lessonIds.isEmpty) return [];

      final lessonsResponse = await _supabase
          .from('lessons')
          .select()
          .inFilter('id', lessonIds);

      return (lessonsResponse as List)
          .map((json) => LessonModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error getting in-progress lessons: $e');
      return [];
    }
  }
}
