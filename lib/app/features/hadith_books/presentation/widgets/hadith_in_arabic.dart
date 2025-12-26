import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

import '../../../../core/shard/constanc/app_style.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';
import '../../data/models/ar_hadith_model.dart';
import '../../../../features/shareCard/PremiumShareCard.dart';

class HadithInArabic extends StatelessWidget {
  final ARHadithModel arabicHadith;
  final String otherLangHadithText;

  HadithInArabic({
    super.key,
    required this.arabicHadith,
    required this.otherLangHadithText,
  });

  final booksCtrl = Get.find<BooksController>();

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "تم نسخ الحديث بنجاح",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  void shareText(String text, String title) {
    Share.share(
      text,
      subject: title,
    );
  }

  Future<void> _showCategoryDialog(BuildContext context, ARHadithModel hadith) async {
    final categories = [
      'أخلاق',
      'عبادات',
      'فضائل',
      'أحكام',
      'سيرة نبوية',
      'دعاء',
      'عام',
    ];

    String? selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final baseColor = KColors.primaryColor;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر التصنيف',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),
                ...categories.map((category) {
                  return InkWell(
                    onTap: () => Navigator.pop(context, category),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: baseColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCategory != null) {
      await booksCtrl.toggleBookmark(hadith, category: selectedCategory);
      Fluttertoast.showToast(
        msg: "تم حفظ الحديث في: $selectedCategory",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final baseColor = KColors.primaryColor;
    
    final shareFullText = """
حديث رقم: ${arabicHadith.hadithNumber}
${arabicHadith.hadithText}

الترجمة:
$otherLangHadithText

من تطبيق رفيق المسلم اليومي
""";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main Premium Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? const [
                        Color(0xFF020617),
                        Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFFF7F1E1),
                        Colors.white,
                      ],
              ),
              border: Border.all(
                color: baseColor.withOpacity(isDark ? 0.5 : 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(isDark ? 0.4 : 0.18),
                  blurRadius: 16,
                  spreadRadius: 0.5,
                  offset: Offset(0, isDark ? 10 : 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Book Title & Number Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "حديث #${arabicHadith.hadithNumber}",
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                      if (arabicHadith.grade1 != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            arabicHadith.grade1!,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: 20.h),

                  // Arabic Hadith Text
                  Text(
                    arabicHadith.hadithText,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'naskh',
                      height: 1.8,
                      fontSize: size.width > 600 ? 14.sp : 20.sp,
                      color: isDark ? Colors.grey[100] : Colors.grey[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 20.h),
                  
                  // Divider
                  _OrnamentDivider(color: baseColor),
                  
                  SizedBox(height: 10.h),

                  // Translation Section
                  Text(
                    'الترجمة',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: baseColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: baseColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      otherLangHadithText,
                      textAlign: TextAlign.left,
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.roboto(
                        height: 1.7,
                        fontSize: size.width > 600 ? 11.sp : 15.sp,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Action Buttons
                  GetBuilder<BooksController>(
                    builder: (ctrl) {
                      final isBookmarked = ctrl.isBookmarked(arabicHadith.id ?? 0);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ActionButton(
                            icon: Icons.copy_rounded,
                            label: "نسخ",
                            onTap: () => copyText(shareFullText),
                          ),
                          _ActionButton(
                            icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            label: isBookmarked ? "محفوظ" : "حفظ",
                            onTap: () async {
                              if (!isBookmarked) {
                                // Show category selection dialog
                                await _showCategoryDialog(context, arabicHadith);
                              } else {
                                // Remove bookmark
                                await ctrl.toggleBookmark(arabicHadith);
                                Fluttertoast.showToast(
                                  msg: "تم إلغاء حفظ الحديث",
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.orange.shade600,
                                  textColor: Colors.white,
                                );
                              }
                            },
                            isHighlighted: isBookmarked,
                          ),
                          _ActionButton(
                            icon: Icons.image_outlined,
                            label: "صورة",
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                pageBuilder: (context, anim1, anim2) =>
                                    PremiumShareCard(
                                  azkarName: arabicHadith.bookName,
                                  text: arabicHadith.hadithText,
                                  source: arabicHadith.grade1,
                                ),
                              );
                            },
                          ),
                          _ActionButton(
                            icon: Icons.share_rounded,
                            label: "مشاركة",
                            onTap: () => shareText(shareFullText, "حديث نبوي شريف"),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Badge (Hadith number in circle above the card)
          Positioned(
            top: -15.h,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(30.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: isHighlighted
              ? primary.withOpacity(0.2)
              : (isDark
                  ? Colors.white.withOpacity(0.04)
                  : primary.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isHighlighted
                  ? primary
                  : (isDark ? Colors.greenAccent : primary),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? primary
                    : (isDark ? Colors.white70 : Colors.grey[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnamentDivider extends StatelessWidget {
  final Color color;
  const _OrnamentDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.0), color.withOpacity(isDark ? 0.7 : 0.6)],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.7), width: 1),
            ),
            child: Container(
              width: 4.r,
              height: 4.r,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.9)),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(isDark ? 0.7 : 0.6), color.withOpacity(0.0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
