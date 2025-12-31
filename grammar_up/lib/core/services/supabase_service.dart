import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient? _client;
  static final _log = AppLogger('SupabaseService');

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        _log.warning('Supabase credentials not found - running in offline mode');
        return;
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _client = Supabase.instance.client;
    } catch (e) {
      _log.warning('Could not initialize Supabase: $e');
    }
  }

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  static String? get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'];
}
