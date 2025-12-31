class ExerciseSummaryModel {
  final String id;
  final String userId;
  final String exerciseId;
  final int totalAttempts;
  final int bestScorePercentage;
  final int bestScorePoints;
  final String? bestAttemptId;
  final bool isCompleted;
  final DateTime? firstCompletedAt;
  final DateTime? lastAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseSummaryModel({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.totalAttempts,
    required this.bestScorePercentage,
    required this.bestScorePoints,
    this.bestAttemptId,
    required this.isCompleted,
    this.firstCompletedAt,
    this.lastAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSummaryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      exerciseId: json['exercise_id'] as String,
      totalAttempts: json['total_attempts'] as int? ?? 0,
      bestScorePercentage: json['best_score_percentage'] as int? ?? 0,
      bestScorePoints: json['best_score_points'] as int? ?? 0,
      bestAttemptId: json['best_attempt_id'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      firstCompletedAt: json['first_completed_at'] != null
          ? DateTime.parse(json['first_completed_at'] as String)
          : null,
      lastAttemptAt: json['last_attempt_at'] != null
          ? DateTime.parse(json['last_attempt_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'total_attempts': totalAttempts,
      'best_score_percentage': bestScorePercentage,
      'best_score_points': bestScorePoints,
      'best_attempt_id': bestAttemptId,
      'is_completed': isCompleted,
      'first_completed_at': firstCompletedAt?.toIso8601String(),
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
