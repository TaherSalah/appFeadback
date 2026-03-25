import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/style/k_color.dart';
import '../../../core/widgets/KLoading.dart';
import '../controllers/hadith_of_day_controller.dart';
import '../controllers/books_controller.dart';

class HadithOfDayView extends StatelessWidget {
  const HadithOfDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = KColors.primaryColor;
    final hadithCtrl = Get.find<HadithOfDayController>();
    Get.find<BooksController>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'حديث اليوم',
          style: TextStyle(
                  fontFamily: "cairo",
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: () async {
              await hadithCtrl.forceRefresh();
              Fluttertoast.showToast(
                msg: "تم تحديث حديث اليوم",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final hadith = hadithCtrl.todayHadith.value;

        if (hadithCtrl.isLoading.value) {
          return Center(
            child: KLoading.progressIOSIndicator(context: context,progressColor: baseColor) ,
          );
        }

        if (hadith == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'لم يتم تحميل حديث اليوم',
                  style: TextStyle(
                  fontFamily: "cairo",
                    fontSize: 18.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Header
              Container(
                width: double.infinity,
                margin: EdgeInsets.all(16.r),
                padding: EdgeInsets.all(24.r),
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
                      color: baseColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 48.sp,
                      color: baseColor,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'حديث اليوم',
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _formatDate(DateTime.now()),
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Hadith Content
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border.all(
                    color: baseColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book & Hadith Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 14.sp,
                                  color: baseColor,
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    hadith.bookName,
                                    style: TextStyle(
                  fontFamily: "cairo",
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: baseColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '#${hadith.hadithNumber}',
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Hadith Text
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: baseColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        hadith.hadithText,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'naskh',
                          height: 1.9,
                          fontSize: 18.sp,
                          color: isDark ? Colors.grey[100] : Colors.grey[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Grade
                    if (hadith.grade1 != null && hadith.grade1!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              hadith.grade1!,
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Chapter/Narrator Info
                    if (hadith.babName != null && hadith.babName!.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16.sp,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                hadith.babName!,
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: 13.sp,
                                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Action Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.copy_rounded,
                        label: 'نسخ',
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: hadith.hadithText));
                          Fluttertoast.showToast(
                            msg: "تم نسخ الحديث",
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                          );
                        },
                        isDark: isDark,
                        baseColor: baseColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GetBuilder<BooksController>(
                        builder: (ctrl) {
                          final isBookmarked = ctrl.isBookmarked(hadith.id ?? 0);
                          return _ActionButton(
                            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            label: isBookmarked ? 'محفوظ' : 'حفظ',
                            onTap: () async {
                              await ctrl.toggleBookmark(hadith);
                              Fluttertoast.showToast(
                                msg: isBookmarked ? "تم إلغاء الحفظ" : "تم الحفظ",
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: isBookmarked ? Colors.orange : Colors.green,
                              );
                            },
                            isDark: isDark,
                            baseColor: baseColor,
                            isHighlighted: isBookmarked,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.share_rounded,
                        label: 'مشاركة',
                        onTap: () {
                          Share.share(
                            '${hadith.hadithText}\n\nمن: ${hadith.bookName}\nحديث رقم: ${hadith.hadithNumber}\n\nحديث اليوم - تطبيق رفيق المسلم اليومي',
                            subject: 'حديث اليوم',
                          );
                        },
                        isDark: isDark,
                        baseColor: baseColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final arabicDays = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
    ];
    return '${arabicDays[date.weekday - 1]} ${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color baseColor;
  final bool isHighlighted;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.baseColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isHighlighted
                ? baseColor.withOpacity(0.2)
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : baseColor.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isHighlighted
                  ? baseColor.withOpacity(0.4)
                  : baseColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: isHighlighted
                    ? baseColor
                    : (isDark ? Colors.grey[300] : baseColor),
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isHighlighted
                      ? baseColor
                      : (isDark ? Colors.grey[300] : Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
