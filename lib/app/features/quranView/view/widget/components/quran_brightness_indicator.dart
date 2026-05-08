import 'package:flutter/material.dart';

/// مؤشر مستوى السطوع يظهر وسط الشاشة عند السحب من اليسار
class QuranBrightnessIndicator extends StatelessWidget {
  final double value;

  const QuranBrightnessIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value > 0.5
                  ? Icons.brightness_high
                  : Icons.brightness_medium,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: "cairo",
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
