class Vocabulary {
  final String id;
  final String word;
  final String? phonetic;
  final String? partOfSpeech;
  final String definition;
  final String? exampleSentence;
  final Map<String, String>? translation;
  final String? difficultyLevel;
  final DateTime createdAt;

  Vocabulary({
    required this.id,
    required this.word,
    this.phonetic,
    this.partOfSpeech,
    required this.definition,
    this.exampleSentence,
    this.translation,
    this.difficultyLevel,
    required this.createdAt,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      definition: json['definition'] as String,
      exampleSentence: json['example_sentence'] as String?,
      translation: json['translation'] != null
          ? Map<String, String>.from(json['translation'])
          : null,
      difficultyLevel: json['difficulty_level'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'part_of_speech': partOfSpeech,
      'definition': definition,
      'example_sentence': exampleSentence,
      'translation': translation,
      'difficulty_level': difficultyLevel,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
