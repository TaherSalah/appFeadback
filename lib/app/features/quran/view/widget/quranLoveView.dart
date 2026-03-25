import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/utils/constent/quranLove.dart';

// class QuranLoveView extends StatelessWidget {
//   const QuranLoveView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     String quranLoveReg = quranLove.replaceAllMapped(
//       RegExp(r"\(\((.*?)\)\)"),
//           (match) => "(${match.group(1)})",
//     );
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         // backgroundColor: AppStyle.bgColors,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
//           child: AppBar(
//
//             leading:  CupertinoNavigationBarBackButton(color:   context.isDark
//                 ? Colors.white
//                 : Colors.black,),
//             centerTitle: true,
//
//
//             title:   Text(
//               "فضل قرأة القران الكريم",
//               style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
//             ),
//
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: context.isTab?12.w:20.w),
//             child: Column(
//               children: [
//                 Text(quranLoveReg,textAlign: TextAlign.justify,style: TextStyle(fontSize: 22.sp,fontFamily: "maja"),)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class QuranKhitamView extends StatelessWidget {
//   const QuranKhitamView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         // backgroundColor: AppStyle.bgColors,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
//           child: AppBar(
//
//             leading:  CupertinoNavigationBarBackButton(color:   context.isDark
//                 ? Colors.white
//                 : Colors.black,),
//             centerTitle: true,
//
//
//             title:   Text(
//               "دعاء ختم القرآن الكريم",
//               style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
//             ),
//
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: context.isTab?12.w:20.w),
//             child: Column(
//               children: [
//                 Text(quranKhatem.replaceAll("۞", ""),textAlign: TextAlign.justify,style: TextStyle(fontSize: 22.sp,fontFamily: "maja"),)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

/// شاشة أساسية لعرض النصوص (فضل، دعاء، …) بشكل أنيق ومريح
class QuranTextScreen extends StatelessWidget {
  final String title;
  final String text, bottomText;
  final double fontSize;
  final bool showBasmala;

  const QuranTextScreen({
    super.key,
    required this.title,
    required this.text,
    this.fontSize = 16,
    this.showBasmala = false,
    required this.bottomText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "دعاء ختم القرآن الكريم",
              style: TextStyle(
                  fontFamily: "cairo",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF05080F), Color(0xFF0D1118)]
                  : const [Color(0xFFe0f2f1), Color(0xFFf1f8e9)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 20.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141820)
                          : const Color(0xFFFEFBF3),
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: (isDark ? AppStyle.scondColors : Colors.blue)
                            .withOpacity(0.18),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // عنوان داخلي بسيط + خط زخرفي
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Container(
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: 10.w,
                        //         vertical: 4.h,
                        //       ),
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(20.r),
                        //         color: (isDark
                        //             ? AppStyle.scondColors
                        //             : Colors.blue)
                        //             .withOpacity(0.12),
                        //       ),
                        //       child: Text(
                        //         headText,
                        //         style: GoogleFonts.cairo(
                        //           fontSize: 11.sp,
                        //           fontWeight: FontWeight.w600,
                        //           color: isDark
                        //               ? Colors.white70
                        //               : Colors.black87,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 14.h),

                        if (showBasmala) ...[
                          Center(
                            child: Text(
                              "﷽",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "cairo",
                                fontSize: 24.sp,
                                height: 1.4,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Center(
                            child: Container(
                              width: 55.w,
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  colors: [
                                    (isDark
                                            ? AppStyle.scondColors
                                            : Colors.blue)
                                        .withOpacity(0.3),
                                    (isDark
                                        ? AppStyle.scondColors
                                        : Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // النص الأساسي قابل للتحديد
                        SelectableText(
                          text,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: "cairo",
                            fontSize: fontSize.sp,
                            height: 1.8,
                            color: isDark
                                ? Colors.white.withOpacity(0.95)
                                : Colors.black87,
                          ),
                        ),

                        SizedBox(height: 18.h),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            bottomText,
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  (isDark ? AppStyle.scondColors : Colors.blue)
                                      .withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// فضل قراءة القرآن الكريم
class QuranLoveView extends StatelessWidget {
  const QuranLoveView({super.key});

  String _normalizeDoubleParentheses(String source) {
    // استبدال ((النص)) بـ (النص)
    return source.replaceAllMapped(
      RegExp(r"\(\((.*?)\)\)"),
      (match) => "(${match.group(1)})",
    );
  }

  @override
  Widget build(BuildContext context) {
    final String quranLoveReg = _normalizeDoubleParentheses(quranLove);

    return QuranTextScreen(
      bottomText: "وصل وسلم وبارك على سيدنا محمد",
      title: "فضل قراءة القرآن الكريم",
      text: quranLoveReg,
      fontSize: 14,
      showBasmala: false,
    );
  }
}

/// دعاء ختم القرآن الكريم
class QuranKhitamView extends StatelessWidget {
  const QuranKhitamView({super.key});

  @override
  Widget build(BuildContext context) {
    final String khitamText = quranKhatem.replaceAll("۞", "");

    return QuranTextScreen(
      bottomText: "وصل وسلم وبارك على سيدنا محمد",
      title: "دعاء ختم القرآن الكريم",
      text: khitamText,
      fontSize: 15,
      showBasmala: true,
    );
  }
}
