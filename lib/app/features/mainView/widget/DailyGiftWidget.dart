import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/style/k_dialog_helper.dart';

class DailyGiftWidget extends StatefulWidget {
  const DailyGiftWidget({super.key});

  @override
  State<DailyGiftWidget> createState() => _DailyGiftWidgetState();
}

class _DailyGiftWidgetState extends State<DailyGiftWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpened = false;

  // قائمة الهدايا (سنن مهجورة، كنوز، حكم)
  final List<Map<String, String>> _gifts = [
    {
      "type": "سنة مهجورة",
      "title": "الشرب على ثلاث دفعات",
      "content":
          "كان النبي ﷺ يشرب في ثلاثة أنفاس، ويقول: «إنه أروى وأبرأ وأمرأ». (رواه مسلم)",
      "action": "سأطبقها اليوم 💧"
    },
    {
      "type": "كنز من كنوز الجنة",
      "title": "لا حول ولا قوة إلا بالله",
      "content":
          "قال النبي ﷺ: «ألا أدلك على كنز من كنوز الجنة؟ لا حول ولا قوة إلا بالله».",
      "action": "رددها الآن 🤲"
    },
    {
      "type": "سنة مهجورة",
      "title": "نفض الفراش قبل النوم",
      "content":
          "قال النبي ﷺ: «إذا أوى أحدكم إلى فراشه فلينفض فراشه بداخلة إزاره، فإنه لا يدري ما خلفه عليه».",
      "action": "سأفعلها الليلة 🛌"
    },
    {
      "type": "سنة مهجورة",
      "title": "الدعاء لأخيك بظهر الغيب",
      "content":
          "قال النبي ﷺ: «دعوة المرء المسلم لأخيه بظهر الغيب مستجابة، عند رأسه ملك موكل كلما دعا لأخيه بخير قال الملك الموكل به: آمين ولك بمثل».",
      "action": "سأدعو لصديق ❤️"
    },
    {
      "type": "حكمة",
      "title": "الرضا",
      "content":
          "من رضي بقضاء الله جرى عليه وكان له أجر، ومن لم يرض جرى عليه وكان عليه وزر.",
      "action": "الحمد لله 🤲"
    },
    {
      "type": "ذكر عظيم",
      "title": "كلمتان خفيفتان",
      "content":
          "«كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن: سبحان الله وبحمده، سبحان الله العظيم».",
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
    final seed =
        DateTime.now().day + DateTime.now().month + DateTime.now().year;
    final random = Random(seed);
    _todaysGift = _gifts[random.nextInt(_gifts.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openGift() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.info,
      icon: Icons.card_giftcard_rounded,
      title: "🎉 ربحت هدية! 🎉",
      description: _todaysGift['title']!,
      additionalContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _todaysGift['type']!,
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 12.sp,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _todaysGift['content']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 18.sp,
              height: 1.6,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[100]
                  : Colors.grey[900],
            ),
          ),
        ],
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: _todaysGift['action']!,
          color: const Color(0xFFFFD700),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _isOpened = true;
            });
          },
        ),
      ],
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
                  : [
                      const Color(0xFFFFE0B2),
                      const Color(0xFFFFCC80)
                    ], // برتقالي فاتح
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
                    offset: Offset(
                        0, -3 * _controller.value), // حركة بسيطة للأعلى والأسفل
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
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "اضغط لفتح صندوق هدايا الرحمن اليومي",
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 11.sp,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}
