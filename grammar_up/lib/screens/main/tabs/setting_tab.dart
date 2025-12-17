import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/landing_screen.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account section
          _buildSectionHeader('Account'),
          _buildSettingItem(icon: Icons.person_outline, title: 'Edit Profile', onTap: () {}),
          _buildSettingItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () {}),
          _buildSettingItem(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
          const SizedBox(height: 16),
          // Preferences section
          _buildSectionHeader('Preferences'),
          _buildSettingItem(icon: Icons.language, title: 'Language', subtitle: 'English', onTap: () {}),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildSettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () => themeProvider.toggleTheme(),
              );
            },
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
          _buildSettingItem(
            icon: Icons.feedback_outlined, 
            title: 'Feedback', 
            onTap: () {
              _openFeedbackActivity(context);
            }
          ),
          _buildSettingItem(
            icon: Icons.info_outline, 
            title: 'About', 
            onTap: () {
              _openAboutActivity(context);
            }
          ),
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
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFB0B0B0)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Builder(
        builder: (context) => Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFB0B0B0)
                : AppColors.textSecondary,
          ),
        ),
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: titleColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFB0B0B0) : AppColors.textSecondary,
                  ),
                )
              : null,
          trailing: trailing ?? Icon(
            Icons.chevron_right,
            color: isDark ? const Color(0xFFB0B0B0) : AppColors.textSecondary,
          ),
          onTap: onTap,
        );
      },
    );
  }

  static const platform = MethodChannel('com.example.grammar_up/native');

  Future<void> _openFeedbackActivity(BuildContext context) async {
    try {
      await platform.invokeMethod('openFeedback');
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  Future<void> _openAboutActivity(BuildContext context) async {
    try {
      await platform.invokeMethod('openAbout');
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }
}
