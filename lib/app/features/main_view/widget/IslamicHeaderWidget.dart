import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';



class IslamicHeaderWidget extends StatelessWidget {
  final String? gregorian;
  final String hijriDate;
  final String nextPrayer;
  final String remainingTimeText;

  const IslamicHeaderWidget({
    super.key,
    required this.gregorian,
    required this.hijriDate,
    required this.nextPrayer,
    required this.remainingTimeText,
  });

  String _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'الفجر':
        return '🌅';
      case 'الظهر':
        return '☀️';
      case 'العصر':
        return '🌤️';
      case 'المغرب':
        return '🌇';
      case 'العشاء':
        return '🌙';
      default:
        return '🕌';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width > 600;

    return Row(
      children: [
        // بطاقة التاريخ
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: isTablet ? width / 6 : width / 3.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xfffacf70),
                  Color(0xfffaf38e),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.shade100.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.teal.shade700,
                    size: isTablet ? 36 : 28,
                  ),
                  Text(
                    gregorian ?? '',
                    style: GoogleFonts.cairo(
                      color: Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 17 : 12,
                    ),
                  ),
                  Text(
                    hijriDate,
                    style: GoogleFonts.cairo(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // بطاقة الصلاة القادمة
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: isTablet ? width / 6 : width / 3.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFede7f6),
                  Color(0xFFd1c4e9),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade100.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${_getPrayerIcon(nextPrayer)} $nextPrayer',
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 18 : 15,
                    ),
                  ),
                  Text(
                    'الوقت المتبقي:',
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 13 : 12,
                    ),
                  ),
                  Text(
                    remainingTimeText,
                    style: GoogleFonts.cairo(
                      color: Colors.deepPurple.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
