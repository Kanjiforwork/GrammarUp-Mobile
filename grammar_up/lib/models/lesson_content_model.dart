class LessonContentModel {
  final String id;
  final String lessonId;
  final String contentType; // 'text', 'example', 'rule', 'tip', 'warning', 'practice'
  final Map<String, dynamic> contentData; // JSON data
  final int orderIndex;
  final DateTime createdAt;

  LessonContentModel({
    required this.id,
    required this.lessonId,
    required this.contentType,
    required this.contentData,
    required this.orderIndex,
    required this.createdAt,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      contentType: json['content_type'] as String,
      contentData: json['content_data'] as Map<String, dynamic>? ?? {},
      orderIndex: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'content_type': contentType,
      'content_data': contentData,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper getters to extract from contentData
  String? get title => contentData['title'] as String?;
  String? get content => contentData['content'] as String?;
  String? get exampleCorrect => contentData['example_correct'] as String?;
  String? get exampleIncorrect => contentData['example_incorrect'] as String?;
  String? get explanation => contentData['explanation'] as String?;

  // Helper to check content type
  bool get isText => contentType == 'text';
  bool get isExample => contentType == 'example';
  bool get isRule => contentType == 'rule';
  bool get isTip => contentType == 'tip';
  bool get isWarning => contentType == 'warning';
  bool get isPractice => contentType == 'practice';
}
