import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class IslamicColoringGame extends StatefulWidget {
  const IslamicColoringGame({super.key});

  @override
  State<IslamicColoringGame> createState() => _IslamicColoringGameState();
}

class _IslamicColoringGameState extends State<IslamicColoringGame> {
  final List<Map<String, dynamic>> _coloringPages = [
    {'name': 'مسجد', 'emoji': '🕌', 'parts': 5},
    {'name': 'هلال', 'emoji': '🌙', 'parts': 3},
    {'name': 'نجمة', 'emoji': '⭐', 'parts': 5},
    {'name': 'كعبة', 'emoji': '🕋', 'parts': 4},
  ];

  int _selectedPage = 0;
  final Map<int, Color> _coloredParts = {};
  Color _selectedColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  void _colorPart(int partIndex) {
    setState(() {
      _coloredParts[partIndex] = _selectedColor;
    });

    KidsSoundHelper.playClick();

    // Check if all parts colored
    if (_coloredParts.length == _coloringPages[_selectedPage]['parts']) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCompletionDialog();
      });
    }
  }

  void _showCompletionDialog() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.palette_rounded,
      title: 'أحسنت يا فنان! 🎨',
      description:
          'أنهيت تلوين ${_coloringPages[_selectedPage]['name']} بشكل رائع!',
      additionalContent: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Text(
              'لقد حصلت على 15 نجمة ✨',
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_selectedPage < _coloringPages.length - 1)
          KDialogHelper.buildButton(
            context: context,
            label: 'التالي',
            isPrimary: false,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedPage++;
                _coloredParts.clear();
              });
            },
          ),
        KDialogHelper.buildButton(
          context: context,
          label: 'رائع!',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context);
            if (_selectedPage >= _coloringPages.length - 1) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final currentPage = _coloringPages[_selectedPage];
    final partsCount = currentPage['parts'] as int;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'التلوين الإسلامي 🎨',
            style: TextStyle(
                  fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Page selector
            Container(
              margin: const EdgeInsets.all(16),
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _coloringPages.length,
                itemBuilder: (context, index) {
                  final page = _coloringPages[index];
                  final isSelected = index == _selectedPage;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPage = index;
                        _coloredParts.clear();
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(left: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page['emoji'],
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            page['name'],
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: 10.sp,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Coloring area
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentPage['name'],
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Simple coloring grid
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: partsCount > 4 ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: partsCount,
                        itemBuilder: (context, index) {
                          final color =
                              _coloredParts[index] ?? Colors.grey.shade200;

                          return GestureDetector(
                            onTap: () => _colorPart(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  currentPage['emoji'],
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Color palette
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'اختر اللون:',
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      final isSelected = _selectedColor == color;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 30)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
