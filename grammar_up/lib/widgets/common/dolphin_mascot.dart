import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Animated Dolphin Mascot Widget
/// Duolingo-inspired mascot with gentle animations
class DolphinMascot extends StatefulWidget {
  final double size;
  final bool showBook;
  final String? message;
  final bool isQuestionType;
  final bool animate;
  final MascotMood mood;

  const DolphinMascot({
    super.key,
    this.size = 150,
    this.showBook = false,
    this.message,
    this.isQuestionType = false,
    this.animate = true,
    this.mood = MascotMood.happy,
  });

  @override
  State<DolphinMascot> createState() => _DolphinMascotState();
}

enum MascotMood {
  happy,
  thinking,
  celebrating,
  encouraging,
  curious,
  teaching,
}

class _DolphinMascotState extends State<DolphinMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _bobAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message != null && widget.message!.isNotEmpty) {
      return _buildWithSpeechBubble(context);
    }
    return _buildSimpleDolphin(context);
  }

  Widget _buildWithSpeechBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleBg = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final textColor = widget.isQuestionType
        ? borderColor
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Dolphin avatar
          AnimatedBuilder(
            animation: _bobAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, widget.animate ? _bobAnimation.value : 0),
                child: child,
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkTeal : AppColors.primary)
                    .withAlpha(26),
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor.withAlpha(51),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/images/dolphin_wave.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          '🐬',
                          style: TextStyle(fontSize: widget.size * 0.24),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Speech bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: borderColor.withAlpha(77), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message!,
                style: GoogleFonts.nunito(
                  fontSize: widget.isQuestionType ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDolphin(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? _bobAnimation.value : 0),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primaryColor.withAlpha(26),
              primaryColor.withAlpha(10),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: widget.size * 0.95,
              height: widget.size * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withAlpha(51),
                  width: 2,
                ),
              ),
            ),

            // Dolphin image
            Padding(
              padding: EdgeInsets.all(widget.size * 0.15),
              child: Image.asset(
                'assets/images/dolphin_wave.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    '🐬',
                    style: TextStyle(fontSize: widget.size * 0.4),
                  );
                },
              ),
            ),

            // Book icon badge
            if (widget.showBook)
              Positioned(
                bottom: widget.size * 0.05,
                right: widget.size * 0.05,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: primaryColor.withAlpha(51),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: widget.size * 0.15,
                    color: primaryColor,
                  ),
                ),
              ),

            // Mood indicator (sparkles for celebrating, etc.)
            if (widget.mood == MascotMood.celebrating) ...[
              Positioned(
                top: widget.size * 0.1,
                right: widget.size * 0.15,
                child: Icon(
                  Icons.auto_awesome,
                  size: widget.size * 0.12,
                  color: AppColors.warning,
                ),
              ),
              Positioned(
                top: widget.size * 0.2,
                left: widget.size * 0.1,
                child: Icon(
                  Icons.auto_awesome,
                  size: widget.size * 0.08,
                  color: AppColors.warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small Dolphin Avatar for chat messages
class DolphinAvatar extends StatelessWidget {
  final double size;
  final bool showBorder;

  const DolphinAvatar({
    super.key,
    this.size = 40,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(26),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: primaryColor.withAlpha(51), width: 2)
            : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.15),
          child: Image.asset(
            'assets/images/dolphin_wave.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text('🐬', style: TextStyle(fontSize: size * 0.5)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Celebration Mascot - appears after correct answers
class CelebrationMascot extends StatefulWidget {
  final double size;
  final VoidCallback? onAnimationComplete;

  const CelebrationMascot({
    super.key,
    this.size = 80,
    this.onAnimationComplete,
  });

  @override
  State<CelebrationMascot> createState() => _CelebrationMascotState();
}

class _CelebrationMascotState extends State<CelebrationMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: DolphinMascot(
              size: widget.size,
              animate: false,
              mood: MascotMood.celebrating,
            ),
          ),
        );
      },
    );
  }
}
