import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/main/main_screen.dart';
import 'services/notification_platform_service.dart';

// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    
    // Set up Firebase Messaging background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
  }
  
  // Initialize Supabase (temporarily disabled - need .env file)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Warning: Supabase not initialized - running in offline mode');
  }
  
  // Initialize notifications
  try {
    final notificationService = NotificationPlatformService();
    await notificationService.initialize();
    print('✅ Notification service initialized');
    
    // Request notification permission
    final hasPermission = await notificationService.requestPermission();
    print('Notification permission: $hasPermission');

    // Get FCM token for push notifications
    final fcmToken = await notificationService.getFCMToken();
    if (fcmToken != null) {
      print('FCM Token: $fcmToken');
      // You can send this token to your backend server if needed
    }

    // Subscribe to a default topic (optional)
    await notificationService.subscribeToTopic('all_users');
  } catch (e) {
    print('⚠️ Notification initialization failed: $e');
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
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        
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
      print('A new onMessageOpenedApp event was published!');
      // Navigate to specific screen based on notification data
      // You can implement custom navigation logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Grammar Up',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
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
