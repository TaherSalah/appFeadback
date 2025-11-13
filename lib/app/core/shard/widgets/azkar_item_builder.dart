import '../exports/all_exports.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AzkerItemBuilder extends StatefulWidget {
  final String azkarTitle;
  final String azkarDes;
  final String azkarRepate;
  final double? fontSize;
  final Color? color;

  const AzkerItemBuilder({
    super.key,
    required this.azkarTitle,
    required this.azkarDes,
    required this.azkarRepate,
    this.fontSize,
    this.color,
  });

  @override
  State<AzkerItemBuilder> createState() => _AzkerItemBuilderState();
}

class _AzkerItemBuilderState extends State<AzkerItemBuilder> {
  // دالة النسخ

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "تم نسخ الذكر بنجاح",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
    );
  }

  // دالة المشاركة
  void shareText(String text) {
    Share.share(text, subject: "${widget.azkarTitle}\n\n${widget.azkarDes}");
  }

  @override
  Widget build(BuildContext context) {
    final fullText = "${widget.azkarTitle}\n\n${widget.azkarDes}";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 14,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Column(
                  children: [
                    Text(
                      widget.azkarTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppStyle.fontFamily,
                        fontSize: widget.fontSize ?? 18.sp,
                        height: 1.8,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      widget.azkarDes,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        height: 2.3,
                        fontSize: MediaQuery.sizeOf(context).width > 600
                            ? 7.sp
                            : 11.sp,
                      ),
                    ),
                    SizedBox(height: 15.h),

                    // 🔹 صف الأزرار

                    SizedBox(height: 25.h),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔸 دائرة التكرار
        Positioned(
          bottom: -10,
          child: CircleAvatar(
            radius: 25,

            backgroundColor:
            widget.color ?? const Color(AppStyle.primaryColor),
            child: Text(
              widget.azkarRepate,
              textAlign: TextAlign.start,
              style: GoogleFonts.cairo(
                color:isDark?Colors.white: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          child:                     Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 60,
            children: [
              // زر النسخ
              GestureDetector(
                onTap: () => copyText(fullText),
                child: CircleAvatar(
                  radius: 25,
                  // backgroundColor:
                  // Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.copy,
                      color: Colors.green, size: 20),
                ),
              ),
              SizedBox(width: 15.w),
              // زر المشاركة
              GestureDetector(
                onTap: () => shareText(fullText),
                child: CircleAvatar(
                  radius: 25,

                  // radius: 18,
                  // backgroundColor:
                  // Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.share,
                      color: Colors.blue, size: 20),
                ),
              ),
            ],
          ),

        ),

      ],
    );
  }
}

