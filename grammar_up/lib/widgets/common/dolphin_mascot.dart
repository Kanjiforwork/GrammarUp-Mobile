import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DolphinMascot extends StatelessWidget {
  final double size;
  final bool showBook;

  const DolphinMascot({super.key, this.size = 150, this.showBook = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withAlpha(76),
        shape: BoxShape.circle,
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
