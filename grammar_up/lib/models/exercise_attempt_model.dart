class ExerciseAttemptModel {
  final String id;
  final String userId;
  final String exerciseId;
  final int attemptNumber;
  final int totalQuestions;
  final int correctAnswers;
  final int scorePoints;
  final int scorePercentage;
  final int timeSpent; // in seconds
  final String status; // 'in_progress', 'completed', 'abandoned'
  final bool isPassed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  ExerciseAttemptModel({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.attemptNumber,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePoints,
    required this.scorePercentage,
    required this.timeSpent,
    required this.status,
    required this.isPassed,
    required this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory ExerciseAttemptModel.fromJson(Map<String, dynamic> json) {
    return ExerciseAttemptModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as String,
      attemptNumber: json['attempt_number'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int? ?? 0,
      scorePoints: json['score_points'] as int? ?? 0,
      scorePercentage: json['score_percentage'] as int? ?? 0,
      timeSpent: json['time_spent'] as int? ?? 0,
      status: json['status'] as String? ?? 'in_progress',
      isPassed: json['is_passed'] as bool? ?? false,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'attempt_number': attemptNumber,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_points': scorePoints,
      'score_percentage': scorePercentage,
      'time_spent': timeSpent,
      'status': status,
      'is_passed': isPassed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For creating a new attempt (without id, created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'exercise_id': exerciseId,
      'attempt_number': attemptNumber,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'score_points': scorePoints,
      'score_percentage': scorePercentage,
      'time_spent': timeSpent,
      'status': status,
      'is_passed': isPassed,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
