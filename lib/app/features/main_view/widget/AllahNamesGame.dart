import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/sounds_helper.dart';
import 'dart:math';

class AllahNamesGame extends StatefulWidget {
  const AllahNamesGame({super.key});

  @override
  State<AllahNamesGame> createState() => _AllahNamesGameState();
}

class _AllahNamesGameState extends State<AllahNamesGame> {
  int _currentQuestion = 0;
  int _score = 0;

  final List<Map<String, String>> _allahNames = [
    {'name': 'الرحمن', 'meaning': 'الكثير الرحمة'},
    {'name': 'الرحيم', 'meaning': 'الذي يرحم عباده'},
    {'name': 'الملك', 'meaning': 'المالك لكل شيء'},
    {'name': 'القدوس', 'meaning': 'المنزه عن كل عيب'},
    {'name': 'السلام', 'meaning': 'الذي سلم من كل نقص'},
    {'name': 'المؤمن', 'meaning': 'الذي يؤمن عباده'},
    {'name': 'العزيز', 'meaning': 'القوي الذي لا يغلب'},
    {'name': 'الجبار', 'meaning': 'القاهر فوق عباده'},
    {'name': 'المتكبر', 'meaning': 'المتعالي عن صفات الخلق'},
    {'name': 'الخالق', 'meaning': 'خالق كل شيء'},
    {'name': 'الغفور', 'meaning': 'كثير المغفرة'},
    {'name': 'الكريم', 'meaning': 'كثير العطاء'},
    {'name': 'السميع', 'meaning': 'يسمع كل شيء'},
    {'name': 'البصير', 'meaning': 'يرى كل شيء'},
    {'name': 'الحكيم', 'meaning': 'صاحب الحكمة'},
  ];

  List<String> _currentOptions = [];
  String _correctAnswer = '';

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final nameData = _allahNames[_currentQuestion];
    _correctAnswer = nameData['meaning']!;

    // Generate wrong answers
    final wrongAnswers = _allahNames
        .where((n) => n['meaning'] != _correctAnswer)
        .map((n) => n['meaning']!)
        .toList()
      ..shuffle(Random());

    _currentOptions = [
      _correctAnswer,
      wrongAnswers[0],
      wrongAnswers[1],
    ]..shuffle(Random());
  }

  void _checkAnswer(String selected) {
    bool isCorrect = selected == _correctAnswer;

    if (isCorrect) {
      _score += 5;
      KidsSoundHelper.playSuccess();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCorrect ? 'صحيح! ✅' : 'خطأ ❌',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isCorrect ? 'ممتاز! المعنى صحيح' : 'المعنى الصحيح: $_correctAnswer',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentQuestion < _allahNames.length - 1) {
                setState(() {
                  _currentQuestion++;
                  _generateQuestion();
                });
              } else {
                _showFinalScore();
              }
            },
            child: Text('التالي', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showFinalScore() {
    final stars = _score;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🌟'),
            const SizedBox(width: 8),
            Text(
              'انتهى الاختبار!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تعلمت ${_allahNames.length} اسماً من أسماء الله الحسنى!',
              style: GoogleFonts.cairo(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'نتيجتك: $_score/${_allahNames.length * 5}',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 30),
                const SizedBox(width: 8),
                Text(
                  '+$stars',
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              'تمام',
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
    final nameData = _allahNames[_currentQuestion];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'أسماء الله الحسنى 🌟',
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
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الاسم ${_currentQuestion + 1}/${_allahNames.length}',
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 20),
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade100,
                            Colors.orange.shade50
                          ],
                        ),
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
                          const Text(
                            '🌟',
                            style: TextStyle(fontSize: 50),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            nameData['name']!,
                            style: GoogleFonts.cairo(
                              fontSize: ResponsiveUtil.isTablet(context)
                                  ? 18.sp
                                  : 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ما معنى هذا الاسم؟',
                      style: GoogleFonts.cairo(
                        fontSize:
                            ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._currentOptions.map((option) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              foregroundColor:
                                  isDark ? Colors.white : Colors.black87,
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              option,
                              style: GoogleFonts.cairo(
                                fontSize: ResponsiveUtil.isTablet(context)
                                    ? 11.sp
                                    : 16.sp,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
