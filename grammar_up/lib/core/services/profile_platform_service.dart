import 'dart:io';
import 'package:flutter/services.dart';
import 'package:grammar_up/models/user_model.dart';
import 'package:grammar_up/core/services/supabase_service.dart';
import '../utils/logger.dart';

class ProfilePlatformService {
  static const MethodChannel _channel = MethodChannel('com.example.grammar_up/profile');

  static ProfilePlatformService? _instance;
  bool _isInitialized = false;
  final _log = AppLogger('ProfilePlatformService');

  ProfilePlatformService._();

  static ProfilePlatformService get instance {
    _instance ??= ProfilePlatformService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final supabaseUrl = SupabaseService.supabaseUrl;
      final supabaseAnonKey = SupabaseService.supabaseAnonKey;
      final accessToken = SupabaseService.client.auth.currentSession?.accessToken;

      if (supabaseUrl == null || supabaseUrl.isEmpty ||
          supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw PlatformException(
          code: 'MISSING_CONFIG',
          message: 'Supabase URL or Anon Key not configured',
        );
      }

      await _channel.invokeMethod('initializeSupabase', {
        'supabaseUrl': supabaseUrl,
        'supabaseAnonKey': supabaseAnonKey,
        'accessToken': accessToken,
      });

      _isInitialized = true;
    } catch (e) {
      _log.error('Error initializing profile platform service', e);
      rethrow;
    }
  }

  Future<UserProfile> getProfile(String userId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final result = await _channel.invokeMethod('getProfile', {
        'userId': userId,
      });

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Profile data is null',
        );
      }

      return UserProfile.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      _log.error('Platform error getting profile', e);
      rethrow;
    } catch (e) {
      _log.error('Error getting profile', e);
      rethrow;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final args = <String, dynamic>{
        'userId': userId,
      };

      if (fullName != null) args['full_name'] = fullName;
      if (email != null) args['email'] = email;
      if (avatarUrl != null) args['avatar_url'] = avatarUrl;

      final result = await _channel.invokeMethod('updateProfile', args);
      return result == true;
    } on PlatformException catch (e) {
      _log.error('Platform error updating profile', e);
      rethrow;
    } catch (e) {
      _log.error('Error updating profile', e);
      rethrow;
    }
  }

  Future<String> uploadProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw PlatformException(
          code: 'FILE_NOT_FOUND',
          message: 'Image file not found at path: $filePath',
        );
      }

      final result = await _channel.invokeMethod('uploadProfilePicture', {
        'userId': userId,
        'filePath': filePath,
      });

      if (result == null || result.toString().isEmpty) {
        throw PlatformException(
          code: 'UPLOAD_FAILED',
          message: 'Failed to upload profile picture',
        );
      }

      return result.toString();
    } on PlatformException catch (e) {
      _log.error('Platform error uploading profile picture', e);
      rethrow;
    } catch (e) {
      _log.error('Error uploading profile picture', e);
      rethrow;
    }
  }

  Future<String> updateProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    try {
      final avatarUrl = await uploadProfilePicture(
        userId: userId,
        filePath: filePath,
      );

      await updateProfile(
        userId: userId,
        avatarUrl: avatarUrl,
      );

      return avatarUrl;
    } catch (e) {
      _log.error('Error updating profile picture', e);
      rethrow;
    }
  }
}
