import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';

import '../../../core/shard/constanc/app_string.dart';
import '../../../core/utils/style/responsive_util.dart';

class Allazkarlistview extends StatelessWidget {
  const Allazkarlistview({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> iconsApp = [
      {
        "title": AppString.KSleep,
        "icon": "assets/images/sleep.png",
        "navigate": "/sleepAzkar",
      },
      {
        "title": AppString.KPrayer,
        "icon": "assets/images/prayer-mat.png",
        "navigate": "/prayerAzkar",
      },
      {
        "title": AppString.KRokia,
        "icon": "assets/images/tasbih.png",
        "navigate": "/rokiaScreen",
      },
      {
        "title": AppString.KOtherZakar,
        "icon": "assets/images/praying.png",
        "navigate": "/azkarOthers",
      },
    ];
    bool isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
        child: AppBar(
          leading:  CupertinoNavigationBarBackButton(
            color: isDark?Colors.white: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "أذكار متنوعة",
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                  child: SizedBox(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: isTab ? 30 : 15,
                      mainAxisSpacing: isTab ? 20 : 25,
                      childAspectRatio: isTab ? 2.9 : 01.80,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // عشان المكون يكون جزء من ScrollView تانية
                      children: iconsApp.map((item) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, item['navigate']!);
                          },
                          // child: Card(
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(10),
                          //     side: const BorderSide(
                          //         color: Colors.grey, width: 1),
                          //   ),
                          //   child: SizedBox(
                          //     width: 90,
                          //     height: 75,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Column(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           Image.asset(
                          //             item["icon"]!,
                          //             width: 90,
                          //             height: 75,
                          //             fit: BoxFit.contain,
                          //           ),
                          //           const SizedBox(height: 8),
                          //           TextDefaultWidget(title:item["title"]! ,fontFamily: "me",fontSize: ResponsiveUtil.isTablet(context)? 11.sp : 11.5.sp,fontWeight: ResponsiveUtil.isTablet(context)?FontWeight.w500: FontWeight.bold,)
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          child: IslamicCardWidget(
                              title: item["title"]!, iconPath: item["icon"]!),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
