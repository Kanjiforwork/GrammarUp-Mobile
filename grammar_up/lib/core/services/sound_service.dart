// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/foundation.dart';
import 'dart:html' as html if (dart.library.io) 'dart:io';
import 'dart:js' as js if (dart.library.io) 'dart:io';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Play a click/tap sound
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 800, duration: 0.05);
  }

  /// Play a success sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 880, duration: 0.1);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playBeep(frequency: 1100, duration: 0.15);
  }

  /// Play an error sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 300, duration: 0.2);
  }

  /// Play correct answer sound
  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 880, duration: 0.08);
    await Future.delayed(const Duration(milliseconds: 80));
    await _playBeep(frequency: 1100, duration: 0.12);
  }

  /// Play wrong answer sound
  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 250, duration: 0.3);
  }

  /// Play notification sound
  Future<void> playNotification() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 600, duration: 0.1);
    await Future.delayed(const Duration(milliseconds: 50));
    await _playBeep(frequency: 800, duration: 0.1);
  }

  /// Play a message sent sound
  Future<void> playMessageSent() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 700, duration: 0.06);
  }

  /// Play a message received sound
  Future<void> playMessageReceived() async {
    if (!_soundEnabled) return;
    await _playBeep(frequency: 500, duration: 0.08);
    await Future.delayed(const Duration(milliseconds: 60));
    await _playBeep(frequency: 650, duration: 0.08);
  }

  /// Play a beep using Web Audio API (web only)
  Future<void> _playBeep({required double frequency, required double duration}) async {
    try {
      if (kIsWeb) {
        _playWebAudioBeep(frequency, duration);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _playWebAudioBeep(double frequency, double duration) {
    if (!kIsWeb) return;
    
    try {
      js.context.callMethod('eval', ['''
        (function() {
          try {
            var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
            var oscillator = audioCtx.createOscillator();
            var gainNode = audioCtx.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioCtx.destination);
            
            oscillator.frequency.value = $frequency;
            oscillator.type = 'sine';
            
            gainNode.gain.setValueAtTime(0.3, audioCtx.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + $duration);
            
            oscillator.start(audioCtx.currentTime);
            oscillator.stop(audioCtx.currentTime + $duration);
          } catch(e) {
            console.log('Audio error:', e);
          }
        })();
      ''']);
    } catch (e) {
      debugPrint('Web Audio error: $e');
    }
  }

  void dispose() {
    // Nothing to dispose for web-based audio
  }
}
