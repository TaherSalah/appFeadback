import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../../core/utils/style/responsive_util.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../../../core/shard/constanc/app_style.dart';

class BookOtherName extends StatelessWidget {
  const BookOtherName({super.key});

  @override
  Widget build(BuildContext context) {
    final booksCtrl = Get.find<BooksController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;

    return Container(
      height: MediaQuery.sizeOf(context).height * .7,
      width: double.infinity,
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : baseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(
          color: baseColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative Icon
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 40.sp,
              color: baseColor,
            ),
          ),
          SizedBox(height: 48.h),

          // Collection Name
          Text(
            booksCtrl.currentCollection.arAndEnName,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Ornament Divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 1, width: 40.w, color: baseColor.withOpacity(0.3)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Icon(Icons.star_rounded, size: 12.sp, color: baseColor),
              ),
              Container(height: 1, width: 40.w, color: baseColor.withOpacity(0.3)),
            ],
          ),

          SizedBox(height: 16.h),

          // Book Name
          Text(
            booksCtrl.currentBookName,
            style: TextStyle(
              fontFamily: 'naskh',
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? baseColor : const Color(0xffa24308),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 48.h),

          // Instruction
          Text(
            "اسحب لليسار لبدء القراءة",
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          SizedBox(height: 8.h),
          Icon(
            Icons.keyboard_double_arrow_left_rounded,
            color: isDark ? Colors.white24 : Colors.black12,
            size: 24.sp,
          ),
        ],
      ),
    );
  }
}
