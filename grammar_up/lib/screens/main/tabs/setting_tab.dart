import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingTab extends StatelessWidget {
  const SettingTab({super.key});

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
          _buildSettingItem(icon: Icons.person_outline, title: 'Edit Profile', onTap: () {}),
          _buildSettingItem(icon: Icons.lock_outline, title: 'Change Password', onTap: () {}),
          _buildSettingItem(icon: Icons.notifications_outlined, title: 'Notifications', onTap: () {}),
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
            onTap: () {},
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
