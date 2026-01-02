import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/common/buttons.dart';
import '../../widgets/common/dolphin_mascot.dart';
import 'email_auth_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Google sign up failed',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.gray900;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : AppColors.gray600;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.gray800,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Mascot with speech bubble
              const DolphinMascot(
                message: "Let's start your learning adventure together!",
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Create Account',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up to start your learning journey',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 40),

              // Divider with text
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.gray200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Sign up with',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.gray200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Email button
              SocialLoginButton(
                text: 'Continue with Email',
                icon: Icon(
                  Icons.email_outlined,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.gray800,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmailSignUpScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Google button
              SocialLoginButton(
                text: 'Continue with Google',
                icon: Icon(
                  Icons.g_mobiledata_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.gray800,
                  size: 28,
                ),
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _handleGoogleSignUp,
              ),
              const SizedBox(height: 40),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
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
