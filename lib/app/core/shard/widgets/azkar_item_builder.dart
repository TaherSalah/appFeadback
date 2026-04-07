import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/features/shareCard/PremiumShareCard.dart';
import 'package:share_plus/share_plus.dart';

import '../exports/all_exports.dart';
import 'AzkarActionButton.dart';
import 'AzkarOrnamentDivider.dart';

// تأكد أن AppStyle / Azkary / ScrollAppearAnimation / con موجودين عندك في المشروع

class AzkerItemBuilder extends StatefulWidget {
  final String azkarTitle;
  final String? azkarName;
  final String azkarDes;
  final String azkarRepate;
  final double? fontSize;
  final Color? color;
  final Color? repertColor;
  final Color? repertColor2;
  final String? fontFamily;
  final bool isOther;
  const AzkerItemBuilder({
    super.key,
    required this.azkarTitle,
    required this.azkarDes,
    required this.azkarRepate,
    this.fontSize,
    this.color,
    this.repertColor,
    this.repertColor2,
    this.azkarName,
    this.fontFamily,
    this.isOther = false,
  });

  @override
  State<AzkerItemBuilder> createState() => _AzkerItemBuilderState();
}

class _AzkerItemBuilderState extends State<AzkerItemBuilder> {
  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Fluttertoast.showToast(
    //   msg: "تم نسخ الذكر بنجاح",
    //   gravity: ToastGravity.BOTTOM,
    //   backgroundColor: Colors.green.shade600,
    //   textColor: Colors.white,
    // );
    KHelper.showSuccess(message: "تم نسخ الذكر بنجاح");
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

📿 *$fullText*

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
    final isDark = context.isDark;
    final size = MediaQuery.sizeOf(context);
    final baseColor = widget.color ?? const Color(AppStyle.primaryColor);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // الكارت الأساسي
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
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
                            style: GoogleFonts.amiri(
                              fontSize: widget.fontSize ?? 18.sp,
                              height: 2.0,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ), // style: TextStyle(
                            //   fontFamily: "cairo",
                            //   fontSize: widget.fontSize ?? 18.sp,
                            //   height: 1.6,
                            //   fontWeight: FontWeight.w700,
                            //   color: isDark ? Colors.white : Colors.black87,
                            // ),
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
                    AzkarOrnamentDivider(
                      color: baseColor,
                    ),

                    SizedBox(height: 6.h),

                    // نص الذكر
                    Text(
                      widget.azkarDes,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: widget.isOther == true
                          ? GoogleFonts.amiri(
                              fontSize: widget.fontSize ?? 18.sp,
                              height: 2.0,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            )
                          : TextStyle(
                              fontFamily: widget.fontFamily ?? "cairo",
                              height: 1.9,
                              fontSize: size.width > 600 ? 9.sp : 13.sp,
                              color:
                                  isDark ? Colors.grey[200] : Colors.grey[900],
                            ),
                    ),

                    SizedBox(height: 18.h),

                    // شريط الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر النسخ
                        AzkarActionButton(
                          icon: Icons.copy_rounded,
                          label: "نسخ",
                          onTap: () => copyText(shareFullTextFancy),
                        ),

                        // زر مشاركة الصورة
                        AzkarActionButton(
                          icon: Icons.image_outlined,
                          label: "صورة",
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              pageBuilder: (context, anim1, anim2) =>
                                  PremiumShareCard(
                                azkarName: widget.azkarName ?? "",
                                text: widget.azkarTitle,
                                source: widget.azkarDes,
                              ),
                            );
                          },
                        ),

                        // زر المشاركة
                        AzkarActionButton(
                          icon: Icons.share_rounded,
                          label: "مشاركة",
                          onTap: () {
                            shareText(shareFullTextFancy);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // كبسولة عدد التكرار (تحت الكارت)
          Positioned(
            bottom: context.isTab ? -20.h : -15.h,
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
                    size: context.isTab ? 15.sp : 18.sp,
                    color: widget.repertColor ??
                        (isDark ? Colors.white : Colors.black87),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    widget.azkarRepate,
                    style: TextStyle(
                      fontFamily: "cairo",
                      color: widget.repertColor ??
                          (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: context.isTab ? 9.sp : 13.sp,
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


