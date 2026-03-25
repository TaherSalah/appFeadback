import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

class AppThemeColors {
  // ================== Card Aesthetics (Premium) ==================

  static Color cardBackgroundColor(BuildContext context) {
    return context.isDark
        ? const Color(0xFF252538) // Premium Dark Card
        : Colors.white;            // Pure White Light Card
  }

  static Color cardBorderColor(BuildContext context) {
    return const Color(0xFFD4AF37).withOpacity(0.4); // Gold Border
  }

  // ================== Text Colors ==================

  static Color cardHeaderColor(BuildContext context) {
    return context.isDark
        ? Colors.white
        : const Color(0xFF1E293B);
  }

  static Color cardSubtitleColor(BuildContext context) {
    return context.isDark
        ? Colors.white70
        : const Color(0xFF64748B);
  }

  // ================== Utility Colors ==================

  static Color patternOpacity(BuildContext context) {
    return context.isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.08);
  }
}
