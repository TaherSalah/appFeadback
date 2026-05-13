import 'package:wakelock_plus/wakelock_plus.dart';
import 'settings_service.dart';

class WakelockService {
  static final SettingsService _settings = SettingsService();

  /// Enables the wakelock if the global setting is active.
  static Future<void> enableIfActive() async {
    if (_settings.isKeepScreenAwakeEnabled) {
      await WakelockPlus.enable();
    }
  }

  /// Disables the wakelock.
  static Future<void> disable() async {
    await WakelockPlus.disable();
  }

  /// Toggles the wakelock based on the provided [enable] flag and global setting.
  static Future<void> toggle({required bool enable}) async {
    if (enable && _settings.isKeepScreenAwakeEnabled) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }
}
