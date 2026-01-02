import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Duolingo-style 3D Primary Button
/// Has a bottom shadow that creates a 3D effect
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? shadowColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.isLoading = false,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final shadow = widget.shadowColor ?? AppColors.buttonShadow;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? double.infinity,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed || isDisabled
                ? []
                : [
                    BoxShadow(
                      color: shadow,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDisabled ? AppColors.gray300 : bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDisabled ? AppColors.gray500 : AppColors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 20,
                      color: isDisabled ? AppColors.gray500 : AppColors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDisabled ? AppColors.gray500 : AppColors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Duolingo-style 3D Success Button (Green)
class SuccessButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final bool isLoading;

  const SuccessButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  @override
  State<SuccessButton> createState() => _SuccessButtonState();
}

class _SuccessButtonState extends State<SuccessButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? double.infinity,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isPressed || isDisabled
                ? []
                : [
                    const BoxShadow(
                      color: AppColors.successButtonShadow,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDisabled ? AppColors.gray300 : AppColors.success,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  ),
                ] else ...[
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: AppColors.white),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined Button (Secondary style)
class OutlinedPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final bool isLoading;

  const OutlinedPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width,
    this.isLoading = false,
  });

  @override
  State<OutlinedPrimaryButton> createState() => _OutlinedPrimaryButtonState();
}

class _OutlinedPrimaryButtonState extends State<OutlinedPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _isPressed
                ? (isDark ? AppColors.darkSurfaceHighlight : AppColors.teal50)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDisabled ? AppColors.gray300 : primaryColor,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ] else ...[
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 20,
                    color: isDisabled ? AppColors.gray400 : primaryColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDisabled ? AppColors.gray400 : primaryColor,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Social Login Button (for Google, Apple, etc.)
class SocialLoginButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.white);
    final txtColor = widget.textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.gray800);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.gray200;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _isPressed
                ? (isDark ? AppColors.darkSurfaceHighlight : AppColors.gray100)
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                  ),
                ),
              ] else ...[
                widget.icon,
                const SizedBox(width: 12),
                Text(
                  widget.text,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: txtColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Text Button (minimal style)
class GrammarTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const GrammarTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = color ?? (isDark ? AppColors.darkTeal : AppColors.primary);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon Button with background
class GrammarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const GrammarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkSurfaceElevated : AppColors.gray100);
    final icColor = iconColor ?? (isDark ? AppColors.darkTeal : AppColors.primary);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: icColor, size: size * 0.5),
        ),
      ),
    );
  }
}
