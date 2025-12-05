





import 'dart:math';

import 'package:hijri/hijri_calendar.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/style/k_color.dart';

// class GreetingWidget extends StatefulWidget {
//   const GreetingWidget({super.key});
//
//   @override
//   State<GreetingWidget> createState() => _GreetingWidgetState();
// }
//
// class _GreetingWidgetState extends State<GreetingWidget> {
//   late String greeting;
//
//   @override
//   void initState() {
//     super.initState();
//     // نهيئ التحية الأولى عند فتح الشاشة
//     greeting = _getHalalGreeting();
//     // نضبط المؤقت ليعيد الحساب وتغيير التحية عندما يصير الوقت مساويًا أو بعد 05:00 أو 15:00
//     _scheduleNextGreetingUpdate();
//   }
//
//   /// ترجع "مساء الخير" إذا كان الوقت >= 15:00 أو < 05:00، وإلا ترجع "صباح الخير"
//   // String _getHalalGreeting() {
//   //   final now = DateTime.now();
//   //   final hour = now.hour;
//   //
//   //   if (hour >= 5 && hour < 13) {
//   //     return 'أسعد الله صباحك بالخير والبركة 🌤️';
//   //   } else {
//   //     return 'أسعد الله مساك بالسكينة والرضا 🌙';
//   //   }
//   // }
//
//   String _getHalalGreeting() {
//     final now = DateTime.now();
//     final hour = now.hour;
//
//     if (hour >= 5 && hour < 13) {
//       return 'صَباحُ الطَّاعَةِ 🌤️';
//     } else if (hour >= 13 && hour < 23) {
//       return 'مَساءُ الرَّحْمَةِ 🌙';
//     } else if (hour >= 23 || hour < 3) {
//       return 'وَقْتُ قِيامِ اللَّيْلِ، نَسْأَلُ اللهَ القَبُولَ 🤲';
//     } else {
//       return 'لَيْلَةٌ مُبارَكَةٌ 🌌';
//     }
//   }
//
//   String getReminder() {
//     final hour = DateTime.now().hour;
//
//     if (hour == 9) {
//       return 'لَا تَنْسَ أذكارَ الصَّباحِ 🌤️';
//     } else if (hour == 18) {
//       return 'لَا تَنْسَ أذكارَ المَساءِ 🌙';
//     } else if (hour == 22) {
//       return 'لَا تَنْسَ أذكارَ النَّومِ 🛌';
//     } else {
//       return '';
//     }
//   }
//
//
//   /// نحسب متى نحتاج لتحديث التحية التالية (05:00 أو 15:00)
//   void _scheduleNextGreetingUpdate() {
//     final now = DateTime.now();
//
//     // نحسب أول موعد قادم من هذه الأوقات: 05:00 أو 15:00
//     DateTime nextUpdate;
//     if (now.hour < 5) {
//       // إذا كانت الساعة الآن أقل من 5 صباحًا، فالتحديث القادم عند 05:00 اليوم نفسه
//       nextUpdate = DateTime(now.year, now.month, now.day, 5, 0, 0);
//     } else if (now.hour < 15) {
//       // إذا كانت الساعة الآن بين 5 صباحًا و15 مساءً، فالتحديث القادم عند 15:00 اليوم نفسه
//       nextUpdate = DateTime(now.year, now.month, now.day, 15, 0, 0);
//     } else {
//       // إذا كانت الساعة >= 15 مساءً، فالتحديث القادم عند 05:00 صباح الغد
//       final tomorrow = now.add(const Duration(days: 1));
//       nextUpdate =
//           DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0, 0);
//     }
//
//     final durationUntilNext = nextUpdate.difference(now);
//     Future.delayed(durationUntilNext, () {
//       if (!mounted) return;
//       setState(() {
//         greeting = _getHalalGreeting();
//       });
//       // بعد تغيّر التحية، نعيد جدولة التحديث التالي
//       _scheduleNextGreetingUpdate();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final reminder = getReminder();
//
//     return Align(
//       alignment: Alignment.topRight,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // التحية
//           Text(
//             greeting,
//             style: GoogleFonts.notoKufiArabic(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? Colors.white
//                   : Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 17.sp,
//             ),
//           ),
//
//           // مسافة صغيرة بين التحية والتذكير
//           if (reminder.isNotEmpty) const SizedBox(width: 8),
//
//           // التذكير (لو موجود)
//           if (reminder.isNotEmpty)
//             Text(
//               reminder,
//               style: GoogleFonts.notoKufiArabic(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.white70
//                     : Colors.black54,
//                 fontWeight: FontWeight.w500,
//                 fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 14.sp,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

class HalalGreeting extends StatefulWidget {
  const HalalGreeting({super.key});

  @override
  State<HalalGreeting> createState() => _HalalGreetingState();
}

class _HalalGreetingState extends State<HalalGreeting> {
  late String greeting;

  @override
  void initState() {
    super.initState();
    greeting = _getFinalGreeting();
    _scheduleNextGreetingUpdate();
  }

