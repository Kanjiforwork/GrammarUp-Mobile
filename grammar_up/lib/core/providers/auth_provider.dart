import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
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
      print('[AuthProvider] 🔔 Auth state changed: ${data.event}');
      if (data.event == AuthChangeEvent.signedIn) {
        print('[AuthProvider] 🔔 SignedIn event - loading profile');
        _loadUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        print('[AuthProvider] 🔔 SignedOut event');
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    // Check initial auth state
    if (_authService.isLoggedIn) {
      print('[AuthProvider] 🔵 Initial check: User is logged in');
      _loadUserProfile();
    } else {
      print('[AuthProvider] 🔵 Initial check: User is not logged in');
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
          // Profile không tồn tại, nhưng user đã authenticated
          // Giữ status hiện tại, không reset về unauthenticated
          print('[AuthProvider] ⚠️ User profile not found, but user is authenticated');
        }
      } else {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('[AuthProvider] 🔴 Error loading profile: $e');
      // Không thay đổi status nếu đã authenticated
      if (_status != AuthStatus.authenticated) {
        _status = AuthStatus.unauthenticated;
      }
      _errorMessage = e.toString();
    }
    notifyListeners();
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
      print('[AuthProvider] 🔵 Starting sign in');
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (_currentUser != null) {
        print('[AuthProvider] ✅ Sign in successful, setting authenticated status');
        _status = AuthStatus.authenticated;
        notifyListeners();
        print('[AuthProvider] ✅ Notified listeners, status: $_status');
        return true;
      }

      print('[AuthProvider] 🔴 Sign in failed: no user returned');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      print('[AuthProvider] 🔴 Sign in error: $e');
      _errorMessage = _getErrorMessage(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('[AuthProvider] 🔵 Starting Google Sign In');
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();

      // On web, OAuth redirect will trigger auth state change listener
      // So we might not get the user immediately
      if (result != null) {
        print('[AuthProvider] ✅ Google Sign In successful');
        _currentUser = result;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      print('[AuthProvider] ⚠️ Google Sign In cancelled or waiting for redirect');
      // Keep loading state for web OAuth redirect
      if (kIsWeb) {
        print('[AuthProvider] 🔵 Keeping loading state for OAuth redirect');
        // Don't change status, wait for auth state listener
        return false;
      }
      
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      print('[AuthProvider] 🔴 Google Sign In error: $e');
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
