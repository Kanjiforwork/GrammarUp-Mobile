import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/lesson_model.dart';
import '../../models/lesson_content_model.dart';
import '../../services/lesson_service.dart';

class LessonDetailScreen extends StatefulWidget {
  final LessonModel lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final LessonService _lessonService = LessonService();
  final PageController _pageController = PageController();

  List<LessonContentModel> _contents = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _startLesson();
  }

  Future<void> _loadContent() async {
    final contents = await _lessonService.getLessonContent(widget.lesson.id);
    setState(() {
      _contents = contents;
      _isLoading = false;
    });
  }

  Future<void> _startLesson() async {
    await _lessonService.startLesson(widget.lesson.id);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeLesson();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeLesson() async {
    _stopTimer();
    await _lessonService.completeLesson(
      lessonId: widget.lesson.id,
      timeSpent: _elapsedSeconds,
    );

    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Hoàn thành!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã hoàn thành bài học "${widget.lesson.title}"'),
            const SizedBox(height: 12),
            Text(
              'Thời gian: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to lesson list
            },
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Text(
          widget.lesson.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contents.isEmpty
              ? _buildEmptyState()
              : _buildContent(isDark),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có nội dung',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Nội dung bài học sẽ sớm được cập nhật',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _contents.isEmpty
                        ? 0
                        : (_currentIndex + 1) / _contents.length,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentIndex + 1}/${_contents.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Content pages
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Update progress
              final progress =
                  ((_currentIndex + 1) / _contents.length * 100).round();
              _lessonService.updateProgress(
                lessonId: widget.lesson.id,
                contentIndex: _currentIndex,
                progressPercentage: progress,
                timeSpent: _elapsedSeconds,
              );
            },
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              return _buildContentCard(_contents[index], isDark);
            },
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Trước'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextPage,
                  icon: Icon(
                    _currentIndex < _contents.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                  ),
                  label: Text(
                    _currentIndex < _contents.length - 1 ? 'Tiếp' : 'Hoàn thành',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(LessonContentModel content, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getContentTypeColor(content.contentType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getContentTypeLabel(content.contentType),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getContentTypeColor(content.contentType),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          if (content.title != null) ...[
            Text(
              content.title!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            child: Text(
              content.content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
          ),

          // Example correct
          if (content.exampleCorrect != null) ...[
            const SizedBox(height: 16),
            _buildExampleBox(
              icon: Icons.check_circle,
              color: Colors.green,
              label: 'Đúng',
              text: content.exampleCorrect!,
              isDark: isDark,
            ),
          ],

          // Example incorrect
          if (content.exampleIncorrect != null) ...[
            const SizedBox(height: 12),
            _buildExampleBox(
              icon: Icons.cancel,
              color: Colors.red,
              label: 'Sai',
              text: content.exampleIncorrect!,
              isDark: isDark,
            ),
          ],

          // Explanation
          if (content.explanation != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Giải thích',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.explanation!,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExampleBox({
    required IconData icon,
    required Color color,
    required String label,
    required String text,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'rule':
        return Colors.purple;
      case 'example':
        return Colors.blue;
      case 'tip':
        return Colors.orange;
      case 'warning':
        return Colors.red;
      case 'practice':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  String _getContentTypeLabel(String type) {
    switch (type) {
      case 'rule':
        return 'Quy tắc';
      case 'example':
        return 'Ví dụ';
      case 'tip':
        return 'Mẹo';
      case 'warning':
        return 'Lưu ý';
      case 'practice':
        return 'Thực hành';
      case 'text':
        return 'Nội dung';
      default:
        return type;
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thoát bài học?'),
        content: const Text(
          'Tiến độ của bạn sẽ được lưu lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () {
              // Save progress before exit
              _lessonService.updateProgress(
                lessonId: widget.lesson.id,
                contentIndex: _currentIndex,
                progressPercentage:
                    ((_currentIndex + 1) / _contents.length * 100).round(),
                timeSpent: _elapsedSeconds,
              );
              _stopTimer();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}
