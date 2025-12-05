// import '../exports/all_exports.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// class AzkerItemBuilder extends StatefulWidget {
//   final String azkarTitle;
//   final String azkarDes;
//   final String azkarRepate;
//   final double? fontSize;
//   final Color? color;
//
//   const AzkerItemBuilder({
//     super.key,
//     required this.azkarTitle,
//     required this.azkarDes,
//     required this.azkarRepate,
//     this.fontSize,
//     this.color,
//   });
//
//   @override
//   State<AzkerItemBuilder> createState() => _AzkerItemBuilderState();
// }
//
// class _AzkerItemBuilderState extends State<AzkerItemBuilder> {
//   void copyText(String text) async {
//     await Clipboard.setData(ClipboardData(text: text));
//     Fluttertoast.showToast(
//       msg: "تم نسخ الذكر بنجاح",
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green.shade600,
//       textColor: Colors.white,
//     );
//   }
//
//   void shareText(String text) {
//     Share.share(
//       text,
//       subject: widget.azkarTitle,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final fullText = "${widget.azkarTitle}\n\n${widget.azkarDes}";
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.sizeOf(context);
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: [
//           // الكارت الأساسي
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24.r),
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: isDark
//                     ? [
//                   const Color(0xFF020617),
//                   const Color(0xFF0F172A),
//                 ]
//                     : [
//                   const Color(0xFFF4FDF8),
//                   const Color(0xFFE0F5EA),
//                 ],
//               ),
//               border: Border.all(
//                 color: (widget.color ?? const Color(AppStyle.primaryColor))
//                     .withOpacity(0.4),
//                 width: 1.2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: (widget.color ?? const Color(AppStyle.primaryColor))
//                       .withOpacity(0.25),
//                   blurRadius: 18,
//                   spreadRadius: 1,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 32.h),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // العنوان مع أيقونة بسيطة
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.stars_rounded,
//                         size: 18.sp,
//                         color: (widget.color ??
//                             const Color(AppStyle.primaryColor))
//                             .withOpacity(0.8),
//                       ),
//                       SizedBox(width: 6.w),
//                       Flexible(
//                         child: Text(
//                           widget.azkarTitle,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: AppStyle.fontFamily,
//                             fontSize: widget.fontSize ?? 18.sp,
//                             height: 1.6,
//                             fontWeight: FontWeight.w700,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 6.w),
//                       Icon(
//                         Icons.stars_rounded,
//                         size: 18.sp,
//                         color: Colors.transparent, // للمحافظة على التماثل
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: 10.h),
//
//                   // نص الذكر
//                   Text(
//                     widget.azkarDes,
//                     textAlign: TextAlign.center,
//                     textDirection: TextDirection.rtl,
//                     style: GoogleFonts.cairo(
//                       height: 1.9,
//                       fontSize: size.width > 600 ? 9.sp : 13.sp,
//                       color: isDark ? Colors.grey[200] : Colors.grey[900],
//                     ),
//                   ),
//
//                   SizedBox(height: 18.h),
//
//                   // شريط الأزرار
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // زر النسخ
//                       _AzkarActionButton(
//                         icon: Icons.copy_rounded,
//                         label: "نسخ",
//                         onTap: () => copyText(fullText),
//                       ),
//
//                       // فاصل خفيف في المنتصف
//                       Container(
//                         width: 1,
//                         height: 24.h,
//                         color: (isDark ? Colors.white70 : Colors.black26)
//                             .withOpacity(0.3),
//                       ),
//
//                       // زر المشاركة
//                       _AzkarActionButton(
//                         icon: Icons.share_rounded,
//                         label: "مشاركة",
//                         onTap: () => shareText(fullText),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // دائرة عدد التكرار (تحت الكارت)
//           Positioned(
//             bottom: -20.h,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: widget.color ??
//                     (isDark
//                         ? const Color(AppStyle.primaryColor)
//                         : const Color(AppStyle.primaryColor)),
//                 borderRadius: BorderRadius.circular(40.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: (widget.color ??
//                         const Color(AppStyle.primaryColor))
//                         .withOpacity(0.45),
//                     blurRadius: 14,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 18.sp,
//                     color: Colors.white,
//                   ),
//                   SizedBox(width: 6.w),
//                   Text(
//                     widget.azkarRepate,
//                     style: GoogleFonts.cairo(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AzkarActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   const _AzkarActionButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return InkWell(
//       borderRadius: BorderRadius.circular(30.r),
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30.r),
//           color: isDark
//               ? Colors.white.withOpacity(0.04)
//               : Colors.black.withOpacity(0.02),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 18.sp,
//               color: isDark ? Colors.greenAccent : Colors.green.shade700,
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               label,
//               style: GoogleFonts.cairo(
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.white70 : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import '../exports/all_exports.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

