import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;
  final AudioPlayer _player = AudioPlayer();

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play a click/tap sound
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/click.mp3');
  }

  /// Play a success sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/success.mp3');
  }

  /// Play an error sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/error.mp3');
  }

  /// Play correct answer sound
  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/correct.mp3');
  }

  /// Play wrong answer sound
  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/wrong.mp3');
  }

  /// Play notification sound
  Future<void> playNotification() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/notification.mp3');
  }

  /// Play a message sent sound
  Future<void> playMessageSent() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/message_sent.mp3');
  }

  /// Play a message received sound
  Future<void> playMessageReceived() async {
    if (!_soundEnabled) return;
    await _playSound('sounds/message_received.mp3');
  }

  /// Play a sound from assets
  Future<void> _playSound(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Sound file might not exist yet - silently fail
      debugPrint('Error playing sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
