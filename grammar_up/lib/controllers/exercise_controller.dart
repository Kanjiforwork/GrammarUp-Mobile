import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';

class ExerciseController extends ChangeNotifier {
  final List<Question> _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  Timer? _timer;
  int _elapsedSeconds = 0; // Đổi từ _remainingSeconds thành _elapsedSeconds
  int _totalElapsedSeconds = 0; // Tổng thời gian làm bài
  bool _isCompleted = false;

  ExerciseController({
    required List<Question> questions,
  })  : _questions = questions;

  // Getters
  List<Question> get questions => _questions;
  int get totalQuestions => _questions.length;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => _questions[_currentQuestionIndex];
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get elapsedSeconds => _elapsedSeconds; // Thời gian đã trôi qua
  int get totalElapsedSeconds => _totalElapsedSeconds; // Tổng thời gian
  bool get isCompleted => _isCompleted;
  double get progress => (_currentQuestionIndex + 1) / _questions.length;
  bool get canSubmit => false; // Sẽ được override bởi widgets

  // Khởi động timer - đếm tiến liên tục
  void startTimer() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      _totalElapsedSeconds++;
      notifyListeners();
    });
  }

  // Dừng timer
  void stopTimer() {
    _timer?.cancel();
  }

  // Reset timer cho câu mới - KHÔNG reset _elapsedSeconds
  void resetTimer() {
    // Không làm gì cả - timer tiếp tục đếm
    notifyListeners();
  }

  // Xử lý câu trả lời
  void submitAnswer({
    required dynamic userAnswer,
    required bool isCorrect,
  }) {
    // KHÔNG stop timer - để nó tiếp tục chạy

    if (isCorrect) {
      _correctAnswers++;
      // Tính điểm cơ bản
      _score += 10;
    }

    notifyListeners();
  }

  // Chuyển sang câu hỏi tiếp theo
  void nextQuestion() {
    // KHÔNG stop timer - để timer chạy liên tục

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      // Hoàn thành bài tập - bây giờ mới stop timer
      stopTimer();
      _isCompleted = true;
      notifyListeners();
    }
  }

  // Skip câu hỏi hiện tại
  void skipQuestion() {
    nextQuestion();
  }

  // Format thời gian hiển thị (đếm tiến)
  String get formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format tổng thời gian
  String get formattedTotalTime {
    final minutes = _totalElapsedSeconds ~/ 60;
    final seconds = _totalElapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Tính phần trăm chính xác
  double get accuracy {
    if (_currentQuestionIndex == 0) return 0;
    return (_correctAnswers / (_currentQuestionIndex + (_isCompleted ? 1 : 0))) * 100;
  }

  // Restart bài tập
  void restart() {
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = 0;
    _totalElapsedSeconds = 0;
    _isCompleted = false;
    resetTimer();
    startTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
