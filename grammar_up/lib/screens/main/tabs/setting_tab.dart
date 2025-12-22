import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/landing_screen.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

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
    
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
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
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: l10n?.changePassword ?? 'Change Password',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.notifications_outlined,
                title: l10n?.notifications ?? 'Notifications',
                onTap: () {},
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
                  value: settingsProvider.darkMode,
                  onChanged: (value) => settingsProvider.setDarkMode(value),
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () => settingsProvider.setDarkMode(!settingsProvider.darkMode),
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
