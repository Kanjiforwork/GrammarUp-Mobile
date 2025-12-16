import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Debug logging helper
  void _log(String message) {
    if (kDebugMode) {
      print('[AuthService] $message');
    }
  }

  // Initialize Google Sign In
  // Note:
  // - iOS: Uses Info.plist CFBundleURLSchemes (no serverClientId needed)
  // - Android: Uses serverClientId
  // - Web: Uses OAuth redirect
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: defaultTargetPlatform == TargetPlatform.android ? dotenv.env['GOOGLE_WEB_CLIENT_ID'] : null,
    scopes: ['email', 'profile'],
  );

  // Sign Up with Email & Password
  Future<UserModel?> signUpWithEmail({required String email, required String password, String? fullName}) async {
    try {
      _log('🔵 Starting sign up for: $email');

      // Step 1: Sign up user in Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      _log('🔵 Auth response received. User: ${response.user?.id}');

      // Step 2: Check if sign up was successful
      if (response.user == null) {
        _log('🔴 Sign up failed: No user in response');
        throw Exception('Failed to create account');
      }

      final user = response.user!;
      _log('✅ User created in auth: ${user.id}');

      // Step 3: Ensure user profile exists in users table
      final userProfile = await _ensureUserProfile(
        userId: user.id,
        email: user.email ?? email,
        fullName: fullName ?? user.userMetadata?['full_name'],
      );

      _log('✅ Sign up completed successfully');
      return userProfile;
    } catch (e) {
      _log('🔴 Sign up error: $e');

      // Handle specific error cases
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('already registered') ||
          errorMessage.contains('duplicate') ||
          errorMessage.contains('user already registered')) {
        // User exists, try to sign in
        throw Exception('Email already registered');
      }

      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign In with Email & Password
  Future<UserModel?> signInWithEmail({required String email, required String password}) async {
    try {
      _log('🔵 Starting sign in for: $email');

      // Step 1: Sign in to Supabase Auth
      final AuthResponse response = await _supabase.auth.signInWithPassword(email: email, password: password);

      _log('🔵 Auth response received. User: ${response.user?.id}');

      // Step 2: Check if sign in was successful
      if (response.user == null) {
        _log('🔴 Sign in failed: No user in response');
        throw Exception('Invalid credentials');
      }

      final user = response.user!;
      _log('✅ User authenticated: ${user.id}');

      // Step 3: Ensure user profile exists in users table
      final userProfile = await _ensureUserProfile(
        userId: user.id,
        email: user.email ?? email,
        fullName: user.userMetadata?['full_name'],
      );

      _log('✅ Sign in completed successfully');
      return userProfile;
    } catch (e) {
      _log('🔴 Sign in error: $e');

      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid login credentials') || errorMessage.contains('invalid credentials')) {
        throw Exception('Invalid email or password');
      }

      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Ensure user profile exists in users table (helper method)
  Future<UserModel?> _ensureUserProfile({required String userId, required String email, String? fullName}) async {
    try {
      _log('🔵 Ensuring user profile exists for: $userId');

      // Try to get existing user profile
      UserModel? userProfile = await getUserProfile(userId);

      if (userProfile != null) {
        _log('✅ User profile found in database');
        return userProfile;
      }

      _log('⚠️ User profile not found, creating new one...');

      // Profile doesn't exist, create it
      final now = DateTime.now().toIso8601String();
      final userData = {
        'id': userId,
        'email': email,
        'full_name': fullName,
        'native_language': 'vi',
        'level': 'beginner',
        'learning_streak': 0,
        'total_points': 0,
        'created_at': now,
        'updated_at': now,
      };

      _log('🔵 Inserting user profile into database...');
      await _supabase.from('users').insert(userData);
      _log('✅ User profile created successfully');

      // Fetch and return the newly created profile
      userProfile = await getUserProfile(userId);

      if (userProfile == null) {
        _log('🔴 Failed to fetch newly created profile');
        throw Exception('Failed to create user profile');
      }

      return userProfile;
    } catch (e) {
      _log('🔴 Error ensuring user profile: $e');

      // If insert fails due to duplicate, try to get profile again
      if (e.toString().contains('duplicate') || e.toString().contains('already exists')) {
        _log('⚠️ Duplicate detected, trying to fetch existing profile...');
        final profile = await getUserProfile(userId);
        if (profile != null) {
          _log('✅ Existing profile retrieved');
          return profile;
        }
      }

      throw e;
    }
  }

  // Sign In with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _log('🔵 Starting Google Sign In...');

      // On Web: Use Supabase OAuth with proper redirect
      // On Mobile: Use google_sign_in package (native flow)
      if (kIsWeb) {
        _log('🔵 Using Supabase OAuth for Web...');

        // Get current URL for redirect
        final currentUrl = Uri.base.toString();
        _log('🔵 Current URL: $currentUrl');

        final response = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: currentUrl,
          authScreenLaunchMode: LaunchMode.platformDefault,
        );

        if (!response) {
          _log('⚠️ Google Sign In cancelled or failed');
          return null;
        }

        // Wait for auth state change (OAuth redirect)
        _log('🔵 Waiting for auth state change...');
        int attempts = 0;
        while (attempts < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          final user = _supabase.auth.currentUser;
          if (user != null) {
            _log('✅ Supabase OAuth successful: ${user.id}');

            // Ensure user profile exists
            final userProfile = await _ensureUserProfile(
              userId: user.id,
              email: user.email!,
              fullName: user.userMetadata?['full_name'],
            );

            _log('✅ Google Sign In completed successfully');
            return userProfile;
          }
          attempts++;
        }

        _log('🔴 No user after OAuth timeout');
        return null;
      } else {
        // Mobile: Use google_sign_in package
        _log('🔵 Using Google Sign In package for Mobile...');

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _log('⚠️ Google Sign In cancelled by user');
          return null;
        }

        _log('🔵 Google user selected: ${googleUser.email}');
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        _log('🔵 Google auth tokens obtained');
        _log('   - idToken: ${googleAuth.idToken != null ? "✓" : "✗ NULL"}');
        _log('   - accessToken: ${googleAuth.accessToken != null ? "✓" : "✗ NULL"}');

        if (googleAuth.idToken == null) {
          _log('🔴 idToken is null - cannot sign in to Supabase');
          throw Exception('Failed to get Google ID token');
        }

        _log('🔵 Signing in to Supabase...');
        final AuthResponse response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );

        if (response.user != null) {
          _log('✅ Supabase auth successful: ${response.user!.id}');

          // Ensure user profile exists in users table
          final userProfile = await _ensureUserProfile(
            userId: response.user!.id,
            email: response.user!.email!,
            fullName: googleUser.displayName,
          );

          _log('✅ Google Sign In completed successfully');
          return userProfile;
        }

        _log('🔴 No user in Supabase response');
        return null;
      }
    } catch (e) {
      _log('🔴 Google Sign In error: $e');
      throw Exception('Google sign in failed: $e');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get User Profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      _log('🔵 Fetching user profile for: $userId');

      final response = await _supabase.from('users').select().eq('id', userId).single();

      _log('✅ User profile fetched successfully');
      return UserModel.fromJson(response);
    } catch (e) {
      _log('⚠️ User profile not found: $e');
      return null;
    }
  }

  // Update User Profile
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? nativeLanguage,
    String? level,
  }) async {
    try {
      final updates = {
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'native_language': nativeLanguage,
        'level': level,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Remove null values
      updates.removeWhere((key, value) => value == null);

      await _supabase.from('users').update(updates).eq('id', userId);

      return await getUserProfile(userId);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
