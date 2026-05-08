import 'package:flutter/material.dart';

/// شريط تقدم القراءة بين صفحتين (initial → target)
class QuranProgressBar extends StatelessWidget {
  final int currentPage;
  final int initialPage;
  final int targetPage;

  const QuranProgressBar({
    super.key,
    required this.currentPage,
    required this.initialPage,
    required this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    final int totalPages = (targetPage - initialPage).abs() + 1;
    final int currentRelative = (currentPage - initialPage).abs() + 1;
    final double progress =
        totalPages > 0 ? (currentRelative / totalPages).clamp(0.0, 1.0) : 1.0;

    return Container(
      height: 4,
      width: double.infinity,
      color: Colors.white10,
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
