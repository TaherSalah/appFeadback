import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

class SoulComfortWidget extends StatelessWidget {
  const SoulComfortWidget({super.key});

  final List<Map<String, dynamic>> moods = const [
    {
      "label": "مهموم",
      "emoji": "😟",
      "color": Color(0xFFE57373),
      "verse": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "dua": "اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوْ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلَاءَ حُزْنِي، وَذَهَابَ هَمِّي.",
      "msg": "لا تحزن، فالله يسمع دبيب النملة السوداء في الليلة الظلماء.. هو معك."
    },
    {
      "label": "سعيد",
      "emoji": "😃",
      "color": Color(0xFF81C784),
      "verse": "لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
      "dua": "الْحَمْدُ لِلَّهِ الَّذِي بِنِعْمَتِهِ تَتِمُّ الصَّالِحَاتُ.",
      "msg": "أدم شكر الله ليديم عليك نعمه، وشارك فرحتك مع من تحب."
    },
    {
      "label": "مظلوم",
      "emoji": "💔",
      "color": Color(0xFFBA68C8),
      "verse": "وَلَا تَحْسَبَنَّ اللَّهَ غَافِلًا عَمَّا يَعْمَلُ الظَّالِمُونَ",
      "dua": "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ، نِعْمَ الْمَوْلَى وَنِعْمَ النَّصِيرُ.",
      "msg": "عدالة السماء لا تتأخر، إنما تأتي في موعدها الدقيق.. اطمئن."
    },
    {
      "label": "غاضب",
      "emoji": "😡",
      "color": Color(0xFFFF8A65),
      "verse": "وَالْكَاظِمِينَ الْغَيْظَ وَالْعَافِينَ عَنِ النَّاسِ ۗ وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ",
      "dua": "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.",
      "msg": "ليس الشديد بالصرعة، إنما الشديد الذي يملك نفسه عند الغضب."
    },
    {
      "label": "كسول",
      "emoji": "🛌",
      "color": Color(0xFF64B5F6),
      "verse": "وَسَارِعُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا السَّمَاوَاتُ وَالْأَرْضُ",
      "dua": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَالْجُبْنِ وَالْهَرَمِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ.",
      "msg": "ابدأ الآن ولو بخطوة صغيرة، فالرحلة تبدأ بالخطوة الأولى."
    },
    {
      "label": "مديون",
      "emoji": "💸",
      "color": Color(0xFFFFD54F),
      "verse": "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا * وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ",
      "dua": "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.",
      "msg": "الرزق بيد الله، خذ بالأسباب وتوكل على مسبب الأسباب."
    },
     {
      "label": "خائف",
      "emoji": "😨",
      "color": Color(0xFF90A4AE),
      "verse": "أَلَيْسَ اللَّهُ بِكَافٍ عَبْدَهُ",
      "dua": "اللَّهُمَّ اكْفِنِيهِمْ بِمَا شِئْتَ.",
      "msg": "من كان مع الله، فممن يخاف؟ ومن فقد الله، فبمن يستنير؟"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "بماذا تشعر اليوم؟ (راحة القلوب)",
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: moods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return InkWell(
                onTap: () => _showMoodSheet(context, mood, isDark),
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: (mood['color'] as Color).withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (mood['color'] as Color).withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mood['emoji'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        mood['label'],
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMoodSheet(BuildContext context, Map<String, dynamic> mood, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(color: mood['color'], width: 3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 30,
                backgroundColor: (mood['color'] as Color).withOpacity(0.1),
                child: Text(
                  mood['emoji'],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "علاج ${mood['label']}",
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // الآية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (mood['color'] as Color).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (mood['color'] as Color).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "📖 من القرآن الكريم",
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: mood['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood['verse'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri( // خط قرآني
                        fontSize: 18.sp,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
               // الدعاء
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      "🤲 دعاء مستحب",
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood['dua'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
               const SizedBox(height: 16),
               // رسالة
               Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Icon(Icons.format_quote_rounded, color: mood['color'], size: 20),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       mood['msg'],
                       style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey : Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                       ),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 30),
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () => Navigator.pop(context),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: mood['color'],
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(15),
                     ),
                   ),
                   child: Text(
                     "الحمد لله",
                     style: GoogleFonts.cairo(
                       color: Colors.white,
                       fontSize: 16.sp,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                 ),
               ),
            ],
          ),
        );
      },
    );
  }
}
