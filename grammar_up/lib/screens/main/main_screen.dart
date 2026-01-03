import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/sound_service.dart';
import 'tabs/lesson_tab.dart';
import 'tabs/exercise_tab.dart';
import 'tabs/ai_chat_tab.dart';
import 'tabs/vocabulary_tab.dart';
import 'tabs/account_tab.dart';
import 'tabs/setting_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    LessonTab(),
    ExerciseTab(),
    AIChatTab(),
    VocabularyTab(),
    AccountTab(),
    SettingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;
    final inactiveColor = isDark ? AppColors.darkTextTertiary : AppColors.gray500;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: l10n?.learn ?? 'Learn',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.fitness_center_outlined,
                  activeIcon: Icons.fitness_center_rounded,
                  label: l10n?.practice ?? 'Practice',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.smart_toy_outlined,
                  activeIcon: Icons.smart_toy_rounded,
                  label: l10n?.aiTutor ?? 'AI Tutor',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.library_books_outlined,
                  activeIcon: Icons.library_books_rounded,
                  label: l10n?.words ?? 'Words',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: l10n?.profile ?? 'Profile',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
                _buildNavItem(
                  index: 5,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: l10n?.settings ?? 'Settings',
                  primaryColor: primaryColor,
                  inactiveColor: inactiveColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color primaryColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          final soundService = SoundService();
          soundService.setSoundEnabled(settingsProvider.soundEffects);
          soundService.playClick();
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? primaryColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
