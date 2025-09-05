





import '../../../core/shard/exports/all_exports.dart';

class GreetingWidget extends StatefulWidget {
  const GreetingWidget({super.key});

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget> {
  late String greeting;

  @override
  void initState() {
    super.initState();
    // نهيئ التحية الأولى عند فتح الشاشة
    greeting = _getHalalGreeting();
    // نضبط المؤقت ليعيد الحساب وتغيير التحية عندما يصير الوقت مساويًا أو بعد 05:00 أو 15:00
    _scheduleNextGreetingUpdate();
  }

  /// ترجع "مساء الخير" إذا كان الوقت >= 15:00 أو < 05:00، وإلا ترجع "صباح الخير"
  String _getHalalGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 15 || hour < 5) {
      return 'مساء الخير 🌙';
    } else {
      return 'صباح الخير ☀';
    }
  }

  /// نحسب متى نحتاج لتحديث التحية التالية (05:00 أو 15:00)
  void _scheduleNextGreetingUpdate() {
    final now = DateTime.now();

    // نحسب أول موعد قادم من هذه الأوقات: 05:00 أو 15:00
    DateTime nextUpdate;
    if (now.hour < 5) {
      // إذا كانت الساعة الآن أقل من 5 صباحًا، فالتحديث القادم عند 05:00 اليوم نفسه
      nextUpdate = DateTime(now.year, now.month, now.day, 5, 0, 0);
    } else if (now.hour < 15) {
      // إذا كانت الساعة الآن بين 5 صباحًا و15 مساءً، فالتحديث القادم عند 15:00 اليوم نفسه
      nextUpdate = DateTime(now.year, now.month, now.day, 15, 0, 0);
    } else {
      // إذا كانت الساعة >= 15 مساءً، فالتحديث القادم عند 05:00 صباح الغد
      final tomorrow = now.add(const Duration(days: 1));
      nextUpdate =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0, 0);
    }

    final durationUntilNext = nextUpdate.difference(now);
    Future.delayed(durationUntilNext, () {
      if (!mounted) return;
      setState(() {
        greeting = _getHalalGreeting();
      });
      // بعد تغيّر التحية، نعيد جدولة التحديث التالي
      _scheduleNextGreetingUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text(
    //   greeting,
    //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    // );

    return Align(
      alignment: Alignment.topRight,
      child: Text(
        greeting,
        style: GoogleFonts.cairo(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize:MediaQuery.sizeOf(context).width >600?14.sp: 18.sp),
      ),
    );
  }
}