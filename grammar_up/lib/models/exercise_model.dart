class ExerciseModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String concept;
  final String level;
  final String? lessonId;
  final int? estimatedTime;
  final int numQuestions;
  final int totalPoints;
  final int passingScore;
  final String? thumbnailUrl;
  final bool isPublic;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.concept,
    required this.level,
    this.lessonId,
    this.estimatedTime,
    required this.numQuestions,
    required this.totalPoints,
    required this.passingScore,
    this.thumbnailUrl,
    required this.isPublic,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      lessonId: json['lesson_id'] as String?,
      estimatedTime: json['estimated_time'] as int?,
      numQuestions: json['num_questions'] as int? ?? 10,
      totalPoints: json['total_points'] as int? ?? 100,
      passingScore: json['passing_score'] as int? ?? 70,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'concept': concept,
      'level': level,
      'lesson_id': lessonId,
      'estimated_time': estimatedTime,
      'num_questions': numQuestions,
      'total_points': totalPoints,
      'passing_score': passingScore,
      'thumbnail_url': thumbnailUrl,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper để lấy difficulty text dựa trên level
  String get difficultyText {
    switch (level.toLowerCase()) {
      case 'a1':
      case 'a2':
      case 'easy':
      case 'beginner':
        return 'Easy';
      case 'b1':
      case 'b2':
      case 'medium':
      case 'intermediate':
        return 'Medium';
      case 'c1':
      case 'c2':
      case 'hard':
      case 'advanced':
        return 'Hard';
      default:
        return 'Medium';
    }
  }
}
