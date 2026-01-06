import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final NotificationPlatformService _notificationService =
      NotificationPlatformService();

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
      if (value) {
        final hasPermission = await _notificationService.requestPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Please grant notification permission in settings'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
          setState(() {
            _isLoadingNotifications = false;
          });
          return;
        }
      }

      final success =
          await _notificationService.setNotificationEnabled(value);

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
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (value) {
          await _notificationService.showLocalNotification(
            title: 'GrammarUp',
            body: 'Notifications are now enabled!',
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update notification settings'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _openChangePassword(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      // Get access token from current session
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please login to change password'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      // Call native method to open Change Password Activity
      const platform = MethodChannel('com.example.grammar_up/native');
      await platform.invokeMethod('openChangePassword', {
        'accessToken': session.accessToken,
        'isDarkMode': themeProvider.themeMode == ThemeMode.dark,
        'languageCode': settingsProvider.language.code,
      });
    } catch (e) {
      debugPrint('Error opening change password: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open change password: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    soundService.playClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.selectLanguage ?? 'Select Language',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 20),
            ...AppLanguage.values.map((language) {
              final isSelected = settingsProvider.language == language;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppColors.darkBorder : AppColors.gray200),
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    settingsProvider.setLanguage(language);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withAlpha(51)
                          : (isDark
                              ? AppColors.darkSurfaceHighlight
                              : AppColors.gray100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: isSelected
                          ? primaryColor
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.gray600),
                    ),
                  ),
                  title: Text(
                    language.displayName,
                    style: GoogleFonts.nunito(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? primaryColor
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.gray900),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: primaryColor)
                      : null,
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, _) {
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
          appBar: AppBar(
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.white,
            elevation: 0,
            centerTitle: false,
            title: Text(
              l10n?.settings ?? 'Settings',
              style: GoogleFonts.nunito(
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Account section
              _buildSectionHeader(
                  l10n?.accountSection ?? 'Account', isDark),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: l10n?.editProfile ?? 'Edit Profile',
                    onTap: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      final result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const EditProfileScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                      if (result == true && mounted) {
                        await authProvider.reloadUserProfile();
                      }
                    },
                  ),
                  // Only show change password for email/password users
                  if (Provider.of<AuthProvider>(context, listen: false)
                          .authService
                          .isEmailPasswordUser) ...[
                    _buildDivider(isDark),
                    _buildSettingItem(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: l10n?.changePassword ?? 'Change Password',
                      onTap: () => _openChangePassword(context),
                    ),
                  ],
                  _buildDivider(isDark),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: l10n?.notifications ?? 'Notifications',
                    trailing: _isLoadingNotifications
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          )
                        : Switch.adaptive(
                            value: _notificationsEnabled,
                            onChanged: _toggleNotifications,
                            activeColor: primaryColor,
                          ),
                    onTap: () =>
                        _toggleNotifications(!_notificationsEnabled),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Preferences section
              _buildSectionHeader(
                  l10n?.preferencesSection ?? 'Preferences', isDark),
              const SizedBox(height: 8),
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.language_rounded,
                    title: l10n?.language ?? 'Language',
                    subtitle: settingsProvider.language.displayName,
                    onTap: () => _showLanguageSelector(context),
                  ),
                  _buildDivider(isDark),
                  _buildSettingItem(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: l10n?.darkMode ?? 'Dark Mode',
                    trailing: Switch.adaptive(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeProvider.setThemeMode(value);
                      },
                      activeColor: primaryColor,
                    ),
                    onTap: () {
                      final isDarkMode =
                          themeProvider.themeMode == ThemeMode.dark;
                      themeProvider.setThemeMode(!isDarkMode);
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSettingItem(
                    context,
                    icon: Icons.volume_up_outlined,
                    title: l10n?.soundEffects ?? 'Sound Effects',
                    trailing: Switch.adaptive(
                      value: settingsProvider.soundEffects,
                      onChanged: (value) {
                        settingsProvider.setSoundEffects(value);
                        if (value) {
                          final soundService = SoundService();
                          soundService.setSoundEnabled(true);
                          soundService.playSuccess();
                        }
                      },
                      activeColor: primaryColor,
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
                ],
              ),
              const SizedBox(height: 24),

              // Logout button
              _buildSettingsCard(
                context,
                children: [
                  _buildSettingItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: l10n?.logOut ?? 'Log Out',
                    iconColor: AppColors.error,
                    titleColor: AppColors.error,
                    showChevron: false,
                    onTap: () => _showLogoutDialog(context, l10n),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Version
              Center(
                child: Text(
                  '${l10n?.version ?? 'Version'} 1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color:
                        isDark ? AppColors.darkTextTertiary : AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextTertiary : AppColors.gray500,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: isDark ? AppColors.darkBorder : AppColors.gray100,
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final effectiveIconColor = iconColor ?? primaryColor;
    final effectiveTitleColor =
        titleColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.gray900);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: effectiveIconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: effectiveTitleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, AppLocalizations? l10n) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n?.logOut ?? 'Log Out',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        content: Text(
          l10n?.logOutConfirm ?? 'Are you sure you want to log out?',
          style: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n?.logOut ?? 'Log Out',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
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
  }
}
