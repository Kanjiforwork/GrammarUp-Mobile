import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DolphinMascot extends StatelessWidget {
  final double size;
  final bool showBook;
  final String? message; // Speech bubble text
  final bool isQuestionType; // true = loại câu hỏi, false = câu hỏi

  const DolphinMascot({
    super.key,
    this.size = 150,
    this.showBook = false,
    this.message,
    this.isQuestionType = false,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu có message, hiển thị với speech bubble
    if (message != null && message!.isNotEmpty) {
      return _buildWithSpeechBubble();
    }
    
    // Nếu không có message, hiển thị dolphin đơn giản
    return _buildSimpleDolphin();
  }

  Widget _buildWithSpeechBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dolphin mascot image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'web/icons/dolphin_book Background Removed.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to emoji if image not found
                  return const Center(
                    child: Text('🐬', style: TextStyle(fontSize: 36)),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Speech bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message!,
                style: TextStyle(
                  fontSize: isQuestionType ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: isQuestionType ? AppColors.primary : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDolphin() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withAlpha(76),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water, size: size * 0.4, color: AppColors.primary),
            if (showBook)
              Icon(Icons.menu_book, size: size * 0.25, color: AppColors.primaryDark),
          ],
        ),
      padding: EdgeInsets.all(size * 0.15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dolphin image
          Image.asset(
            'assets/images/dolphin_wave.png',
            fit: BoxFit.contain,
          ),
          // Book icon (optional, overlay on top right)
          if (showBook)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_book,
                  size: size * 0.2,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
