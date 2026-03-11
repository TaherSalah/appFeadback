import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  // Theme helpers
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Screen size helpers
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isDarkMode => theme.brightness == Brightness.dark;
  bool get isDark => isDarkMode;

  // Responsive helpers
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;

  // Localization helpers (optional, depending on your setup)
  // String translate(String key) => AppLocalizations.of(this)!.translate(key);

  // Navigation helpers
  void pop<T extends Object?>([T? result]) => Navigator.pop(this, result);

  Future<T?> push<T extends Object?>(Widget widget) {
    return Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      Widget widget) {
    return Navigator.pushReplacement(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<T?> pushNamed<T extends Object?>(String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }
}
