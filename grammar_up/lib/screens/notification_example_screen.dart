import 'package:flutter/material.dart';
import '../services/notification_platform_service.dart';

/// Example screen demonstrating notification features
/// 
/// This shows how to use the notification system in your app.
/// You can copy these examples to use notifications anywhere.
class NotificationExampleScreen extends StatefulWidget {
  const NotificationExampleScreen({super.key});

  @override
  State<NotificationExampleScreen> createState() => _NotificationExampleScreenState();
}

class _NotificationExampleScreenState extends State<NotificationExampleScreen> {
  final NotificationPlatformService _notificationService = NotificationPlatformService();
  String? _fcmToken;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
    _loadFCMToken();
  }

  Future<void> _loadNotificationStatus() async {
    final enabled = await _notificationService.isNotificationEnabled();
    setState(() {
      _isEnabled = enabled;
    });
  }

  Future<void> _loadFCMToken() async {
    final token = await _notificationService.getFCMToken();
    setState(() {
      _fcmToken = token;
    });
  }

  Future<void> _showSimpleNotification() async {
    final success = await _notificationService.showLocalNotification(
      title: 'Simple Notification',
      body: 'This is a basic local notification',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Notification sent!' : 'Failed to send')),
      );
    }
  }

  Future<void> _showGrammarTip() async {
    await _notificationService.showLocalNotification(
      title: 'Grammar Tip 💡',
      body: 'Use "a" before consonants and "an" before vowels',
    );
  }

  Future<void> _showDailyChallenge() async {
    await _notificationService.showLocalNotification(
      title: 'Daily Challenge 🎯',
      body: 'Complete 5 exercises today to maintain your streak!',
    );
  }

  Future<void> _showAchievement() async {
    await _notificationService.showLocalNotification(
      title: '🏆 Achievement Unlocked!',
      body: 'You\'ve completed 10 lessons in a row!',
    );
  }

  Future<void> _subscribeToGrammarTips() async {
    final success = await _notificationService.subscribeToTopic('grammar_tips');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Subscribed to Grammar Tips!' 
            : 'Failed to subscribe'),
        ),
      );
    }
  }

  Future<void> _subscribeToChallenges() async {
    final success = await _notificationService.subscribeToTopic('daily_challenges');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Subscribed to Daily Challenges!' 
            : 'Failed to subscribe'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Enabled: ${_isEnabled ? "✅ Yes" : "❌ No"}'),
                  const SizedBox(height: 8),
                  const Text(
                    'FCM Token:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _fcmToken ?? 'Loading...',
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          const Text(
            'Local Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Example: Simple notification
          ElevatedButton.icon(
            onPressed: _showSimpleNotification,
            icon: const Icon(Icons.notifications),
            label: const Text('Show Simple Notification'),
          ),
          
          // Example: Grammar tip
          ElevatedButton.icon(
            onPressed: _showGrammarTip,
            icon: const Icon(Icons.lightbulb),
            label: const Text('Show Grammar Tip'),
          ),
          
          // Example: Daily challenge
          ElevatedButton.icon(
            onPressed: _showDailyChallenge,
            icon: const Icon(Icons.emoji_events),
            label: const Text('Show Daily Challenge'),
          ),
          
          // Example: Achievement
          ElevatedButton.icon(
            onPressed: _showAchievement,
            icon: const Icon(Icons.star),
            label: const Text('Show Achievement'),
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Topic Subscriptions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Subscribe to topics
          ElevatedButton.icon(
            onPressed: _subscribeToGrammarTips,
            icon: const Icon(Icons.subscriptions),
            label: const Text('Subscribe to Grammar Tips'),
          ),
          
          ElevatedButton.icon(
            onPressed: _subscribeToChallenges,
            icon: const Icon(Icons.subscriptions),
            label: const Text('Subscribe to Daily Challenges'),
          ),
          
          const SizedBox(height: 24),
          
          // Info card
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 How to Use',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('1. Tap any button to show a local notification'),
                  Text('2. Subscribe to topics to receive push notifications'),
                  Text('3. Send push notifications from Firebase Console'),
                  Text('4. Toggle notifications in Settings tab'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Code example card
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 Code Example',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const SelectableText(
                      '''// Import the service
import 'package:grammar_up/services/notification_platform_service.dart';

// Show notification
final service = NotificationPlatformService();
await service.showLocalNotification(
  title: 'Hello',
  body: 'This is a notification!',
);''',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
