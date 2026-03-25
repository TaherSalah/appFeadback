import 'package:just_audio/just_audio.dart';

class KidsSoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  // Sound files (we'll create simple ones or use system sounds)
  static Future<void> playSuccess() async {
    try {
      // Using a simple notification sound for success
      // In production, you'd add custom MP3s to assets
      await _player.setAsset('assets/sounds/success.mp3').catchError((_) {
        // Fallback: no sound if asset missing
        return Future.value(null);
      });
      await _player.play().catchError((_) => Future.value());
    } catch (e) {
      // Silently fail if sound not available
    }
  }

  static Future<void> playApplause() async {
    try {
      await _player
          .setAsset('assets/sounds/applause.mp3')
          .catchError((_) => Future.value(null));
      await _player.play().catchError((_) => Future.value());
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> playClick() async {
    try {
      await _player
          .setAsset('assets/sounds/click.mp3')
          .catchError((_) => Future.value(null));
      await _player.play().catchError((_) => Future.value());
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> playTada() async {
    try {
      await _player
          .setAsset('assets/sounds/tada.mp3')
          .catchError((_) => Future.value(null));
      await _player.play().catchError((_) => Future.value());
    } catch (e) {
      // Silently fail
    }
  }

  static void dispose() {
    _player.dispose();
  }
}
