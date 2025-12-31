class LessonProgressModel {
  final String id;
  final String userId;
  final String lessonId;
  final String status; // 'not_started', 'in_progress', 'completed'
  final int lastQuestionIndex;
  final int timeSpent; // in seconds
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonProgressModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.status,
    this.lastQuestionIndex = 0,
    this.timeSpent = 0,
    this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      status: json['status'] as String? ?? 'not_started',
      lastQuestionIndex: json['last_question_index'] as int? ?? 0,
      timeSpent: json['time_spent'] as int? ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'status': status,
      'last_question_index': lastQuestionIndex,
      'time_spent': timeSpent,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isNotStarted => status == 'not_started';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';

  // Format time spent
  String get formattedTimeSpent {
    if (timeSpent < 60) {
      return '$timeSpent giây';
    }
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    if (minutes < 60) {
      return '$minutes phút ${seconds > 0 ? "$seconds giây" : ""}';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours giờ ${mins > 0 ? "$mins phút" : ""}';
  }
}
