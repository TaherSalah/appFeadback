import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  // قاعدة بيانات الأسئلة
  final List<Map<String, dynamic>> questions = [
    {
      "question": "ما هي السورة التي تعدل ثلث القرآن؟",
      "options": ["سورة الفاتحة", "سورة الإخلاص", "سورة الكوثر", "سورة يس"],
      "answer": "سورة الإخلاص"
    },
    {
      "question": "من هو النبي الذي ألقي في النار ولم يحترق؟",
      "options": [
        "موسى عليه السلام",
        "إبراهيم عليه السلام",
        "يوسف عليه السلام",
        "يونس عليه السلام"
      ],
      "answer": "إبراهيم عليه السلام"
    },
    {
      "question": "كم عدد أركان الإسلام؟",
      "options": ["4 أركان", "5 أركان", "6 أركان", "7 أركان"],
      "answer": "5 أركان"
    },
    {
      "question": "ما هي الصلاة التي ليس فيها ركوع ولا سجود؟",
      "options": [
        "صلاة الاستسقاء",
        "صلاة الجنازة",
        "صلاة العيد",
        "سجود التلاوة"
      ],
      "answer": "صلاة الجنازة"
    },
    {
      "question": "من هو خاتم الأنبياء والمرسلين؟",
      "options": [
        "عيسى عليه السلام",
        "موسى عليه السلام",
        "محمد ﷺ",
        "إبراهيم عليه السلام"
      ],
      "answer": "محمد ﷺ"
    },
    {
      "question": "في أي يوم خلق الله سيدنا آدم؟",
      "options": ["يوم الإثنين", "يوم الخميس", "يوم الجمعة", "يوم السبت"],
      "answer": "يوم الجمعة"
    },
  ];

  late Map<String, dynamic> _todaysQuestion;
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    // اختيار سؤال عشوائي يومي
    final seed =
        DateTime.now().day + DateTime.now().month + DateTime.now().year + 5;
    final random = Random(seed);
    _todaysQuestion = questions[random.nextInt(questions.length)];
  }

  void _checkAnswer(String option) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final correctAnswer = _todaysQuestion['answer'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "سؤال التحدي اليومي 🧠",
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.indigo.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "اختبر معلوماتك",
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _todaysQuestion['question'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ...(_todaysQuestion['options'] as List<String>).map((option) {
                  final isSelected = _selectedOption == option;
                  final isCorrect = option == correctAnswer;

                  Color borderColor =
                      isDark ? Colors.white12 : Colors.grey.shade300;
                  Color bgColor = Colors.transparent;
                  IconData? icon;

                  if (_isAnswered) {
                    if (isCorrect) {
                      borderColor = Colors.green;
                      bgColor = Colors.green.withOpacity(0.1);
                      icon = Icons.check_circle;
                    } else if (isSelected && !isCorrect) {
                      borderColor = Colors.red;
                      bgColor = Colors.red.withOpacity(0.1);
                      icon = Icons.cancel;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _checkAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            if (icon != null) ...[
                              Icon(icon,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 20),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                option,
                                style: GoogleFonts.cairo(
                                  fontSize: 14
                                      .sp, // Reduced font size to avoid overflow
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (_isAnswered && _selectedOption == correctAnswer)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "أحسنت! إجابة صحيحة 🎉",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_isAnswered && _selectedOption != correctAnswer)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "إجابة خاطئة، الصحيح: $correctAnswer",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
