import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/landing_screen.dart';
// import 'core/database/supabase_test.dart'; // Uncomment to test connection

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Uncomment to test Supabase connection
  // await SupabaseConnectionTest.runAllTests();
  
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
