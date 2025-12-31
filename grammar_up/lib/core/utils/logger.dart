import 'package:flutter/foundation.dart';

/// Simple logger utility that only logs in debug mode
class AppLogger {
  final String _tag;

  AppLogger(this._tag);

  void debug(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] $message');
    }
  }

  void info(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] ℹ️ $message');
    }
  }

  void success(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] ✅ $message');
    }
  }

  void warning(String message) {
    if (kDebugMode) {
      debugPrint('[$_tag] ⚠️ $message');
    }
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ❌ $message');
      if (error != null) {
        debugPrint('[$_tag] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag] StackTrace: $stackTrace');
      }
    }
  }
}
