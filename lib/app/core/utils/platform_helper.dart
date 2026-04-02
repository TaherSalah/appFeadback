import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformHelper {
  /// Checks if the app is running on the Web.
  static bool get isWeb => kIsWeb;

  /// Checks if the app is running on Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Checks if the app is running on iOS.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Checks if the app is running on a mobile device (Android or iOS).
  static bool get isMobile => isAndroid || isIOS;

  /// Checks if the app is running on a desktop platform.
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Checks if the app is running on Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Checks if the app is running on macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Checks if the app is running on Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;
}
