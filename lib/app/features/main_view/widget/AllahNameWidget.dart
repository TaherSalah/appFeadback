import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllahNameWidget extends StatefulWidget {
  const AllahNameWidget({super.key});

  @override
  State<AllahNameWidget> createState() => _AllahNameWidgetState();
}

class _AllahNameWidgetState extends State<AllahNameWidget> {
  // قائمة أسماء الله الحسنى (عينة)
  final List<Map<String, String>> names = [
    {
      "name": "الرَّحْمَٰنُ",
      "meaning": "الذي وسعت رحمته كل شيء، تشمل المؤمن والكافر في الدنيا.",
      "reflection": "كن رحيماً بمن حولك، واعلم أن رحمة الله أقرب إليك من حبل الوريد."
    },
    {
      "name": "الْوَدُودُ",
      "meaning": "الذي يحب عباده الصالحين ويحبونه، ويتحبب إليهم بالنعم.",
      "reflection": "تقرب إلى الله بما يحب، واجعل الحب أساس تعاملك مع الخلق."
    },
    {
      "name": "الْجَبَّارُ",
      "meaning": "الذي يجبر الكسير، ويغني الفقير، ويقهر الجبابرة.",
      "reflection": "إذا كُسِر قلبك فالجأ للجبار ليجبرك، ولا تتكبر على أحد."
    },
    {
      "name": "اللَّطِيفُ",
      "meaning": "العليم ببدائع الأمور وخفاياها، والرفيق بعباده في إيصال الخير لهم.",
      "reflection": "ثق بتدبير الله الخفي، فربما يكمن الخير فيما تكره."
    },
    {
      "name": "الرَّزَّاقُ",
      "meaning": "الذي تكفل بأرزاق العباد جميعاً، لا ينسى أحداً.",
      "reflection": "اطلب الرزق من الرزاق ولا تذل نفسك لمخلوق، وأنفق مما رزقك الله."
    },
    {
      "name": "الْغَفُورُ",
      "meaning": "الذي يكثر من المغفرة، ويستر الذنوب ويتجاوز عنها.",
      "reflection": "استغفر الله كثيراً، وسامح من أخطأ في حقك لتنال مغفرة الله."
    },
     {
      "name": "الْحَفِيظُ",
      "meaning": "الذي يحفظ عباده من كل سوء، ويحفظ عليهم أعمالهم.",
      "reflection": "احفظ الله يحفظك، واستودع الله كل ما تخاف عليه."
    },
     {
      "name": "الْقَرِيبُ",
      "meaning": "الذي لا يبعد عن أحد، قريب بعلمه وسمعه وإجابته.",
      "reflection": "ناجِ ربك في كل وقت، فهو يسمع دبيب النملة."
    },
  ];

  late Map<String, String> _todaysName;

  @override
  void initState() {
    super.initState();
    final seed = DateTime.now().day + DateTime.now().month * 2; // تغيير يومي مختلف عن الهدية
    final random = Random(seed);
    _todaysName = names[random.nextInt(names.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            "تعرف على ربك ❤️",
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage("assets/images/pattern.webp"), // خلفية إسلامية (سنستخدم تدرج لوني كبديل إن لم توجد)
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0F2027), const Color(0xFF2C5364)]
                    : [const Color(0xFFE0F7FA), const Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.cyan.withOpacity(0.3) : Colors.cyan.shade100,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                  ).createShader(bounds),
                  child: Text(
                    _todaysName['name']!,
                    style: GoogleFonts.amiri(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color is ignored by ShaderMask but required
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  width: 50,
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  _todaysName['meaning']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.cyan.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.cyan.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _todaysName['reflection']!,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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
