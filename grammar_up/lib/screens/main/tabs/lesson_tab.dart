import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../models/lesson_model.dart';
import '../../../models/lesson_progress_model.dart';
import '../../../services/lesson_service.dart';
import '../../../widgets/cards/lesson_node.dart';
import '../lesson_detail_screen.dart';

class LessonTab extends StatefulWidget {
  const LessonTab({super.key});

  @override
  State<LessonTab> createState() => _LessonTabState();
}

class _LessonTabState extends State<LessonTab> {
  final LessonService _lessonService = LessonService();
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final lessons = await _lessonService.getLessons();
    final progressMap = await _lessonService.getAllProgress();
    return {
      'lessons': lessons,
      'progress': progressMap,
    };
  }

  void _refreshData() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Lesson',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          final lessons = snapshot.data?['lessons'] as List<LessonModel>? ?? [];
          final progressMap = snapshot.data?['progress'] as Map<String, LessonProgressModel>? ?? {};

          if (lessons.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildLessonList(context, lessons, progressMap);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài học',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các bài học sẽ xuất hiện tại đây',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Đã xảy ra lỗi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonList(
    BuildContext context,
    List<LessonModel> lessons,
    Map<String, LessonProgressModel> progressMap,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Map path layout với zigzag pattern
          ...List.generate(lessons.length, (index) {
            final lesson = lessons[index];
            final progress = progressMap[lesson.id];

            // Xác định trạng thái
            final isCompleted = progress?.isCompleted ?? false;
            // Lesson đầu tiên hoặc lesson trước đã hoàn thành thì không khóa
            final isLocked = index > 0 &&
                !(progressMap[lessons[index - 1].id]?.isCompleted ?? false);

            // Tạo hiệu ứng zigzag: lẻ sang trái, chẵn sang phải
            final alignment = index % 2 == 0
                ? Alignment.centerLeft
                : Alignment.centerRight;
            final padding = index % 2 == 0
                ? const EdgeInsets.only(left: 60)
                : const EdgeInsets.only(right: 60);

            return Column(
              children: [
                Padding(
                  padding: padding,
                  child: Align(
                    alignment: alignment,
                    child: LessonNode(
                      unitNumber: index + 1,
                      title: lesson.title,
                      isCompleted: isCompleted,
                      isLocked: isLocked,
                      onTap: () {
                        if (isLocked) return;

                        final settingsProvider =
                            Provider.of<SettingsProvider>(context, listen: false);
                        final soundService = SoundService();
                        soundService.setSoundEnabled(settingsProvider.soundEffects);
                        soundService.playClick();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonDetailScreen(lesson: lesson),
                          ),
                        ).then((_) => _refreshData());
                      },
                    ),
                  ),
                ),
                // Đường nối giữa các node
                if (index < lessons.length - 1)
                  SizedBox(
                    height: 40,
                    child: CustomPaint(
                      painter: _PathPainter(isLeftToRight: index % 2 == 0),
                      size: const Size(double.infinity, 40),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Custom painter để vẽ đường nối
class _PathPainter extends CustomPainter {
  final bool isLeftToRight;

  _PathPainter({required this.isLeftToRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isLeftToRight) {
      path.moveTo(size.width * 0.3, 0);
      path.quadraticBezierTo(
          size.width * 0.5, size.height * 0.5, size.width * 0.7, size.height);
    } else {
      path.moveTo(size.width * 0.7, 0);
      path.quadraticBezierTo(
          size.width * 0.5, size.height * 0.5, size.width * 0.3, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
