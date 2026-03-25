import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kids_data/sounds_helper.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

class PuzzleLevel {
  final String title;
  final String instruction;
  final List<String> correctOrder;
  final List<Color> colors;

  PuzzleLevel({
    required this.title,
    required this.instruction,
    required this.correctOrder,
    required this.colors,
  });
}

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  final List<PuzzleLevel> _levels = [
    PuzzleLevel(
      title: 'رتب خطوات الوضوء',
      instruction: 'رتب خطوات الوضوء بالترتيب الصحيح!',
      correctOrder: ['1. النية', '2. قول بسم الله', '3. غسل الكفين 3 مرات', '4. المضمضة والاستنشاق', '5. غسل الوجه 3 مرات', '6. غسل اليدين إلى المرفقين', '7. مسح الرأس', '8. مسح الأذنين', '9. غسل القدمين إلى الكعبين'],
      colors: [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
    ),
    PuzzleLevel(
      title: 'رتب خطوات الصلاة',
      instruction: 'رتب أفعال الصلاة من البداية!',
      correctOrder: ['1. النية', '2. تكبيرة الإحرام', '3. القيام وقراءة الفاتحة', '4. الركوع', '5. الرفع من الركوع', '6. السجود', '7. الجلوس بين السجدتين', '8. السجود الثاني', '9. التشهد والتسليم'],
      colors: [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
    ),
    PuzzleLevel(
      title: 'أركان الإسلام',
      instruction: 'رتب أركان الإسلام الخمسة!',
      correctOrder: ['1. الشهادتان', '2. إقام الصلاة', '3. إيتاء الزكاة', '4. صوم رمضان', '5. حج البيت لمن استطاع'],
      colors: [const Color(0xFFFFA000), const Color(0xFFFF8F00)],
    ),
    PuzzleLevel(
      title: 'أركان الإيمان',
      instruction: 'رتب أركان الإيمان الستة!',
      correctOrder: ['1. الإيمان بالله', '2. الإيمان بالملائكة', '3. الإيمان بالكتب', '4. الإيمان بالرسل', '5. الإيمان باليوم الآخر', '6. الإيمان بالقدر خيره وشره'],
      colors: [const Color(0xFF7B1FA2), const Color(0xFF6A1B9A)],
    ),
    PuzzleLevel(
      title: 'رتب جمل الأذان',
      instruction: 'رتب جمل الأذان بشكل صحيح!',
      correctOrder: ['1. الله أكبر (4 مرات)', '2. أشهد أن لا إله إلا الله', '3. أشهد أن محمداً رسول الله', '4. حي على الصلاة', '5. حي على الفلاح', '6. الله أكبر', '7. لا إله إلا الله'],
      colors: [const Color(0xFFE64A19), const Color(0xFFD84315)],
    ),
  ];

  int _currentLevelIndex = 0;
  List<String> _currentOrder = [];
  bool _isComplete = false;
  int _stars = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLevelIndex = prefs.getInt('puzzle_level') ?? 0;
      _stars = prefs.getInt('puzzle_stars') ?? 0;
      _shuffleSteps();
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('puzzle_level', _currentLevelIndex);
    await prefs.setInt('puzzle_stars', _stars);
  }

  void _shuffleSteps() {
    setState(() {
      _currentOrder = List.from(_levels[_currentLevelIndex].correctOrder)..shuffle();
      _isComplete = false;
    });
  }

  void _checkOrder() {
    final level = _levels[_currentLevelIndex];
    bool allCorrect = true;
    for (int i = 0; i < _currentOrder.length; i++) {
      if (_currentOrder[i] != level.correctOrder[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() => _isComplete = allCorrect);

    if (allCorrect) {
      KidsSoundHelper.playTada();
      _stars += 10;
      _saveProgress();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    final isLastLevel = _currentLevelIndex == _levels.length - 1;
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.celebration_rounded,
      title: isLastLevel ? 'تهانينا يا بطل! 🏆' : 'أحسنت يا بطل! 🎊',
      description: isLastLevel 
          ? 'لقد أكملت جميع المستويات بنجاح! أنت الآن تعرف الكثير عن دينك.' 
          : 'أحسنت! رتبت الخطوات بشكل صحيح. حصلت على 10 نجوم إضافية! ⭐',
      actions: [
        if (!isLastLevel)
          KDialogHelper.buildButton(
            context: context,
            label: 'المستوى التالي',
            color: const Color(0xFF4CAF50),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevelIndex++;
                _shuffleSteps();
              });
            },
          ),
        KDialogHelper.buildButton(
          context: context,
          label: isLastLevel ? 'إغلاق' : 'العب مرة أخرى',
          isPrimary: isLastLevel,
          onPressed: () {
            Navigator.pop(context);
            if (isLastLevel) Navigator.pop(context);
            else _shuffleSteps();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final level = _levels[_currentLevelIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_stars',
                    style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _shuffleSteps,
              tooltip: 'إعادة المحاولة',
            ),
          ],
          centerTitle: true,
          title: Text(
            level.title,
            style: TextStyle(
                  fontFamily: "cairo",
              color: level.colors[0],
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: Column(
          children: [
            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: level.colors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: level.colors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      level.instruction,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentLevelIndex + 1}/${_levels.length}',
                    style: TextStyle(
                  fontFamily: "cairo",color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Reorderable list
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  final isCorrect = _isComplete || step == level.correctOrder[index];

                  return Container(
                    key: ValueKey(step),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withOpacity(0.1)
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.grey.withOpacity(0.3),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: isCorrect ? Colors.green : level.colors[0].withOpacity(0.2),
                        child: Icon(
                          isCorrect ? Icons.check : Icons.drag_handle,
                          color: isCorrect ? Colors.white : level.colors[0],
                        ),
                      ),
                      title: Text(
                        step,
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 14.sp,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: Icon(Icons.reorder, color: Colors.grey.withOpacity(0.5)),
                    ),
                  );
                },
              ),
            ),

            // Check button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isComplete ? null : _checkOrder,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                  label: Text(
                    _isComplete ? 'إجابة رائعة! 🎉' : 'تحقق من الترتيب',
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isComplete ? Colors.green : level.colors[0],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: level.colors[0].withOpacity(0.4),
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