  /// ============= تنبيهات الأيام الأسبوعية =============
  String? _getWeeklyReminder() {
    final weekday = DateTime.now().weekday;

    switch (weekday) {
      case DateTime.sunday: // الأحد
        return '🌙 لا تَنْسَ صِيام غدًا الإثنين';
      case DateTime.wednesday: // الأربعاء
        return '🌙 لا تَنْسَ صِيام غدًا الخميس';
      case DateTime.friday: // الجمعة
        return 'لا تَنْسَ قراءة سورة الكهف';
      default:
        return null;
    }
  }
 var hijri = HijriCalendar.now();

  /// ============= تنبيهات الأيام البيض (13، 14، 15 هجري) =============
  String? _getWhiteDaysReminder() {
    final dayHijri = hijri.hDay; // اليوم الهجري الحقيقي
    if ([13, 14, 15].contains(dayHijri)) {
      return '🌙 لا تَنْسَ صِيام الأيام البيض';
    }
    return null;
  }

  /// ============= تنبيهات قيام الليل (مثلاً 23:00 - 03:00) =============
  String? _getQiyamReminder() {
    final hour = DateTime.now().hour;
    if (hour >= 23 || hour < 3) {
      return '🤲 وقت قيام الليل';
    }
    return null;
  }

  /// ============= تحية حسب الوقت =============
  String _getHalalGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 13) {
      return '🌤️ صَباحُ الطَّاعَةِ';
    } else if (hour >= 13 && hour < 23) {
      return '🌙 مَساءُ الرَّحْمَةِ';
    } else {
      return '🌌 لَيْلَةٌ مُبارَكَة';
    }
  }

  /// ============= الدمج بين كل التنبيهات + التحية =============
  String _getFinalGreeting() {
    final weekly = _getWeeklyReminder();
    if (weekly != null) return weekly;

    final whiteDays = _getWhiteDaysReminder();
    if (whiteDays != null) return whiteDays;

    final qiyam = _getQiyamReminder();
    if (qiyam != null) return qiyam;

    return _getHalalGreeting();
  }

  /// ============= تحديث تلقائي كل يوم عند منتصف الليل =============
  void _scheduleNextGreetingUpdate() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextUpdate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 5);

    final durationUntilNext = nextUpdate.difference(now);

    Future.delayed(durationUntilNext, () {
      if (!mounted) return;
      setState(() {
        greeting = _getFinalGreeting();
      });
      _scheduleNextGreetingUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      greeting,
      textAlign: TextAlign.center,
      style: GoogleFonts.notoKufiArabic(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 13.sp,
      ),
    );
  }
}


class AdhkarReminder extends StatefulWidget {
  const AdhkarReminder({super.key});

  @override
  State<AdhkarReminder> createState() => _AdhkarReminderState();
}

class _AdhkarReminderState extends State<AdhkarReminder> {
  String reminder = '';


  final List<String> randomMessages = [
    'لا تنسَ ذكر الله',
    'صلِّ على رسول الله ﷺ',
    'استغفرِ الله العظيم',
    'سبحان الله وبحمده',
    // 'أكثر من الصلاة على النبي ﷺ',
  ];

  @override
  void initState() {
    super.initState();
    reminder = _getReminder();
    _scheduleNextReminderUpdate();
  }

  // دالة اختيار رسالة عشوائية مختلفة عن السابقة
  String _getRandomMessage(String previous) {
    final filtered = randomMessages.where((m) => m != previous).toList();
    return filtered[Random().nextInt(filtered.length)];
  }

  // String _getReminder() {
  //   final hour = DateTime.now().hour;
  //
  //   if (hour >= 9 && hour < 10) {
  //     return 'لَا تَنْسَ أذكارَ الصَّباحِ️ 🌅';
  //   } else if (hour >= 18 && hour < 19) {
  //     return 'لَا تَنْسَ أذكارَ المَساء 🌆';
  //   } else if (hour >= 22 && hour < 23) {
  //     return 'لَا تَنْسَ أذكارَ النَّوم 🌙';
  //   } else {
  //     return _getRandomMessage(reminder);
  //   }
  // }
  String _getReminder() {
    final hour = DateTime.now().hour;

    if (hour >= 9 && hour < 10) {
      return 'لَا تَنْسَ أذكارَ الصَّباح';
    } else if (hour >= 18 && hour < 19) {
      return 'لَا تَنْسَ أذكارَ المَساء';
    } else if (hour >= 22 && hour < 23) {
      return 'لَا تَنْسَ أذكارَ النَّوم';
    } else {
      return _getRandomMessage(reminder);
    }
  }

  void _scheduleNextReminderUpdate() {
    Future.delayed(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() {
        reminder = _getReminder();
      });
      _scheduleNextReminderUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (reminder.isEmpty) return const SizedBox.shrink();

    return Text(
      reminder,
      style: GoogleFonts.notoKufiArabic(
        fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 13.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        // color: Theme.of(context).brightness == Brightness.dark
        //     ? Colors.white.withOpacity(0.8)
        //     : const Color(0xFF2C3E50),
      ),
      textAlign: TextAlign.center,
    );
  }
}
