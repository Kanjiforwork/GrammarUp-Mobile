import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/landing');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.teal600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with dolphin
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal900.withAlpha(51),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Image.asset(
                      'assets/images/dolphin_wave.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          '🐬',
                          style: TextStyle(fontSize: 80),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // App name
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'GRAMMARUP',
                        style: GoogleFonts.nunito(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Master English with AI',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white.withAlpha(204),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // Loading indicator
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.8,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white.withAlpha(179),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
