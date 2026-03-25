import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

enum KDialogType { success, warning, info, error }

class KDialogHelper {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required KDialogType type,
    Widget? additionalContent,
    List<Widget>? actions,
    bool barrierDismissible = false,
  }) {
    final bool isDark = context.isDark;

    // Determine colors based on type
    List<Color> bodyGradient;
    List<Color> iconGradient;

    switch (type) {
      case KDialogType.success:
        bodyGradient = isDark
            ? [const Color(0xFF064E3B), const Color(0xFF065F46)]
            : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)];
        iconGradient = [Colors.green, Colors.teal];
        break;
      case KDialogType.warning:
      case KDialogType.error:
        bodyGradient = isDark
            ? [const Color(0xFF450A0A), const Color(0xFF7F1D1D)]
            : [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)];
        iconGradient = [Colors.red, Colors.deepOrange];
        break;
      case KDialogType.info:
        bodyGradient = isDark
            ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
            : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)];
        iconGradient = [Colors.blue, Colors.indigo];
        break;
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Body
              Container(
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: bodyGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      description,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (additionalContent != null) ...[
                      const SizedBox(height: 20),
                      additionalContent,
                    ],

                    const SizedBox(height: 24),

                    // Actions
                    if (actions != null)
                      Row(
                        children: actions
                            .map((action) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: actions.length > 1 ? 6 : 0),
                                    child: action,
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              // Floating Top Icon
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: iconGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconGradient[0].withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for generic action buttons to maintain style
  static Widget buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = true,
    Color? color,
    IconData? icon,
  }) {
    final bool isDark = context.isDark;

    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
                  fontFamily: "cairo",
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      );
    }
  }
}
