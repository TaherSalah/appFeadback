import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart'; // سنستخدم أيقونة متحركة إذا توفرت، أو صورة ثابتة كبديل

class DailyGiftWidget extends StatefulWidget {
  const DailyGiftWidget({super.key});

  @override
  State<DailyGiftWidget> createState() => _DailyGiftWidgetState();
}

class _DailyGiftWidgetState extends State<DailyGiftWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpened = false;

  // قائمة الهدايا (سنن مهجورة، كنوز، حكم)
  final List<Map<String, String>> _gifts = [
    {
      "type": "سنة مهجورة",
      "title": "الشرب على ثلاث دفعات",
      "content": "كان النبي ﷺ يشرب في ثلاثة أنفاس، ويقول: «إنه أروى وأبرأ وأمرأ». (رواه مسلم)",
      "action": "سأطبقها اليوم 💧"
    },
    {
      "type": "كنز من كنوز الجنة",
      "title": "لا حول ولا قوة إلا بالله",
      "content": "قال النبي ﷺ: «ألا أدلك على كنز من كنوز الجنة؟ لا حول ولا قوة إلا بالله».",
      "action": "رددها الآن 🤲"
    },
    {
      "type": "سنة مهجورة",
      "title": "نفض الفراش قبل النوم",
      "content": "قال النبي ﷺ: «إذا أوى أحدكم إلى فراشه فلينفض فراشه بداخلة إزاره، فإنه لا يدري ما خلفه عليه».",
      "action": "سأفعلها الليلة 🛌"
    },
    {
      "type": "سنة مهجورة",
      "title": "الدعاء لأخيك بظهر الغيب",
      "content": "قال النبي ﷺ: «دعوة المرء المسلم لأخيه بظهر الغيب مستجابة، عند رأسه ملك موكل كلما دعا لأخيه بخير قال الملك الموكل به: آمين ولك بمثل».",
      "action": "سأدعو لصديق ❤️"
    },
    {
      "type": "حكمة",
      "title": "الرضا",
      "content": "من رضي بقضاء الله جرى عليه وكان له أجر، ومن لم يرض جرى عليه وكان عليه وزر.",
      "action": "الحمد لله 🤲"
    },
     {
      "type": "ذكر عظيم",
      "title": "كلمتان خفيفتان",
      "content": "«كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن: سبحان الله وبحمده، سبحان الله العظيم».",
      "action": "سبحان الله وبحمده ✨"
    },
  ];

  late Map<String, String> _todaysGift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    // اختيار هدية عشوائية لليوم
    // (يمكن تطويرها لتعتمد على التاريخ حتى تكون ثابتة طوال اليوم)
    final seed = DateTime.now().day + DateTime.now().month + DateTime.now().year;
    final random = Random(seed); 
    _todaysGift = _gifts[random.nextInt(_gifts.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openGift() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الخلفية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFFFD700), // ذهبي
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                     Text(
                      "🎉 ربحت هدية! 🎉",
                      style: GoogleFonts.cairo(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _todaysGift['type']!,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _todaysGift['title']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _todaysGift['content']!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 16.sp,
                        height: 1.6,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), // ذهبي
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _isOpened = true; 
                          });
                        },
                        child: Text(
                          _todaysGift['action']!,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // أيقونة شريط في الأعلى
              Positioned(
                top: -25,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFFFD700),
                  child: const Icon(Icons.card_giftcard, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpened) return const SizedBox.shrink(); // تختفي بعد الفتح (اختياري)

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: _openGift,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [const Color(0xFF2C3E50), const Color(0xFF4CA1AF)] 
                  : [const Color(0xFFFFE0B2), const Color(0xFFFFCC80)], // برتقالي فاتح
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // أيقونة متحركة (محاكاة)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -3 * _controller.value), // حركة بسيطة للأعلى والأسفل
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "لديك هدية جديدة! 🎁",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "اضغط لفتح صندوق هدايا الرحمن اليومي",
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
