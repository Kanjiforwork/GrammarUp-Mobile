import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const GrammarUpApp());
}

class GrammarUpApp extends StatelessWidget {
  const GrammarUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Grammar Up',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Debug log
        print('[AuthWrapper] Status: ${authProvider.status}, Authenticated: ${authProvider.isAuthenticated}');
        
        // Show splash screen while checking auth status
        if (authProvider.status == AuthStatus.initial || authProvider.status == AuthStatus.loading) {
          return const SplashScreen();
        }
        
        // Show main screen if authenticated
        if (authProvider.isAuthenticated) {
          print('[AuthWrapper] ✅ Showing MainScreen');
          return const MainScreen();
        }
        
        // Show landing screen if not authenticated
        print('[AuthWrapper] 🔵 Showing LandingScreen');
        return const LandingScreen();
      },
    );
  }
}
