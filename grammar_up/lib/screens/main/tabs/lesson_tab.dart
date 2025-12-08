import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/cards/lesson_node.dart';
import '../exercise_screen.dart';

class LessonTab extends StatelessWidget {
  const LessonTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tĩnh cho các unit
    final List<Map<String, dynamic>> lessons = [
      {'unit': 1, 'title': 'Unit 1', 'completed': true, 'locked': false},
      {'unit': 2, 'title': 'Unit 2', 'completed': true, 'locked': false},
      {'unit': 3, 'title': 'Unit 3', 'completed': false, 'locked': false},
      {'unit': 4, 'title': 'Unit 4', 'completed': false, 'locked': true},
      {'unit': 5, 'title': 'Unit 5', 'completed': false, 'locked': true},
      {'unit': 6, 'title': 'Unit 6', 'completed': false, 'locked': true},
      {'unit': 7, 'title': 'Unit 7', 'completed': false, 'locked': true},
      {'unit': 8, 'title': 'Unit 8', 'completed': false, 'locked': true},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lesson',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Map path layout với zigzag pattern
            ...List.generate(lessons.length, (index) {
              final lesson = lessons[index];
              // Tạo hiệu ứng zigzag: lẻ sang trái, chẵn sang phải
              final alignment = index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight;
              final padding = index % 2 == 0 ? const EdgeInsets.only(left: 60) : const EdgeInsets.only(right: 60);

              return Column(
                children: [
                  Padding(
                    padding: padding,
                    child: Align(
                      alignment: alignment,
                      child: LessonNode(
                        unitNumber: lesson['unit'],
                        title: lesson['title'],
                        isCompleted: lesson['completed'],
                        isLocked: lesson['locked'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ExerciseScreen(title: lesson['title'])),
                          );
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
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.7, size.height);
    } else {
      path.moveTo(size.width * 0.7, 0);
      path.quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.3, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
