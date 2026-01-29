import 'package:flutter/material.dart';

class CustomGradientDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;
  final VoidCallback onPrimaryPressed;
  final String primaryButtonText;
  final Color primaryButtonColor;
  final VoidCallback? onSecondaryPressed;
  final String? secondaryButtonText;
  final String? infoText;
  final bool isDark;

  const CustomGradientDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.gradientColors,
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
    this.messageColor = Colors.white70,
    required this.onPrimaryPressed,
    required this.primaryButtonText,
    this.primaryButtonColor = const Color(0xFF10B981),
    this.onSecondaryPressed,
    this.secondaryButtonText,
    this.infoText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Safe area for the icon
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradientColors,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
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
                        fontSize: 20,
                        fontFamily: "cairo",
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Message
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontFamily: "cairo",

                        color: messageColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (infoText != null) ...[
                      const SizedBox(height: 16),
                      // Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 18, color: messageColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                infoText!,
                                style: TextStyle(
                                  fontFamily: "cairo",

                                  fontSize: 12.5,
                                  color: messageColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        if (onSecondaryPressed != null &&
                            secondaryButtonText != null) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onSecondaryPressed,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                              ),
                              child: Text(
                                secondaryButtonText!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "cairo",

                                  color: titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onPrimaryPressed,
                            icon: const SizedBox
                                .shrink(), // No icon for simplicity unless needed
                            label: Text(
                              primaryButtonText,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold,
                                    fontFamily: "cairo",

                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryButtonColor, // Main action color
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Circular Icon
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        gradientColors.first.withOpacity(0.8),
                        gradientColors.last
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 30, // Slightly smaller to fit border
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
