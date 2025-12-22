import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/sound_service.dart';

/// A widget that wraps any tappable widget and plays a sound on tap
class SoundWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final SoundType soundType;

  const SoundWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.soundType = SoundType.click,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _playSound(context);
        onTap?.call();
      },
      child: child,
    );
  }

  void _playSound(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    
    switch (soundType) {
      case SoundType.click:
        soundService.playClick();
        break;
      case SoundType.success:
        soundService.playSuccess();
        break;
      case SoundType.error:
        soundService.playError();
        break;
      case SoundType.correct:
        soundService.playCorrect();
        break;
      case SoundType.wrong:
        soundService.playWrong();
        break;
      case SoundType.notification:
        soundService.playNotification();
        break;
    }
  }
}

enum SoundType {
  click,
  success,
  error,
  correct,
  wrong,
  notification,
}

/// Extension method to easily play sounds from any widget
extension SoundExtension on BuildContext {
  void playSound(SoundType type) {
    final settingsProvider = Provider.of<SettingsProvider>(this, listen: false);
    final soundService = SoundService();
    soundService.setSoundEnabled(settingsProvider.soundEffects);
    
    switch (type) {
      case SoundType.click:
        soundService.playClick();
        break;
      case SoundType.success:
        soundService.playSuccess();
        break;
      case SoundType.error:
        soundService.playError();
        break;
      case SoundType.correct:
        soundService.playCorrect();
        break;
      case SoundType.wrong:
        soundService.playWrong();
        break;
      case SoundType.notification:
        soundService.playNotification();
        break;
    }
  }
  
  void playClickSound() => playSound(SoundType.click);
  void playSuccessSound() => playSound(SoundType.success);
  void playErrorSound() => playSound(SoundType.error);
  void playCorrectSound() => playSound(SoundType.correct);
  void playWrongSound() => playSound(SoundType.wrong);
}
