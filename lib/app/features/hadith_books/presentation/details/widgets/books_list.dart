import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/hadith_books/controllers/extensions/books_getters_extension.dart';
import 'package:muslimdaily/app/features/messaView/azkar_massa.dart';

import '../../../../../core/shard/exports/all_exports.dart';
import '../../../../../core/utils/style/responsive_util.dart';
import '../../../controllers/books_controller.dart';

class BooksList extends StatelessWidget {
  const BooksList({super.key});

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = AppColors.primary;
    const Color goldColor = Color(0xFFD4AF37);

    return GetBuilder<BooksController>(builder: (controller) {
      if (controller.currentCollection.booksNames.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: baseColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل الكتب...',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      final booksNames = controller.currentCollection.booksNames.toList();
      
      return ListView.separated(
        primary: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: booksNames.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, i) {
          final book = booksNames[i];
          return GestureDetector(
            onTap: () => controller.setAndShowBookByBookNumber(
              double.parse(book.bookNumber).toInt(),
            ),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? Colors.white24 : goldColor.withOpacity(0.5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Gold Badge for Number
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: isDark ? goldColor.withOpacity(0.15) : baseColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? goldColor.withOpacity(0.3) : baseColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? goldColor : baseColor,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 16.w),
                  
                  // Book Name
                  Expanded(
                    child: Text(
                      book.bookName,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Arrow icon
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14.sp,
                    color: isDark ? Colors.white24 : Colors.grey[300],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
