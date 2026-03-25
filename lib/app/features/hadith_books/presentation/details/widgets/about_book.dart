import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../../../core/shard/exports/all_exports.dart';

class AboutBook extends StatelessWidget {
  final String bookDetails;
  const AboutBook({super.key, required this.bookDetails});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = AppColors.primary;
    const Color goldColor = Color(0xFFD4AF37);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white24 : goldColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.all(16),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: Icon(
            Icons.info_outline_rounded,
            color: isDark ? goldColor : baseColor,
            size: 26.sp,
          ),
          title: Text(
            'عن الكتاب',
            style: TextStyle(
                  fontFamily: "cairo",
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : baseColor.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bookDetails,
                style: GoogleFonts.amiri(
                  fontSize: 18.sp,
                  height: 1.8,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
