import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common/buttons.dart';
import '../../widgets/common/dolphin_mascot.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Mascot placeholder
              const DolphinMascot(size: 200),
              const SizedBox(height: 32),
              // App title
              const Text(
                'GRAMMAR UP',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              // Tagline
              const Text(
                'Start your English learning\njourney now!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
              ),
              const Spacer(flex: 2),
              // Sign Up button
              PrimaryButton(
                text: 'SIGN UP',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
              ),
              const SizedBox(height: 16),
              // Login button
              OutlinedPrimaryButton(
                text: 'LOGIN',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
