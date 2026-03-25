import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class QuizGameScreen extends StatefulWidget {
  const QuizGameScreen({super.key});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen> {
  int _currentQuestion = 0;
  int _score = 0;
  int _highScore = 0;
  bool _answered = false;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_high_score', _highScore);
    }
  }

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'ما هو الركن الأول من أركان الإسلام؟',
      'options': ['الصلاة', 'الشهادتان', 'الزكاة', 'الصوم'],
      'answer': 1,
    },
    {
      'question': 'كم عدد الصلوات في اليوم والليلة؟',
      'options': ['3 صلوات', '4 صلوات', '5 صلوات', '6 صلوات'],
      'answer': 2,
    },
    {
      'question': 'ما هو الكتاب الذي أنزله الله على سيدنا محمد؟',
      'options': ['التوراة', 'الإنجيل', 'الزبور', 'القرآن الكريم'],
      'answer': 3,
    },
    {
      'question': 'أين ولد النبي محمد صلى الله عليه وسلم؟',
      'options': ['المدينة المنورة', 'مكة المكرمة', 'الطائف', 'القدس'],
      'answer': 1,
    },
    {
      'question': 'ما هو اسم أم النبي محمد صلى الله عليه وسلم؟',
      'options': ['خديجة', 'عائشة', 'آمنة', 'فاطمة'],
      'answer': 2,
    },
  ];

  void _checkAnswer(int index) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (index == _questions[_currentQuestion]['answer']) {
        _score += 10;
        KidsSoundHelper.playSuccess();
      } else {
        KidsSoundHelper.playClick();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestion < _questions.length - 1) {
          setState(() {
            _currentQuestion++;
            _answered = false;
            _selectedAnswer = null;
          });
        } else {
          _saveHighScore();
          _showResultDialog();
        }
      }
    });
  }

  void _showResultDialog() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: 'انتهت المسابقة! 🎉',
      description: 'لقد أجبت على كل الأسئلة بنجاح يا بطل!',
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نتيجتك: $_score/${_questions.length * 10}',
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'حصلت على $_score نجمة ✨',
                      style: const TextStyle(
                  fontFamily: "cairo",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'أعلى نتيجة: $_highScore ✨',
                  style: TextStyle(
                  fontFamily: "cairo",
                    fontSize: 14,
                    color: Colors.grey[600],
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
          label: 'رائع!',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final question = _questions[_currentQuestion];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "مسابقة المعلومات العامة",
              style: TextStyle(
                fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Progress and Score
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KColors.primaryColor, KColors.primaryColor],
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
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: context.isTab? 10.sp : 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: TextStyle(
                              fontFamily: "cairo",
                              fontSize: context.isTab? 12.sp : 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'الأفضل: $_highScore',
                        style: TextStyle(
                          fontFamily: "cairo",
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      question['question'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize:
                            context.isTab? 14.sp : 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(
                      question['options'].length,
                      (index) => _buildOption(index, question['options'][index]),
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

  Widget _buildOption(int index, String option) {
    bool isCorrect = index == _questions[_currentQuestion]['answer'];
    bool isSelected = index == _selectedAnswer;
    final isDark = context.isDark;

    Color? backgroundColor;
    Color? borderColor;

    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _checkAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: borderColor ?? Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _answered && isCorrect
                      ? const Icon(Icons.check, color: Colors.green, size: 20)
                      : _answered && isSelected
                          ? const Icon(Icons.close, color: Colors.red, size: 20)
                          : Text(
                              String.fromCharCode(65 + index), // A, B, C
                              style: TextStyle(
                  fontFamily: "cairo",
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
                  style: TextStyle(
                  fontFamily: "cairo",
                    fontSize: context.isTab? 11.sp : 16.sp,
                    fontWeight: _answered &&
                            (index == _questions[_currentQuestion]['answer'] || index == _selectedAnswer)
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
