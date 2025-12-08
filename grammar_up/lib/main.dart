import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/landing_screen.dart';

void main() {
  runApp(const GrammarUpApp());
}

class GrammarUpApp extends StatelessWidget {
  const GrammarUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grammar Up',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}
