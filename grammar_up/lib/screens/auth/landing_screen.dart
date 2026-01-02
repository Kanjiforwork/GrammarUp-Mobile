import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/buttons.dart';
import '../../widgets/common/dolphin_mascot.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.white;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.gray600;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Mascot with animation
              const DolphinMascot(
                size: 180,
                showBook: true,
                animate: true,
              ),
              const SizedBox(height: 32),

              // App title
              Text(
                'GRAMMARUP',
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTeal : AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // Tagline
              Text(
                'Start your English learning\njourney now!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 2),

              // Sign Up button with 3D effect
              PrimaryButton(
                text: 'GET STARTED',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SignUpScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Login button
              OutlinedPrimaryButton(
                text: 'I ALREADY HAVE AN ACCOUNT',
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const LoginScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Terms text
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.gray500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
