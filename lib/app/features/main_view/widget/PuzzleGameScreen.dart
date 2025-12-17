import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/sounds_helper.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  final List<String> _correctOrder = [
    '1. النية',
    '2. قول بسم الله',
    '3. غسل الكفين 3 مرات',
    '4. المضمضة والاستنشاق',
    '5. غسل الوجه 3 مرات',
    '6. غسل اليدين إلى المرفقين',
    '7. مسح الرأس',
    '8. مسح الأذنين',
    '9. غسل القدمين إلى الكعبين',
  ];

  List<String> _currentOrder = [];
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _shuffleSteps();
  }

  void _shuffleSteps() {
    setState(() {
      _currentOrder = List.from(_correctOrder)..shuffle();
      _isComplete = false;
    });
  }

  void _checkOrder() {
    bool allCorrect = true;
    for (int i = 0; i < _currentOrder.length; i++) {
      if (_currentOrder[i] != _correctOrder[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() => _isComplete = allCorrect);

    if (allCorrect) {
      KidsSoundHelper.playTada();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎊'),
            const SizedBox(width: 8),
            Text(
              'ممتاز!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'أحسنت! رتبت خطوات الوضوء بشكل صحيح.\nحصلت على 30 نجمة! ⭐',
          style: GoogleFonts.cairo(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shuffleSteps();
            },
            child: Text(
              'العب مرة أخرى',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'رائع!',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'لعبة ترتيب الوضوء 💧',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _shuffleSteps,
              tooltip: 'خلط من جديد',
            ),
          ],
        ),
        body: Column(
          children: [
            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'رتب خطوات الوضوء بالترتيب الصحيح!',
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _currentOrder.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _currentOrder.removeAt(oldIndex);
                    _currentOrder.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final step = _currentOrder[index];
                  final isCorrect = _isComplete || step == _correctOrder[index];

                  return Container(
                    key: ValueKey(step),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            isCorrect ? Colors.green : Colors.blue.shade100,
                        child: Icon(
                          isCorrect ? Icons.check : Icons.drag_indicator,
                          color: isCorrect ? Colors.white : Colors.blue,
                        ),
                      ),
                      title: Text(
                        step,
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                          fontWeight:
                              isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: const Icon(Icons.menu, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),

            // Check button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isComplete ? null : _checkOrder,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isComplete ? 'صحيح! 🎉' : 'تحقق من الترتيب',
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 12.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isComplete ? Colors.green : const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _isComplete ? 0 : 4,
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
