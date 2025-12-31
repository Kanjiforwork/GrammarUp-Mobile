import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/chat_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/utils/logger.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/notification_platform_service.dart';

final _log = AppLogger('Main');

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) debugPrint('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    _log.success('Firebase initialized successfully');

    // Set up Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    _log.warning('Firebase initialization failed: $e');
  }

  // Initialize Supabase (temporarily disabled - need .env file)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    _log.warning('Supabase not initialized - running in offline mode');
  }

  // Initialize notifications
  try {
    final notificationService = NotificationPlatformService();
    await notificationService.initialize();
    _log.success('Notification service initialized');

    // Request notification permission
    final hasPermission = await notificationService.requestPermission();
    _log.debug('Notification permission: $hasPermission');

    // Get FCM token for push notifications
    final fcmToken = await notificationService.getFCMToken();
    if (fcmToken != null) {
      _log.debug('FCM Token received');
    }

    // Subscribe to a default topic (optional)
    await notificationService.subscribeToTopic('all_users');
  } catch (e) {
    _log.warning('Notification initialization failed: $e');
  }

  runApp(const GrammarUpApp());
}

class GrammarUpApp extends StatefulWidget {
  const GrammarUpApp({super.key});

  @override
  State<GrammarUpApp> createState() => _GrammarUpAppState();
}

class _GrammarUpAppState extends State<GrammarUpApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _log.debug('Got a message whilst in the foreground!');

      if (message.notification != null) {
        // Show local notification when app is in foreground
        final notificationService = NotificationPlatformService();
        notificationService.showLocalNotification(
          title: message.notification!.title ?? 'Grammar Up',
          body: message.notification!.body ?? '',
        );
      }
    });

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _log.debug('Notification opened app');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settingsProvider, _) {
          return MaterialApp(
            title: 'Grammar Up',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
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

  static final _authLog = AppLogger('AuthWrapper');

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        _authLog.debug('Status: ${authProvider.status}, Authenticated: ${authProvider.isAuthenticated}');

        // Show splash screen while checking auth status
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return const SplashScreen();
        }

        // Show main screen if authenticated
        if (authProvider.isAuthenticated) {
          return const MainScreen();
        }

        // Show landing screen if not authenticated
        return const LandingScreen();
      },
    );
  }
}
