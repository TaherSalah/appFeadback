import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/sounds_helper.dart';
import 'dart:math';
import '../../../core/utils/style/k_dialog_helper.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'كم عدد أركان الإسلام؟',
      'options': ['3', '5', '7'],
      'correct': 1,
    },
    {
      'question': 'ما هو أول ركن من أركان الإسلام؟',
      'options': ['الصلاة', 'الشهادتان', 'الصوم'],
      'correct': 1,
    },
    {
      'question': 'كم عدد الصلوات المفروضة في اليوم؟',
      'options': ['3', '5', '7'],
      'correct': 1,
    },
    {
      'question': 'في أي شهر يصوم المسلمون؟',
      'options': ['شعبان', 'رمضان', 'ذو الحجة'],
      'correct': 1,
    },
    {
      'question': 'ما هي القبلة التي يتجه إليها المسلمون في الصلاة؟',
      'options': ['المسجد النبوي', 'الكعبة المشرفة', 'المسجد الأقصى'],
      'correct': 1,
    },
    {
      'question': 'من هو خاتم الأنبياء والمرسلين؟',
      'options': ['موسى عليه السلام', 'عيسى عليه السلام', 'محمد ﷺ'],
      'correct': 2,
    },
    {
      'question': 'ما هي أول سورة في القرآن الكريم؟',
      'options': ['البقرة', 'الفاتحة', 'الإخلاص'],
      'correct': 1,
    },
    {
      'question': 'كم عدد أركان الإيمان؟',
      'options': ['5', '6', '7'],
      'correct': 1,
    },
  ];

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = index;
      _answered = true;

      if (index == _questions[_currentQuestion]['correct']) {
        _score += 10;
        KidsSoundHelper.playSuccess();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < _questions.length - 1) {
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
    final stars = (_score / 10 * 5).round();

    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: 'انتهى الاختبار! 🎉',
      description: 'لقد حصلت على $stars نجمة! ⭐',
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نتيجتك: $_score من ${_questions.length * 10}',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getEncouragementMessage(),
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
            _resetQuiz();
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

  String _getEncouragementMessage() {
    if (_score >= 70) return 'ممتاز! أنت عالم صغير! 🌟';
    if (_score >= 50) return 'جيد جداً! استمر في التعلم! 📚';
    return 'جيد! حاول مرة أخرى! 💪';
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _questions.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentQuestion];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'اختبر معلوماتك 🧠',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
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
                  colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.quiz, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'السؤال ${_currentQuestion + 1}/${_questions.length}',
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
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
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 12.sp : 16.sp,
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
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Text(
                        question['question'],
                        style: GoogleFonts.cairo(
                          fontSize:
                              ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(
                      (question['options'] as List).length,
                      (index) => _buildOptionButton(
                        index,
                        question['options'][index],
                        question['correct'],
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
    IconData? icon;

    if (_answered) {
      if (index == correctIndex) {
        backgroundColor = Colors.green.withOpacity(0.2);
        borderColor = Colors.green;
        icon = Icons.check_circle;
      } else if (index == _selectedAnswer) {
        backgroundColor = Colors.red.withOpacity(0.2);
        borderColor = Colors.red;
        icon = Icons.cancel;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: borderColor ?? Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: icon != null
                      ? Icon(icon, color: Colors.white, size: 24)
                      : Text(
                          String.fromCharCode(65 + index), // A, B, C
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: borderColor == null
                                ? Colors.blue
                                : Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 11.sp : 16.sp,
                    fontWeight: _answered &&
                            (index == correctIndex || index == _selectedAnswer)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
