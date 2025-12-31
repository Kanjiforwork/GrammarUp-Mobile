import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/question_model.dart';
import '../utils/logger.dart';

final _log = AppLogger('AIExplanationService');

class AIExplanationService {
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    
    final apiKey = dotenv.env['GPT_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GPT_KEY not found in .env file');
    }
    
    OpenAI.apiKey = apiKey;
    _initialized = true;
  }

  static String _getTranslatePrompt({
    required String question,
    required String correctAnswer,
    required String userAnswer,
    required String questionType,
  }) {
    return '''Bạn là một gia sư tiếng Anh Gen Z thân thiện và công bằng.
   Học sinh vừa trả lời một câu hỏi tiếng Anh. Nhiệm vụ của bạn là kiểm tra toàn diện — bao gồm cả chính tả, ngữ pháp và cấu trúc câu.
  
   Câu hỏi: $question
   Đáp án đúng: $correctAnswer
   Đáp án của học sinh: $userAnswer
   Loại câu hỏi: $questionType
  
   Hãy thực hiện theo thứ tự:
   1. Kiểm tra lỗi chính tả hoặc đánh máy.
   2. So sánh cấu trúc câu giữa hai đáp án:
      - Chủ ngữ (subject) có giống hoặc phù hợp không?
      - Động từ (verb) có đúng thì và dạng không?
      - Tân ngữ (object) và trật tự từ có đúng không?
   3. Sau đó, so sánh ý nghĩa tổng thể — nếu ý nghĩa tương đương nhưng cấu trúc sai, hãy nói rõ lỗi nào sai.
   4. Nếu học sinh dùng cấu trúc khác nhưng vẫn diễn đạt đúng ý, hãy ghi nhận điều đó.
   5. Giải thích dễ hiểu, thân thiện, không gạch đầu dòng hay số thứ tự.
   6. Kết thúc bằng 1 câu khích lệ kiểu: "Cố lên nha, ai cũng sai mà hihi 🙆‍♂️"
  
   Giọng văn: thân thiện, tự nhiên, Gen Z vibe.
   Ngắn gọn (tối đa 200 từ), không liệt kê số, không quá hàn lâm.''';
  }

  static String _getOtherQuestionPrompt({
    required String question,
    required String correctAnswer,
    required String userAnswer,
    required String questionType,
  }) {
    return '''You are a friendly Gen Z English tutor. A student just answered an English question.

Question: $question
Student's answer: $userAnswer
Expected correct answer: $correctAnswer
Question type: $questionType

YOUR TASK:
1. First, independently analyze if the student's answer is grammatically correct
2. Check for spelling, grammar, and sentence structure errors
3. Compare with the expected answer
4. If the student is ACTUALLY CORRECT but different from expected answer, acknowledge it!

IMPORTANT:
- The "correct answer" might be wrong! Use your grammar expertise to judge.
- For "Neither...nor" / "Either...or": verb agrees with CLOSEST subject
- Be fair and accurate in your assessment

Response format (in Vietnamese, Gen Z friendly):
1. Greeting: Use "Hế lu" or "À câu này..." (1 line)
2. Analysis:
  - If student is WRONG: Explain why (grammar rules, spelling, etc.)
  - If student is ACTUALLY RIGHT but marked wrong: "Ê khoan, câu này bạn làm đúng mà! Đáp án gợi ý có vẻ bị nhầm..."
  - If expected answer is wrong: Point it out clearly
3. Correct explanation: Explain the right grammar rule

Tone: Friendly, natural, Gen Z vibe
Length: Max 200 words, no numbered lists, not too academic

Think step by step before responding.''';
  }

  static Future<String> explainAnswer({
    required Question question,
    required dynamic userAnswer,
    required bool isCorrect,
  }) async {
    try {
      initialize();

      // Nếu đúng thì không cần giải thích
      if (isCorrect) {
        return '';
      }

      String questionText = '';
      String correctAnswerText = '';
      String userAnswerText = '';
      String questionType = '';
      bool isTranslateQuestion = question is TranslateQuestion;

      // Lấy thông tin câu hỏi theo loại
      if (question is MCQQuestion) {
        questionText = question.prompt;
        correctAnswerText = question.choices[question.answerIndex];
        userAnswerText = userAnswer != null ? question.choices[userAnswer as int] : 'Không có đáp án';
        questionType = 'Multiple Choice';
      } else if (question is ClozeQuestion) {
        questionText = question.template;
        correctAnswerText = question.correctAnswer;
        userAnswerText = userAnswer?.toString() ?? 'Không có đáp án';
        questionType = 'Fill in the Blank';
      } else if (question is OrderQuestion) {
        questionText = 'Sắp xếp từ: ${question.tokens.join(", ")}';
        correctAnswerText = question.correctAnswer;
        userAnswerText = (userAnswer as List<String>?)?.join(' ') ?? 'Không có đáp án';
        questionType = 'Word Order';
      } else if (question is TranslateQuestion) {
        questionText = question.vietnameseText;
        correctAnswerText = question.correctAnswer;
        userAnswerText = userAnswer?.toString() ?? 'Không có đáp án';
        questionType = 'Translation';
      }

      // Chọn prompt phù hợp
      final prompt = isTranslateQuestion
          ? _getTranslatePrompt(
              question: questionText,
              correctAnswer: correctAnswerText,
              userAnswer: userAnswerText,
              questionType: questionType,
            )
          : _getOtherQuestionPrompt(
              question: questionText,
              correctAnswer: correctAnswerText,
              userAnswer: userAnswerText,
              questionType: questionType,
            );

      // Gọi OpenAI API
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
        maxTokens: 300,
        temperature: 0.7,
      );

      final content = response.choices.first.message.content;
      if (content != null && content.isNotEmpty) {
        return content.first.text ?? 'Không thể tạo giải thích lúc này.';
      }
      return 'Không thể tạo giải thích lúc này.';
    } catch (e) {
      _log.error('Error getting AI explanation', e);
      return 'Có lỗi xảy ra khi tạo giải thích. Vui lòng thử lại sau.';
    }
  }
}
