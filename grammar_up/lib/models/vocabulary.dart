class Vocabulary {
  final String id;
  final String userId;
  final String word;
  final String? phonetic;
  final String? partOfSpeech;
  final String definition;
  final String? exampleSentence;
  final Map<String, String>? translation;
  final String? difficultyLevel;
  final bool isMastered;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vocabulary({
    required this.id,
    required this.userId,
    required this.word,
    this.phonetic,
    this.partOfSpeech,
    required this.definition,
    this.exampleSentence,
    this.translation,
    this.difficultyLevel,
    this.isMastered = false,
    this.reviewCount = 0,
    this.lastReviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      definition: json['definition'] as String,
      exampleSentence: json['example_sentence'] as String?,
      translation: json['translation'] != null
          ? Map<String, String>.from(json['translation'])
          : null,
      difficultyLevel: json['difficulty_level'] as String?,
      isMastered: json['is_mastered'] as bool? ?? false,
      reviewCount: json['review_count'] as int? ?? 0,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.parse(json['last_reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'word': word,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example_sentence': exampleSentence,
      'translation': translation,
      'difficulty_level': difficultyLevel,
      'is_mastered': isMastered,
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // For inserting new vocabulary (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'word': word,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example_sentence': exampleSentence,
      'translation': translation,
      'difficulty_level': difficultyLevel,
      'is_mastered': isMastered,
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
    };
  }
}
