class LessonModel {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String concept;
  final String level;
  final int orderIndex;
  final int? estimatedTime; // in minutes
  final int numPracticeQuestions;
  final String? thumbnailUrl;
  final bool isPublic;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.concept,
    required this.level,
    required this.orderIndex,
    this.estimatedTime,
    this.numPracticeQuestions = 5,
    this.thumbnailUrl,
    this.isPublic = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      orderIndex: json['order_index'] as int,
      estimatedTime: json['estimated_time'] as int?,
      numPracticeQuestions: json['num_practice_questions'] as int? ?? 5,
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
      'order_index': orderIndex,
      'estimated_time': estimatedTime,
      'num_practice_questions': numPracticeQuestions,
      'thumbnail_url': thumbnailUrl,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getter for difficulty display
  String get difficultyText {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Dễ';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Khó';
      default:
        return level;
    }
  }

  // Helper getter for estimated time display
  String get estimatedTimeText {
    if (estimatedTime == null) return '';
    if (estimatedTime! < 60) {
      return '$estimatedTime phút';
    }
    final hours = estimatedTime! ~/ 60;
    final mins = estimatedTime! % 60;
    if (mins == 0) {
      return '$hours giờ';
    }
    return '$hours giờ $mins phút';
  }
}
