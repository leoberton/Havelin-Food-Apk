import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticManager {
  static final HapticManager instance = HapticManager._internal();

  static const MethodChannel _platformChannel = MethodChannel('com.havelin.food/vibrate');

  HapticManager._internal() {
    loadHapticsSetting();
  }

  bool _isHapticsEnabled = true;

  bool get isHapticsEnabled => _isHapticsEnabled;

  set isHapticsEnabled(bool enabled) {
    _isHapticsEnabled = enabled;
    saveHapticsSetting(enabled);
  }

  Future<void> loadHapticsSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('app_haptics_enabled');
      if (saved != null) {
        _isHapticsEnabled = saved;
      }
    } catch (e) {
      debugPrint("Haptics load note: $e");
    }
  }

  Future<void> saveHapticsSetting(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_haptics_enabled', enabled);
    } catch (e) {
      debugPrint("Haptics save note: $e");
    }
  }

  void _triggerNativePulse(int durationMs, int amplitude) async {
    if (!_isHapticsEnabled) return;
    try {
      // 1. Standard System Haptic (iOS native Taptic Engine handles this out-of-the-box!)
      HapticFeedback.selectionClick();

      // 2. Direct Native Android Hardware Vibrator Service Call (Only on Android)
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _platformChannel.invokeMethod('vibrate', {
          'duration': durationMs,
          'amplitude': amplitude,
        });
      }
    } on MissingPluginException catch (_) {
      // Safely ignore missing channel on platforms like iOS Simulator
    } catch (e) {
      debugPrint("Haptic pulse note: $e");
    }
  }

  void lightImpact() {
    _triggerNativePulse(35, 150);
  }

  void mediumImpact() {
    _triggerNativePulse(65, 210);
  }

  void heavyImpact() {
    _triggerNativePulse(110, 255);
  }

  void selectionClick() {
    _triggerNativePulse(25, 120);
  }

  void vibrate() {
    _triggerNativePulse(80, 230);
  }
}
