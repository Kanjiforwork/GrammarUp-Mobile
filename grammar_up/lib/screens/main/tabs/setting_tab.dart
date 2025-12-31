import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/l10n/app_localizations.dart';
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
      debugPrint('Error loading notification preference: $e');
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
      debugPrint('Error toggling notifications: $e');
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

  void _showLanguageSelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    soundService.playClick();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.selectLanguage ?? 'Select Language',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...AppLanguage.values.map((language) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: settingsProvider.language == language
                      ? AppColors.primary.withAlpha(25)
                      : Colors.grey.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.language,
                  color: settingsProvider.language == language
                      ? AppColors.primary
                      : Colors.grey,
                ),
              ),
              title: Text(
                language.displayName,
                style: TextStyle(
                  fontWeight: settingsProvider.language == language
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: settingsProvider.language == language
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              trailing: settingsProvider.language == language
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                settingsProvider.setLanguage(language);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              l10n?.settings ?? 'Settings',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Account section
              _buildSectionHeader(l10n?.accountSection ?? 'Account'),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: l10n?.editProfile ?? 'Edit Profile',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  
                  // Reload profile if changes were saved
                  if (result == true && mounted) {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.reloadUserProfile();
                  }
                },
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: l10n?.changePassword ?? 'Change Password',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: l10n?.notifications ?? 'Notifications',
                trailing: _isLoadingNotifications
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeTrackColor: AppColors.primary,
                      ),
                onTap: () => _toggleNotifications(!_notificationsEnabled),
              ),
              const SizedBox(height: 16),
              // Preferences section
              _buildSectionHeader(l10n?.preferencesSection ?? 'Preferences'),
              _buildSettingItem(
                icon: Icons.language,
                title: l10n?.language ?? 'Language',
                subtitle: settingsProvider.language.displayName,
                onTap: () => _showLanguageSelector(context),
              ),
              _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: l10n?.darkMode ?? 'Dark Mode',
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value);
                  },
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () {
                  final isDark = themeProvider.themeMode == ThemeMode.dark;
                  themeProvider.setThemeMode(!isDark);
                },
              ),
              _buildSettingItem(
                icon: Icons.volume_up_outlined,
                title: l10n?.soundEffects ?? 'Sound Effects',
                trailing: Switch(
                  value: settingsProvider.soundEffects,
                  onChanged: (value) {
                    settingsProvider.setSoundEffects(value);
                    // Play a sound to demonstrate it's on
                    if (value) {
                      final soundService = SoundService();
                      soundService.setSoundEnabled(true);
                      soundService.playSuccess();
                    }
                  },
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () {
                  final newValue = !settingsProvider.soundEffects;
                  settingsProvider.setSoundEffects(newValue);
                  if (newValue) {
                    final soundService = SoundService();
                    soundService.setSoundEnabled(true);
                    soundService.playSuccess();
                  }
                },
              ),
              const SizedBox(height: 16),
              // Support section
              _buildSectionHeader(l10n?.supportSection ?? 'Support'),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: l10n?.helpCenter ?? 'Help Center',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info_outline,
                title: l10n?.about ?? 'About',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: l10n?.privacyPolicy ?? 'Privacy Policy',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: l10n?.termsOfService ?? 'Terms of Service',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              // Logout
              _buildSettingItem(
                icon: Icons.logout,
                title: l10n?.logOut ?? 'Log Out',
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n?.logOut ?? 'Log Out'),
                      content: Text(l10n?.logOutConfirm ?? 'Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n?.cancel ?? 'Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n?.logOut ?? 'Log Out', style: const TextStyle(color: Colors.red)),
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
              Center(
                child: Text(
                  '${l10n?.version ?? 'Version'} 1.0.0',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
