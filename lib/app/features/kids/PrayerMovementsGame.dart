import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class PrayerMovementsGame extends StatefulWidget {
  const PrayerMovementsGame({super.key});

  @override
  State<PrayerMovementsGame> createState() => _PrayerMovementsGameState();
}

class _PrayerMovementsGameState extends State<PrayerMovementsGame> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;

  final List<Map<String, dynamic>> _movements = [
    {
      'name': 'القيام',
      'description': 'الوقوف مستقيماً',
      'emoji': '🧍',
      'options': ['🧘 الجلوس', '🧎 الركوع', '🧍 القيام'],
      'correct': 2,
    },
    {
      'name': 'الركوع',
      'description': 'الانحناء مع وضع اليدين على الركبتين',
      'emoji': '🙇',
      'options': ['🙇 الركوع', '🧘 السجود', '🧍 القيام'],
      'correct': 0,
    },
    {
      'name': 'السجود',
      'description': 'وضع الجبهة والأنف على الأرض',
      'emoji': '🧎',
      'options': ['🧍 القيام', '🧎 السجود', '🙇 الركوع'],
      'correct': 1,
    },
    {
      'name': 'الجلوس بين السجدتين',
      'description': 'الجلوس على القدمين',
      'emoji': '🧘',
      'options': ['🧘 الجلوس', '🧍 القيام', '🙇 الركوع'],
      'correct': 0,
    },
    {
      'name': 'التشهد',
      'description': 'الجلوس مع رفع الإصبع',
      'emoji': '☝️',
      'options': ['🙇 الركوع', '☝️ التشهد', '🧍 القيام'],
      'correct': 1,
    },
    {
      'name': 'التسليم',
      'description': 'الالتفات يميناً ويساراً',
      'emoji': '👋',
      'options': ['👋 التسليم', '🙇 الركوع', '🧘 الجلوس'],
      'correct': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _movements.shuffle(Random());
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = index;
      _answered = true;

      if (index == _movements[_currentQuestion]['correct']) {
        _score += 10;
        KidsSoundHelper.playSuccess();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < _movements.length - 1) {
        setState(() {
          _currentQuestion++;
          _answered = false;
          _selectedAnswer = null;
        });
      } else {
        _showFinalScore();
      }
    });
  }

  void _showFinalScore() {
    final stars = (_score ~/ 10) * 5;

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.mosque_rounded,
      title: 'أحسنت يا بطل! 🎉',
      description: 'لقد تعلمت حركات الصلاة بشكل رائع!',
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نتيجتك: $_score/${_movements.length * 10}',
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded,
                    color: Color(0xFFF59E0B), size: 24),
                const SizedBox(width: 8),
                Text(
                  'حصلت على $stars نجمة ✨',
                  style: TextStyle(
                  fontFamily: "cairo",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'العب مرة أخرى',
          isPrimary: false,
          onPressed: () {
            Navigator.pop(context);
            _resetGame();
          },
        ),
        KDialogHelper.buildButton(
          context: context,
          label: 'تمام',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _movements.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final movement = _movements[_currentQuestion];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تعليم حركات الصلاة 🙏',
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
            // Progress
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mosque, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'الحركة ${_currentQuestion + 1}/${_movements.length}',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize:
                              context.isTab ? 10.sp : 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_score',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize:
                              context.isTab ? 12.sp : 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Movement display
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            movement['emoji'],
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            movement['name'],
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: context.isTab
                                  ? 14.sp
                                  : 20.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            movement['description'],
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: context.isTab
                                  ? 10.sp
                                  : 14.sp,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'اختر الحركة الصحيحة:',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize:
                            context.isTab ? 11.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options
                    ...List.generate(
                      (movement['options'] as List).length,
                      (index) => _buildOptionButton(
                        index,
                        movement['options'][index],
                        movement['correct'],
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      int index, String option, int correctIndex, bool isDark) {
    Color? backgroundColor;
    Color? borderColor;

    if (_answered) {
      if (index == correctIndex) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
      } else if (index == _selectedAnswer) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
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
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: context.isTab ? 14.sp : 20.sp,
                fontWeight: _answered && index == correctIndex
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
