import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/notification_platform_service.dart';
import '../../auth/landing_screen.dart';
import '../../profile/edit_profile_screen.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  bool _notificationsEnabled = true;
  bool _isLoadingNotifications = false;
  final NotificationPlatformService _notificationService = NotificationPlatformService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final enabled = await _notificationService.isNotificationEnabled();
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
        });
      }
    } catch (e) {
      print('Error loading notification preference: $e');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      // Request permission first (Android 13+)
      if (value) {
        final hasPermission = await _notificationService.requestPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please grant notification permission in Android settings'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          setState(() {
            _isLoadingNotifications = false;
          });
          return;
        }
      }
      
      final success = await _notificationService.setNotificationEnabled(value);
      
      if (success) {
        setState(() {
          _notificationsEnabled = value;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value ? 'Notifications enabled' : 'Notifications disabled',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Show a test notification when enabled
        if (value) {
          await _notificationService.showLocalNotification(
            title: 'Grammar Up',
            body: 'Notifications are now enabled!',
          );
        }
      } else {
        // Revert the change if it failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update notification settings'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _testNotification() async {
    // First check if notifications are enabled
    final isEnabled = await _notificationService.isNotificationEnabled();
    
    if (!isEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable notifications first'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Request permission if not granted (Android 13+)
    final hasPermission = await _notificationService.requestPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please grant notification permission in Android settings'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Show test notification
    final success = await _notificationService.showLocalNotification(
      title: '🎯 Test Notification',
      body: 'This is a test notification from Grammar Up!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '✅ Test notification sent! Check your notification tray.' 
            : '❌ Failed to send notification'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account section
          _buildSectionHeader('Account'),
          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildSettingItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () {}),
          
          // Notification toggle
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Nhận thông báo',
            trailing: _isLoadingNotifications
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                    activeTrackColor: AppColors.primary,
                  ),
            onTap: () {},
          ),
          
          // Test notification button
          _buildSettingItem(
            icon: Icons.notifications_active,
            title: 'Test Notification',
            subtitle: 'Send a test notification',
            onTap: _testNotification,
          ),
          const SizedBox(height: 16),
          // Preferences section
          _buildSectionHeader('Preferences'),
          _buildSettingItem(icon: Icons.language, title: 'Language', subtitle: 'English', onTap: () {}),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(value: false, onChanged: (value) {}, activeTrackColor: AppColors.primary),
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.volume_up_outlined,
            title: 'Sound Effects',
            trailing: Switch(value: true, onChanged: (value) {}, activeTrackColor: AppColors.primary),
            onTap: () {},
          ),
          const SizedBox(height: 16),
          // Support section
          _buildSectionHeader('Support'),
          _buildSettingItem(icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
          _buildSettingItem(icon: Icons.info_outline, title: 'About', onTap: () {}),
          _buildSettingItem(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () {}),
          _buildSettingItem(icon: Icons.description_outlined, title: 'Terms of Service', onTap: () {}),
          const SizedBox(height: 16),
          // Logout
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Log Out',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await authProvider.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LandingScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 32),
          // Version
          const Center(
            child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor ?? AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
