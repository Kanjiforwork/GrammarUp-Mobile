// Base question model
abstract class Question {
  final String? id;
  final String type;
  final String prompt;
  final String concept;
  final String level;
  final String? explanation;
  final int points;

  Question({
    this.id,
    required this.type,
    required this.prompt,
    required this.concept,
    required this.level,
    this.explanation,
    this.points = 10,
  });

  // Factory method để tạo question từ JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'MCQ':
        return MCQQuestion.fromJson(json);
      case 'CLOZE':
        return ClozeQuestion.fromJson(json);
      case 'ORDER':
        return OrderQuestion.fromJson(json);
      case 'TRANSLATE':
        return TranslateQuestion.fromJson(json);
      default:
        throw Exception('Unknown question type: $type');
    }
  }

  // Method để validate câu trả lời
  bool validateAnswer(dynamic userAnswer);
}

// Multiple Choice Question
class MCQQuestion extends Question {
  final List<String> choices;
  final int answerIndex;

  MCQQuestion({
    super.id,
    required super.prompt,
    required super.concept,
    required super.level,
    super.explanation,
    super.points,
    required this.choices,
    required this.answerIndex,
  }) : super(type: 'MCQ');

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MCQQuestion(
      id: json['id'] as String?,
      prompt: json['prompt'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 10,
      choices: List<String>.from(data['choices'] as List),
      answerIndex: data['answerIndex'] as int,
    );
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is int) {
      return userAnswer == answerIndex;
    }
    return false;
  }

  String get correctAnswer => choices[answerIndex];
}

// Fill in the blank (Cloze) Question
class ClozeQuestion extends Question {
  final String template;
  final List<String> answers;

  ClozeQuestion({
    super.id,
    required super.prompt,
    required super.concept,
    required super.level,
    super.explanation,
    super.points,
    required this.template,
    required this.answers,
  }) : super(type: 'CLOZE');

  factory ClozeQuestion.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ClozeQuestion(
      id: json['id'] as String?,
      prompt: json['prompt'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 10,
      template: data['template'] as String,
      answers: List<String>.from(data['answers'] as List),
    );
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is String) {
      final normalized = userAnswer.trim().toLowerCase();
      return answers.any((answer) => answer.trim().toLowerCase() == normalized);
    }
    return false;
  }

  String get correctAnswer => answers.first;
}

// Word ordering (Drag & Drop) Question
class OrderQuestion extends Question {
  final List<String> tokens;

  OrderQuestion({
    super.id,
    required super.prompt,
    required super.concept,
    required super.level,
    super.explanation,
    super.points,
    required this.tokens,
  }) : super(type: 'ORDER');

  factory OrderQuestion.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return OrderQuestion(
      id: json['id'] as String?,
      prompt: json['prompt'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 10,
      tokens: List<String>.from(data['tokens'] as List),
    );
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is List<String>) {
      if (userAnswer.length != tokens.length) return false;
      for (int i = 0; i < tokens.length; i++) {
        if (userAnswer[i] != tokens[i]) return false;
      }
      return true;
    }
    return false;
  }

  String get correctAnswer => tokens.join(' ');
  
  List<String> get shuffledTokens {
    final shuffled = List<String>.from(tokens);
    shuffled.shuffle();
    return shuffled;
  }
}

// Translation Question
class TranslateQuestion extends Question {
  final String vietnameseText;
  final String correctAnswer;

  TranslateQuestion({
    super.id,
    required super.prompt,
    required super.concept,
    required super.level,
    super.explanation,
    super.points,
    required this.vietnameseText,
    required this.correctAnswer,
  }) : super(type: 'TRANSLATE');

  factory TranslateQuestion.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TranslateQuestion(
      id: json['id'] as String?,
      prompt: json['prompt'] as String,
      concept: json['concept'] as String,
      level: json['level'] as String,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 10,
      vietnameseText: data['vietnameseText'] as String,
      correctAnswer: data['correctAnswer'] as String,
    );
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is String) {
      final normalized = userAnswer.trim().toLowerCase();
      final correct = correctAnswer.trim().toLowerCase();
      
      // Chấp nhận nếu giống 90% (để xử lý các trường hợp viết hơi khác)
      return _calculateSimilarity(normalized, correct) >= 0.9;
    }
    return false;
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    
    final longer = s1.length > s2.length ? s1 : s2;
    final shorter = s1.length > s2.length ? s2 : s1;
    
    if (longer.isEmpty) return 1.0;
    
    return (longer.length - _editDistance(longer, shorter)) / longer.length;
  }

  int _editDistance(String s1, String s2) {
    final costs = List.generate(s2.length + 1, (i) => i);
    
    for (int i = 1; i <= s1.length; i++) {
      int lastValue = i;
      for (int j = 1; j <= s2.length; j++) {
        final newValue = s1[i - 1] == s2[j - 1]
            ? costs[j - 1]
            : 1 + [costs[j - 1], lastValue, costs[j]].reduce((a, b) => a < b ? a : b);
        costs[j - 1] = lastValue;
        lastValue = newValue;
      }
      costs[s2.length] = lastValue;
    }
    
    return costs[s2.length];
  }
}
