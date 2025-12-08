import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/buttons.dart';
import '../../widgets/common/dolphin_mascot.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToMain(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Mascot
              const DolphinMascot(size: 120, showBook: true),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Welcome Back!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue your learning journey',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              // Continue with Email button
              SocialLoginButton(
                text: 'Continue with Email',
                icon: Icons.email_outlined,
                onPressed: () => _navigateToMain(context),
              ),
              const SizedBox(height: 16),
              // Continue with Google button
              SocialLoginButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onPressed: () => _navigateToMain(context),
              ),
              const Spacer(),
              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
