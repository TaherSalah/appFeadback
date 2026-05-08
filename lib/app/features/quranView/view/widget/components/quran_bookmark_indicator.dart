import 'package:flutter/material.dart';

/// علامة الحجز (الشريط الأحمر) التي تظهر أعلى الصفحة المحفوظة
class QuranBookmarkIndicator extends StatelessWidget {
  final VoidCallback onTap;

  const QuranBookmarkIndicator({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -5,
      left: 155,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: -50, end: 0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x94A50000),
                  Color(0x578B0000),
                  Color(0x64600000),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  width: 20,
                  height: 2,
                  color: Colors.white.withOpacity(0.3),
                ),
                const Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
