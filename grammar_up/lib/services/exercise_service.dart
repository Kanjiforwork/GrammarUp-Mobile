import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/exercise_model.dart';
import '../models/exercise_attempt_model.dart';
import '../models/exercise_summary_model.dart';
import '../models/question_model.dart';

class ExerciseService {
  final SupabaseClient _supabase = SupabaseService.client;

  void _log(String message) {
    if (kDebugMode) {
      print('[ExerciseService] $message');
    }
  }

  // Lấy danh sách exercises public
  Future<List<ExerciseModel>> getExercises() async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('is_public', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExerciseModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching exercises: $e');
      return [];
    }
  }

  // Lấy chi tiết 1 exercise theo id
  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('id', id)
          .single();

      return ExerciseModel.fromJson(response);
    } catch (e) {
      _log('❌ Error fetching exercise by id: $e');
      return null;
    }
  }

  // Lấy questions theo concept + level của exercise
  Future<List<Question>> getQuestionsForExercise(ExerciseModel exercise) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('concept', exercise.concept)
          .eq('level', exercise.level)
          .eq('is_public', true)
          .limit(exercise.numQuestions);

      if ((response as List).isEmpty) {
        _log('⚠️ No questions found for ${exercise.concept} - ${exercise.level}');
        return [];
      }

      return response
          .map((json) => Question.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching questions: $e');
      return [];
    }
  }

  // Lấy questions theo concept và level trực tiếp
  Future<List<Question>> getQuestionsByConceptAndLevel({
    required String concept,
    required String level,
    int limit = 12,
  }) async {
    try {
      final response = await _supabase
          .from('questions')
          .select()
          .eq('concept', concept)
          .eq('level', level)
          .eq('is_public', true)
          .limit(limit);

      if ((response as List).isEmpty) {
        _log('⚠️ No questions found for $concept - $level');
        return [];
      }

      return response
          .map((json) => Question.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error fetching questions by concept/level: $e');
      return [];
    }
  }

  // ============== EXERCISE ATTEMPTS ==============

  // Lấy số lần attempt hiện tại của user cho exercise
  Future<int> getAttemptCount(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('exercise_attempts')
          .select('id')
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId);

      return (response as List).length;
    } catch (e) {
      _log('❌ Error getting attempt count: $e');
      return 0;
    }
  }

  // Tạo attempt mới và trả về attempt
  Future<ExerciseAttemptModel?> createAttempt({
    required String exerciseId,
    required int totalQuestions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _log('⚠️ User not logged in, cannot create attempt');
        return null;
      }

      final attemptCount = await getAttemptCount(exerciseId);

      final response = await _supabase
          .from('exercise_attempts')
          .insert({
            'user_id': userId,
            'exercise_id': exerciseId,
            'attempt_number': attemptCount + 1,
            'total_questions': totalQuestions,
            'correct_answers': 0,
            'score_points': 0,
            'score_percentage': 0,
            'time_spent': 0,
            'status': 'in_progress',
            'is_passed': false,
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      _log('✅ Created attempt #${attemptCount + 1} for exercise $exerciseId');
      return ExerciseAttemptModel.fromJson(response);
    } catch (e) {
      _log('❌ Error creating attempt: $e');
      return null;
    }
  }

  // Cập nhật attempt khi hoàn thành
  Future<bool> completeAttempt({
    required String attemptId,
    required int correctAnswers,
    required int scorePoints,
    required int scorePercentage,
    required int timeSpent,
    required bool isPassed,
  }) async {
    try {
      await _supabase
          .from('exercise_attempts')
          .update({
            'correct_answers': correctAnswers,
            'score_points': scorePoints,
            'score_percentage': scorePercentage,
            'time_spent': timeSpent,
            'status': 'completed',
            'is_passed': isPassed,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attemptId);

      _log('✅ Completed attempt $attemptId with score $scorePercentage%');
      return true;
    } catch (e) {
      _log('❌ Error completing attempt: $e');
      return false;
    }
  }

  // ============== EXERCISE SUMMARY ==============

  // Lấy summary của user cho exercise
  Future<ExerciseSummaryModel?> getSummary(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('exercise_summary')
          .select()
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId)
          .maybeSingle();

      if (response == null) return null;
      return ExerciseSummaryModel.fromJson(response);
    } catch (e) {
      _log('❌ Error getting summary: $e');
      return null;
    }
  }

  // Cập nhật hoặc tạo mới summary
  Future<bool> updateSummary({
    required String exerciseId,
    required String attemptId,
    required int scorePercentage,
    required int scorePoints,
    required bool isPassed,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final existing = await getSummary(exerciseId);
      final now = DateTime.now().toIso8601String();

      if (existing == null) {
        // Tạo mới summary
        await _supabase.from('exercise_summary').insert({
          'user_id': userId,
          'exercise_id': exerciseId,
          'total_attempts': 1,
          'best_score_percentage': scorePercentage,
          'best_score_points': scorePoints,
          'best_attempt_id': attemptId,
          'is_completed': isPassed,
          'first_completed_at': isPassed ? now : null,
          'last_attempt_at': now,
        });
        _log('✅ Created summary for exercise $exerciseId');
      } else {
        // Cập nhật summary
        final isBetterScore = scorePercentage > existing.bestScorePercentage;
        final isFirstCompletion = isPassed && !existing.isCompleted;

        await _supabase
            .from('exercise_summary')
            .update({
              'total_attempts': existing.totalAttempts + 1,
              'best_score_percentage': isBetterScore ? scorePercentage : existing.bestScorePercentage,
              'best_score_points': isBetterScore ? scorePoints : existing.bestScorePoints,
              'best_attempt_id': isBetterScore ? attemptId : existing.bestAttemptId,
              'is_completed': existing.isCompleted || isPassed,
              'first_completed_at': isFirstCompletion ? now : existing.firstCompletedAt?.toIso8601String(),
              'last_attempt_at': now,
              'updated_at': now,
            })
            .eq('id', existing.id);
        _log('✅ Updated summary for exercise $exerciseId');
      }

      return true;
    } catch (e) {
      _log('❌ Error updating summary: $e');
      return false;
    }
  }

  // Lưu kết quả hoàn chỉnh (attempt + summary)
  Future<bool> saveExerciseResult({
    required String exerciseId,
    required int totalQuestions,
    required int correctAnswers,
    required int scorePoints,
    required int scorePercentage,
    required int timeSpent,
    required int passingScore,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _log('⚠️ User not logged in, cannot save result');
        return false;
      }

      final isPassed = scorePercentage >= passingScore;
      final attemptCount = await getAttemptCount(exerciseId);

      // 1. Tạo attempt
      final attemptResponse = await _supabase
          .from('exercise_attempts')
          .insert({
            'user_id': userId,
            'exercise_id': exerciseId,
            'attempt_number': attemptCount + 1,
            'total_questions': totalQuestions,
            'correct_answers': correctAnswers,
            'score_points': scorePoints,
            'score_percentage': scorePercentage,
            'time_spent': timeSpent,
            'status': 'completed',
            'is_passed': isPassed,
            'started_at': DateTime.now().subtract(Duration(seconds: timeSpent)).toIso8601String(),
            'completed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final attemptId = attemptResponse['id'] as String;

      // 2. Cập nhật summary
      await updateSummary(
        exerciseId: exerciseId,
        attemptId: attemptId,
        scorePercentage: scorePercentage,
        scorePoints: scorePoints,
        isPassed: isPassed,
      );

      _log('✅ Saved exercise result: $correctAnswers/$totalQuestions ($scorePercentage%)');
      return true;
    } catch (e) {
      _log('❌ Error saving exercise result: $e');
      return false;
    }
  }

  // Lấy lịch sử attempts của user cho exercise
  Future<List<ExerciseAttemptModel>> getAttemptHistory(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('exercise_attempts')
          .select()
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExerciseAttemptModel.fromJson(json))
          .toList();
    } catch (e) {
      _log('❌ Error getting attempt history: $e');
      return [];
    }
  }
}
