import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _log = AppLogger('AuthProvider');

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((AuthState data) {
      _log.debug('Auth state changed: ${data.event}');
      if (data.event == AuthChangeEvent.signedIn) {
        _loadUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    // Check initial auth state
    if (_authService.isLoggedIn) {
      _log.debug('Initial check: User is logged in');
      _loadUserProfile();
    } else {
      _log.debug('Initial check: User is not logged in');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final profile = await _authService.getUserProfile(user.id);
        if (profile != null) {
          _currentUser = profile;
          _status = AuthStatus.authenticated;
          _errorMessage = null;
        } else {
          _log.warning('User profile not found, but user is authenticated');
        }
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _log.error('Error loading profile', e);
      if (_status != AuthStatus.authenticated) {
        _status = AuthStatus.unauthenticated;
      }
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Public method to reload user profile
  Future<void> reloadUserProfile() async {
    await _loadUserProfile();
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (_currentUser != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _log.debug('Starting sign in');
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        _log.success('Sign in successful');
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _log.error('Sign in failed: no user returned');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _log.error('Sign in error', e);
      _errorMessage = _getErrorMessage(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _log.debug('Starting Google Sign In');
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();

      if (result != null) {
        _log.success('Google Sign In successful');
        _currentUser = result;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _log.warning('Google Sign In cancelled or waiting for redirect');
      if (kIsWeb) {
        return false;
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _log.error('Google Sign In error', e);
      _errorMessage = _getErrorMessage(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e.toString());
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    // Authentication errors
    if (errorLower.contains('invalid login credentials') || 
        errorLower.contains('invalid email or password')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    
    // Already registered errors
    if (errorLower.contains('already registered') || 
        errorLower.contains('email already registered')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập';
    }
    
    // Email verification
    if (errorLower.contains('email not confirmed')) {
      return 'Vui lòng xác nhận email của bạn';
    }
    
    // Validation errors
    if (errorLower.contains('invalid email')) {
      return 'Email không hợp lệ';
    }
    
    if (errorLower.contains('password') && 
        (errorLower.contains('6 characters') || errorLower.contains('too short'))) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    
    // Network/Connection errors
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Lỗi kết nối. Vui lòng kiểm tra internet';
    }
    
    // Generic errors
    if (errorLower.contains('sign in failed')) {
      return 'Đăng nhập thất bại. Vui lòng thử lại';
    }
    
    if (errorLower.contains('sign up failed')) {
      return 'Đăng ký thất bại. Vui lòng thử lại';
    }
    
    // Default error
    return 'Đã có lỗi xảy ra. Vui lòng thử lại';
  }
}
