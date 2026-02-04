import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'kids_data/sounds_helper.dart';
import 'dart:math';
import '../../../core/utils/style/k_dialog_helper.dart';

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

    KDialogHelper.showCustomDialog(
      context: context,
      type: isCorrect ? KDialogType.success : KDialogType.error,
      icon: isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
      title: isCorrect ? 'صحيح!' : 'خطأ',
      description: isCorrect
          ? 'ممتاز! المعنى صحيح'
          : 'المعنى الصحيح هو: $_correctAnswer',
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'التالي',
          color: isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
        ),
      ],
    );
  }

  void _showFinalScore() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.emoji_events_rounded,
      title: 'انتهى الاختبار!',
      description: 'تعلمت ${_allahNames.length} اسماً من أسماء الله الحسنى!',
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'نتيجتك: $_score/${_allahNames.length * 5}',
            style: GoogleFonts.cairo(
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
                  'حصلت على $_score نجمة ✨',
                  style: GoogleFonts.cairo(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nameData = _allahNames[_currentQuestion];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'أسماء الله الحسنى 🌟',
        //     style: GoogleFonts.cairo(
        //       fontWeight: FontWeight.bold,
        //       fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
        //     ),
        //   ),
        //   centerTitle: true,
        // ),
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
              "أسماء الله الحسنى",
              style: GoogleFonts.cairo(
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
            // Progress
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient:  LinearGradient(
                  colors: [KColors.primaryColor, KColors.primaryColor],
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
                    Text(
                      nameData['name']!,
                      style: GoogleFonts.cairo(
                        fontSize: ResponsiveUtil.isTablet(context)
                            ? 18.sp
                            : 32.sp,
                        fontWeight: FontWeight.bold,
                        color:isDark?KColors.primaryColor :Colors.brown.shade700,
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
