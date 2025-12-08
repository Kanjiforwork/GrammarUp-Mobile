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
      decoration: BoxDecoration(color: AppColors.primaryLight.withAlpha(76), shape: BoxShape.circle),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water, size: size * 0.4, color: AppColors.primary),
            if (showBook) Icon(Icons.menu_book, size: size * 0.25, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }
}