// تأكد أن AppStyle / Azkary / ScrollAppearAnimation / con موجودين عندك في المشروع

class AzkerItemBuilder extends StatefulWidget {
  final String azkarTitle;
  final String azkarDes;
  final String azkarRepate;
  final double? fontSize;
  final Color? color;
  final Color? repertColor;
  final Color? repertColor2;

  const AzkerItemBuilder({
    super.key,
    required this.azkarTitle,
    required this.azkarDes,
    required this.azkarRepate,
    this.fontSize,
    this.color,
    this.repertColor,
    this.repertColor2,
  });

  @override
  State<AzkerItemBuilder> createState() => _AzkerItemBuilderState();
}

class _AzkerItemBuilderState extends State<AzkerItemBuilder> {
  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "تم نسخ الذكر بنجاح",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  void shareText(String text) {
    Share.share(
      text,
      subject: widget.azkarTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullText = "${widget.azkarTitle}\n\n${widget.azkarDes}";
    final shareFullTextFancy = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 *${fullText}*

🌿✨🌸✨🌿✨🌸✨🌿✨

💫 من تطبيق *رفيق المسلم اليومي* 💫  
حمل التطبيق الآن واستفد من كل الذكر اليومي:

📱 **Play Google للاندرويد:**  
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

📱 **App Gallery هواوي:**  
➡️ https://appgallery.huawei.com/app/C114956477

📱 **App Store للايفون:**  
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 شارك هذا الذكر مع أصدقائك لتعمّ الفائدة 🌟

🌺✨🌿✨🌺✨🌿✨🌺✨🌿
""";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final baseColor = widget.color ?? const Color(AppStyle.primaryColor);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // الكارت الأساسي
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
                        // baseColor.withOpacity(0.06), // لمسة لون خفيفة
                        Color(0xFFF7F1E1),
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
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان مع أيقونة بسيطة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 18.sp,
                        color: baseColor.withOpacity(0.8),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          widget.azkarTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppStyle.fontFamily,
                            fontSize: widget.fontSize ?? 18.sp,
                            height: 1.6,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.transparent, // للمحافظة على التماثل
                      ),
                    ],
                  ),

                  // الفاصل الزخرفي تحت العنوان
                  _AzkarOrnamentDivider(
                    color: baseColor,
                  ),

                  SizedBox(height: 6.h),

                  // نص الذكر
                  Text(
                    widget.azkarDes,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(
                      height: 1.9,
                      fontSize: size.width > 600 ? 9.sp : 13.sp,
                      color: isDark ? Colors.grey[200] : Colors.grey[900],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // شريط الأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر النسخ
                      _AzkarActionButton(
                        icon: Icons.copy_rounded,
                        label: "نسخ",
                        onTap: () => copyText(shareFullTextFancy),
                      ),

                      // فاصل خفيف في المنتصف
                      Container(
                        width: 1,
                        height: 24.h,
                        color: (isDark ? Colors.white70 : Colors.black26)
                            .withOpacity(0.3),
                      ),

                      // زر المشاركة
                      _AzkarActionButton(
                        icon: Icons.share_rounded,
                        label: "مشاركة",
                        onTap: () {
//                           final shareFullTextDecorated = """
// 🌸🌿🌸🌿🌸🌿🌸🌿🌸
//
// 📿 *${fullText}*
//
// 🌿🌸🌿🌸🌿🌸🌿🌸🌿
//
// ✨ من تطبيق *رفيق المسلم اليومي* 📱
// حمل التطبيق الآن:
//
// 📲 **Android:**
// https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily
//
// 📲 **Huawei AppGallery:**
// https://appgallery.huawei.com/app/C114956477
//
// 📲 **iOS App Store:**
// https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338
//
// 🌟 شارك هذا الذكر مع أصدقائك ليعمّ الخير 🌟
//
// 🌸🌿🌸🌿🌸🌿🌸🌿🌸
// """;



                          shareText(shareFullTextFancy);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // كبسولة عدد التكرار (تحت الكارت)
          Positioned(
            bottom: -15.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: widget.repertColor2 ??
                    (isDark
                        ? const Color(0xFF020617)
                        : baseColor.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: [
                  BoxShadow(
                    color: (widget.repertColor2 ?? baseColor).withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 18.sp,
                    color: widget.repertColor ??
                        (isDark ? Colors.white : Colors.black87),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    widget.azkarRepate,
                    style: GoogleFonts.cairo(
                      color: widget.repertColor ??
                          (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AzkarActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AzkarActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(30.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : primary.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isDark ? Colors.greenAccent : primary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AzkarOrnamentDivider extends StatelessWidget {
  final Color color;

  const _AzkarOrnamentDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      child: Row(
        children: [
          // خط يسار
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    color.withOpacity(0.0),
                    color.withOpacity(isDark ? 0.7 : 0.6),
                  ],
                ),
              ),
            ),
          ),

          // دائرة مزخرفة في المنتصف
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.9),
              ),
            ),
          ),

          // خط يمين
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    color.withOpacity(0.0),
                    color.withOpacity(isDark ? 0.7 : 0.6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class AzkerItemBuilder extends StatefulWidget {
//   final String azkarTitle;
//   final String azkarDes;
//   final String azkarRepate;
//   final double? fontSize;
//   final Color? color,repertColor,repertColor2;
//
//   const AzkerItemBuilder({
//     super.key,
//     required this.azkarTitle,
//     required this.azkarDes,
//     required this.azkarRepate,
//     this.fontSize,
//     this.color, this.repertColor, this.repertColor2,
//   });
//
//   @override
//   State<AzkerItemBuilder> createState() => _AzkerItemBuilderState();
// }
//
// class _AzkerItemBuilderState extends State<AzkerItemBuilder> {
//   void copyText(String text) async {
//     await Clipboard.setData(ClipboardData(text: text));
//     Fluttertoast.showToast(
//       msg: "تم نسخ الذكر بنجاح",
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green.shade600,
//       textColor: Colors.white,
//     );
//   }
//
//   void shareText(String text) {
//     Share.share(
//       text,
//       subject: widget.azkarTitle,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final fullText = "${widget.azkarTitle}\n\n${widget.azkarDes}";
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.sizeOf(context);
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: [
//           // الكارت الأساسي
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(24.r),
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: isDark
//                     ? [
//                   const Color(0xFF020617),
//                   const Color(0xFF0F172A),
//                 ]
//                     : [
//                   const Color(0xFFF4FDF8),
//                   const Color(0xFFFFFFFF),
//                 ],
//               ),
//               border: Border.all(
//                 color: (widget.color ?? const Color(AppStyle.primaryColor))
//                     .withOpacity(0.4),
//                 width: 1.2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: (widget.color ?? const Color(AppStyle.primaryColor))
//                       .withOpacity(0.25),
//                   blurRadius: 18,
//                   spreadRadius: 1,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 32.h),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // العنوان مع أيقونة بسيطة
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.stars_rounded,
//                         size: 18.sp,
//                         color: (widget.color ??
//                             const Color(AppStyle.primaryColor))
//                             .withOpacity(0.8),
//                       ),
//                       SizedBox(width: 6.w),
//                       Flexible(
//                         child: Text(
//                           widget.azkarTitle,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: AppStyle.fontFamily,
//                             fontSize: widget.fontSize ?? 18.sp,
//                             height: 1.6,
//                             fontWeight: FontWeight.w700,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 6.w),
//                       Icon(
//                         Icons.stars_rounded,
//                         size: 18.sp,
//                         color: Colors.transparent, // للمحافظة على التماثل
//                       ),
//                     ],
//                   ),
//
//                   // الفاصل الزخرفي تحت العنوان
//                   _AzkarOrnamentDivider(
//                     color: widget.color ?? const Color(AppStyle.primaryColor),
//                   ),
//
//                   SizedBox(height: 6.h),
//
//                   // نص الذكر
//                   Text(
//                     widget.azkarDes,
//                     textAlign: TextAlign.center,
//                     textDirection: TextDirection.rtl,
//                     style: GoogleFonts.cairo(
//                       height: 1.9,
//                       fontSize: size.width > 600 ? 9.sp : 13.sp,
//                       color: isDark ? Colors.grey[200] : Colors.grey[900],
//                     ),
//                   ),
//
//                   SizedBox(height: 18.h),
//
//                   // شريط الأزرار
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // زر النسخ
//                       _AzkarActionButton(
//                         icon: Icons.copy_rounded,
//                         label: "نسخ",
//                         onTap: () => copyText(fullText),
//                       ),
//
//                       // فاصل خفيف في المنتصف
//                       Container(
//                         width: 1,
//                         height: 24.h,
//                         color: (isDark ? Colors.white70 : Colors.black26)
//                             .withOpacity(0.3),
//                       ),
//
//                       // زر المشاركة
//                       _AzkarActionButton(
//                         icon: Icons.share_rounded,
//                         label: "مشاركة",
//
//                         onTap: () => shareText(fullText),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // كبسولة عدد التكرار (تحت الكارت)
//           Positioned(
//             bottom: -20.h,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
//               decoration: BoxDecoration(
//                 color: widget.repertColor2 ??
//                     (isDark
//                         ? Colors.black
//                         : Theme.of(context).cardColor),
//                 borderRadius: BorderRadius.circular(40.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color:
//                     (widget.repertColor2 ?? Colors.amberAccent)
//                         .withOpacity(0.45),
//                     blurRadius: 14,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.repeat_rounded,
//                     size: 18.sp,
//                     color: widget.repertColor,
//                   ),
//                   SizedBox(width: 6.w),
//                   Text(
//                     widget.azkarRepate,
//                     style: GoogleFonts.cairo(
//                       color: widget.repertColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AzkarActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//
//   const _AzkarActionButton({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return InkWell(
//       borderRadius: BorderRadius.circular(30.r),
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30.r),
//           color: isDark
//               ? Colors.white.withOpacity(0.04)
//               : Colors.black.withOpacity(0.02),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               size: 18.sp,
//               color: isDark ? Colors.greenAccent : Colors.green.shade700,
//             ),
//             SizedBox(width: 6.w),
//             Text(
//               label,
//               style: GoogleFonts.cairo(
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.white70 : Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _AzkarOrnamentDivider extends StatelessWidget {
//   final Color color;
//
//   const _AzkarOrnamentDivider({required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
//       child: Row(
//         children: [
//           // خط يسار
//           Expanded(
//             child: Container(
//               height: 1,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.centerRight,
//                   end: Alignment.centerLeft,
//                   colors: [
//                     color.withOpacity(0.0),
//                     color.withOpacity(isDark ? 0.7 : 0.6),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // دائرة مزخرفة في المنتصف
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 8.w),
//             padding: EdgeInsets.all(4.r),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: color.withOpacity(0.7),
//                 width: 1,
//               ),
//             ),
//             child: Container(
//               width: 6.r,
//               height: 6.r,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: color.withOpacity(0.9),
//               ),
//             ),
//           ),
//
//           // خط يمين
//           Expanded(
//             child: Container(
//               height: 1,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                   colors: [
//                     color.withOpacity(0.0),
//                     color.withOpacity(isDark ? 0.7 : 0.6),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
