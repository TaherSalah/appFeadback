import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/hadith_of_day_controller.dart';
import '../../controllers/books_controller.dart';
import '../hadith_of_day_view.dart';
import '../../../../core/utils/style/k_color.dart';

class HadithOfDayCard extends StatelessWidget {
  const HadithOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;
    final hadithCtrl = Get.put(HadithOfDayController());

    return Obx(() {
      if (hadithCtrl.isLoading.value) {
        return _buildLoadingCard(isDark, baseColor,context);
      }

      final hadith = hadithCtrl.todayHadith.value;
      if (hadith == null) {
        return _buildEmptyCard(isDark, baseColor);
      }

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HadithOfDayView(),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [
                      const Color(0xFF1E3A5F),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFFFF5E1),
                      const Color(0xFFFFE4B5),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withOpacity(isDark ? 0.3 : 0.2),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                // Decorative Pattern
                Positioned(
                  top: -50.h,
                  right: -50.w,
                  child: Container(
                    width: 150.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30.h,
                  left: -30.w,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor.withOpacity(0.08),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.wb_sunny_outlined,
                              color: baseColor,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حديث اليوم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  _formatDate(DateTime.now()),
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Hadith Text (Preview)
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: baseColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          hadith.hadithText.length > 150
                              ? '${hadith.hadithText.substring(0, 150)}...'
                              : hadith.hadithText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'naskh',
                            height: 1.8,
                            fontSize: 16.sp,
                            color: isDark ? Colors.grey[100] : const Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Footer: Book Name & Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Book Name
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14.sp,
                                  color: isDark ? Colors.grey[500] : Colors.grey[700],
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    hadith.bookName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick Actions
                          Row(
                            children: [
                              _QuickActionButton(
                                icon: Icons.copy_rounded,
                                onTap: () => _copyHadith(hadith.hadithText),
                              ),
                              SizedBox(width: 8.w),
                              _QuickActionButton(
                                icon: Icons.share_rounded,
                                onTap: () => _shareHadith(hadith.hadithText, hadith.bookName),
                              ),
                              SizedBox(width: 8.w),
                              GetBuilder<BooksController>(
                                builder: (ctrl) {
                                  final isBookmarked = ctrl.isBookmarked(hadith.id ?? 0);
                                  return _QuickActionButton(
                                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    onTap: () async {
                                      await ctrl.toggleBookmark(hadith);
                                      Fluttertoast.showToast(
                                        msg: isBookmarked ? "تم إلغاء حفظ الحديث" : "تم حفظ الحديث",
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: isBookmarked ? Colors.orange : Colors.green,
                                        textColor: Colors.white,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadingCard(bool isDark, Color baseColor,BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      height: 250.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: isDark ? Colors.grey[900] : Colors.grey[100],
      ),
      child: Center(
        child: KLoading.progressIOSIndicator(context: context,progressColor: baseColor),
      ),
    );
  }

  Widget _buildEmptyCard(bool isDark, Color baseColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: isDark ? Colors.grey[900] : Colors.grey[100],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.grey[500],
          ),
          SizedBox(height: 12.h),
          Text(
            'لم يتم تحميل حديث اليوم',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  void _copyHadith(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "تم نسخ الحديث",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _shareHadith(String text, String bookName) {
    Share.share(
      '$text\n\nمن: $bookName\nحديث اليوم - تطبيق رفيق المسلم اليومي',
      subject: 'حديث اليوم',
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
    );
  }
}
