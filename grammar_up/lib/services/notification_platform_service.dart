import 'package:flutter/services.dart';

class NotificationPlatformService {
  static const MethodChannel _channel =
      MethodChannel('com.example.grammar_up/notifications');

  static final NotificationPlatformService _instance =
      NotificationPlatformService._internal();

  factory NotificationPlatformService() => _instance;

  NotificationPlatformService._internal();

  /// Initialize the notification system
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error initializing notifications: ${e.message}');
      return false;
    }
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error requesting notification permission: ${e.message}');
      return false;
    }
  }

  /// Check if notifications are enabled in local preferences
  Future<bool> isNotificationEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isNotificationEnabled');
      return result ?? true;
    } on PlatformException catch (e) {
      print('Error checking notification enabled: ${e.message}');
      return true;
    }
  }

  /// Set notification enabled state in local preferences
  Future<bool> setNotificationEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setNotificationEnabled',
        {'enabled': enabled},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error setting notification enabled: ${e.message}');
      return false;
    }
  }

  /// Show a local notification
  Future<bool> showLocalNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'showLocalNotification',
        {
          'title': title,
          'body': body,
          'id': id ?? DateTime.now().millisecondsSinceEpoch,
        },
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error showing local notification: ${e.message}');
      return false;
    }
  }

  /// Get FCM token for push notifications
  Future<String?> getFCMToken() async {
    try {
      final token = await _channel.invokeMethod<String>('getFCMToken');
      return token;
    } on PlatformException catch (e) {
      print('Error getting FCM token: ${e.message}');
      return null;
    }
  }

  /// Subscribe to a topic for push notifications
  Future<bool> subscribeToTopic(String topic) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'subscribeToTopic',
        {'topic': topic},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error subscribing to topic: ${e.message}');
      return false;
    }
  }

  /// Unsubscribe from a topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'unsubscribeFromTopic',
        {'topic': topic},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error unsubscribing from topic: ${e.message}');
      return false;
    }
  }
}
