import 'package:flutter/services.dart';
import '../core/utils/logger.dart';

class NotificationPlatformService {
  static const MethodChannel _channel =
      MethodChannel('com.example.grammar_up/notifications');

  static final NotificationPlatformService _instance =
      NotificationPlatformService._internal();

  factory NotificationPlatformService() => _instance;

  NotificationPlatformService._internal();

  final _log = AppLogger('NotificationService');

  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      _log.error('Error initializing notifications', e);
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      _log.error('Error requesting notification permission', e);
      return false;
    }
  }

  Future<bool> isNotificationEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('isNotificationEnabled');
      return result ?? true;
    } on PlatformException catch (e) {
      _log.error('Error checking notification enabled', e);
      return true;
    }
  }

  Future<bool> setNotificationEnabled(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'setNotificationEnabled',
        {'enabled': enabled},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      _log.error('Error setting notification enabled', e);
      return false;
    }
  }

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
      _log.error('Error showing local notification', e);
      return false;
    }
  }

  Future<String?> getFCMToken() async {
    try {
      final token = await _channel.invokeMethod<String>('getFCMToken');
      return token;
    } on PlatformException catch (e) {
      _log.error('Error getting FCM token', e);
      return null;
    }
  }

  Future<bool> subscribeToTopic(String topic) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'subscribeToTopic',
        {'topic': topic},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      _log.error('Error subscribing to topic', e);
      return false;
    }
  }

  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'unsubscribeFromTopic',
        {'topic': topic},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      _log.error('Error unsubscribing from topic', e);
      return false;
    }
  }
}
