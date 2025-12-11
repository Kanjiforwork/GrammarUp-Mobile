import '../models/question_model.dart';

class SampleQuestions {
  static List<Map<String, dynamic>> getSampleQuestionsJson() {
    return [
      // 5 MCQ Questions
      {
        'type': 'MCQ',
        'prompt': 'He _ to school every day.',
        'concept': 'present_simple_verb',
        'level': 'A1',
        'data': {
          'choices': ['go', 'goes', 'is going', 'went'],
          'answerIndex': 1,
        },
      },
      {
        'type': 'MCQ',
        'prompt': 'They _ football on Sundays.',
        'concept': 'present_simple_verb',
        'level': 'A1',
        'data': {
          'choices': ['play', 'plays', 'is playing', 'played'],
          'answerIndex': 0,
        },
      },
      {
        'type': 'MCQ',
        'prompt': 'She _ coffee every morning.',
        'concept': 'present_simple_frequency',
        'level': 'A2',
        'data': {
          'choices': ['drinks', 'drink', 'is drinking', 'drank'],
          'answerIndex': 0,
        },
      },
      {
        'type': 'MCQ',
        'prompt': 'He _ TV after school.',
        'concept': 'present_simple_routine',
        'level': 'A1',
        'data': {
          'choices': ['watches', 'watch', 'is watching', 'watched'],
          'answerIndex': 0,
        },
      },
      {
        'type': 'MCQ',
        'prompt': 'Mary _ to music in her free time.',
        'concept': 'present_simple_habit',
        'level': 'A2',
        'data': {
          'choices': ['listens', 'listen', 'is listening', 'listened'],
          'answerIndex': 0,
        },
      },

      // 5 CLOZE Questions
      {
        'type': 'CLOZE',
        'prompt': 'Complete: I _ (not / to like) vegetables.',
        'concept': 'present_simple_negative',
        'level': 'A1',
        'data': {
          'template': 'I {{1}} vegetables.',
          'answers': ['do not like', "don't like"],
        },
      },
      {
        'type': 'CLOZE',
        'prompt': 'Complete: He _ (to go) to work by bus.',
        'concept': 'present_simple_verb',
        'level': 'A1',
        'data': {
          'template': 'He {{1}} to work by bus.',
          'answers': ['goes'],
        },
      },
      {
        'type': 'CLOZE',
        'prompt': 'Complete: They _ (to read) books every night.',
        'concept': 'present_simple_routine',
        'level': 'A2',
        'data': {
          'template': 'They {{1}} books every night.',
          'answers': ['read'],
        },
      },
      {
        'type': 'CLOZE',
        'prompt': 'Complete: She _ (to live) in Hanoi.',
        'concept': 'present_simple_fact',
        'level': 'A1',
        'data': {
          'template': 'She {{1}} in Hanoi.',
          'answers': ['lives'],
        },
      },
      {
        'type': 'CLOZE',
        'prompt': 'Complete: He _ (to like) chocolate.',
        'concept': 'present_simple_preference',
        'level': 'A2',
        'data': {
          'template': 'He {{1}} chocolate.',
          'answers': ['likes'],
        },
      },

      // 5 ORDER Questions
      {
        'type': 'ORDER',
        'prompt': 'Arrange the words in correct order:',
        'concept': 'present_simple_word_order',
        'level': 'A1',
        'data': {
          'tokens': ['She', 'goes', 'to', 'school', 'every', 'day'],
        },
      },
      {
        'type': 'ORDER',
        'prompt': 'Arrange the words in correct order:',
        'concept': 'present_simple_word_order',
        'level': 'A1',
        'data': {
          'tokens': ['We', 'play', 'football', 'on', 'Saturday'],
        },
      },
      {
        'type': 'ORDER',
        'prompt': 'Arrange the words in correct order:',
        'concept': 'present_simple_word_order',
        'level': 'A2',
        'data': {
          'tokens': ['He', 'drinks', 'coffee', 'in', 'the', 'morning'],
        },
      },
      {
        'type': 'ORDER',
        'prompt': 'Arrange the words in correct order:',
        'concept': 'present_simple_word_order',
        'level': 'A2',
        'data': {
          'tokens': ['They', 'read', 'books', 'every', 'night'],
        },
      },
      {
        'type': 'ORDER',
        'prompt': 'Arrange the words in correct order:',
        'concept': 'present_simple_word_order',
        'level': 'A1',
        'data': {
          'tokens': ['I', 'like', 'tea'],
        },
      },

      // 5 TRANSLATE Questions
      {
        'type': 'TRANSLATE',
        'prompt': 'Dịch câu sau sang tiếng Anh:',
        'concept': 'present_simple_translation',
        'level': 'A1',
        'data': {
          'vietnameseText': 'Cô ấy đi làm mỗi ngày.',
          'correctAnswer': 'She goes to work every day.',
        },
      },
      {
        'type': 'TRANSLATE',
        'prompt': 'Dịch câu sau sang tiếng Anh:',
        'concept': 'present_simple_translation',
        'level': 'A2',
        'data': {
          'vietnameseText': 'Họ chơi bóng vào cuối tuần.',
          'correctAnswer': 'They play football on weekends.',
        },
      },
      {
        'type': 'TRANSLATE',
        'prompt': 'Dịch câu sau sang tiếng Anh:',
        'concept': 'present_simple_translation',
        'level': 'A1',
        'data': {
          'vietnameseText': 'Tôi không thích rau.',
          'correctAnswer': 'I do not like vegetables.',
        },
      },
      {
        'type': 'TRANSLATE',
        'prompt': 'Dịch câu sau sang tiếng Anh:',
        'concept': 'present_simple_translation',
        'level': 'A2',
        'data': {
          'vietnameseText': 'Anh ấy xem TV sau giờ học.',
          'correctAnswer': 'He watches TV after school.',
        },
      },
      {
        'type': 'TRANSLATE',
        'prompt': 'Dịch câu sau sang tiếng Anh:',
        'concept': 'present_simple_translation',
        'level': 'A2',
        'data': {
          'vietnameseText': 'Cô ấy sống ở Hà Nội.',
          'correctAnswer': 'She lives in Hanoi.',
        },
      },
    ];
  }

  static List<Question> getSampleQuestions() {
    return getSampleQuestionsJson()
        .map((json) => Question.fromJson(json))
        .toList();
  }

  // Lấy danh sách câu hỏi theo concept
  static List<Question> getQuestionsByConcept(String concept) {
    return getSampleQuestions()
        .where((q) => q.concept.contains(concept))
        .toList();
  }

  // Lấy danh sách câu hỏi theo level
  static List<Question> getQuestionsByLevel(String level) {
    return getSampleQuestions()
        .where((q) => q.level == level)
        .toList();
  }

  // Lấy danh sách câu hỏi theo type
  static List<Question> getQuestionsByType(String type) {
    return getSampleQuestions()
        .where((q) => q.type == type)
        .toList();
  }
}
