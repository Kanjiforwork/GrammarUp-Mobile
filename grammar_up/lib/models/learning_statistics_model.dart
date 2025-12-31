class LearningStatisticsModel {
  final String id;
  final String oderId;
  final DateTime date;
  final int lessonsCompleted;
  final int exercisesCompleted;
  final int totalScorePoints;
  final int timeSpent; // in seconds
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningStatisticsModel({
    required this.id,
    required this.oderId,
    required this.date,
    this.lessonsCompleted = 0,
    this.exercisesCompleted = 0,
    this.totalScorePoints = 0,
    this.timeSpent = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningStatisticsModel.fromJson(Map<String, dynamic> json) {
    return LearningStatisticsModel(
      id: json['id'] as String,
      oderId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      exercisesCompleted: json['exercises_completed'] as int? ?? 0,
      totalScorePoints: json['total_score_points'] as int? ?? 0,
      timeSpent: json['time_spent'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': oderId,
      'date': date.toIso8601String().split('T')[0], // date only
      'lessons_completed': lessonsCompleted,
      'exercises_completed': exercisesCompleted,
      'total_score_points': totalScorePoints,
      'time_spent': timeSpent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get formattedTimeSpent {
    if (timeSpent < 60) {
      return '$timeSpent giây';
    }
    final minutes = timeSpent ~/ 60;
    if (minutes < 60) {
      return '$minutes phút';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours giờ ${mins > 0 ? "$mins phút" : ""}';
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Aggregate statistics model for dashboard/profile
class AggregateStatistics {
  final int totalLessonsCompleted;
  final int totalExercisesCompleted;
  final int totalScorePoints;
  final int totalTimeSpent;
  final int currentStreak; // from users table
  final int totalPoints; // from users table

  AggregateStatistics({
    this.totalLessonsCompleted = 0,
    this.totalExercisesCompleted = 0,
    this.totalScorePoints = 0,
    this.totalTimeSpent = 0,
    this.currentStreak = 0,
    this.totalPoints = 0,
  });

  String get formattedTotalTime {
    if (totalTimeSpent < 60) {
      return '$totalTimeSpent giây';
    }
    final minutes = totalTimeSpent ~/ 60;
    if (minutes < 60) {
      return '$minutes phút';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours giờ ${mins > 0 ? "$mins phút" : ""}';
  }
}
