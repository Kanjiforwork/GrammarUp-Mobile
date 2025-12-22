import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (temporarily disabled - need .env file)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Warning: Supabase not initialized - running in offline mode');
  }
  
  runApp(const GrammarUpApp());
}

class GrammarUpApp extends StatelessWidget {
  const GrammarUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Grammar Up',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: settingsProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthWrapper(),
          );
        },
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
