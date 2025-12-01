import 'dart:ui' as ui;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/utils/style/k_color.dart';
import '../sleep_view/sleep_azkar.dart';


class PrayerAzkar extends StatefulWidget {
  const PrayerAzkar({super.key});

  @override
  State<PrayerAzkar> createState() => _PrayerAzkarState();
}

class _PrayerAzkarState extends State<PrayerAzkar> {
  var selectedFontSize;

  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    // منطق الانتهاء من كل أذكار ما بعد الصلاة
    final bool allDone = con.isPrayerDone;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),
        child: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة العداد',
              onPressed: con.resetPrayer,
            ),
          ],

          leading: CupertinoNavigationBarBackButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            AppString.KPrayer,
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize:
              MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),

      body: allDone
          ? DoneDialogWidget(
        onPressedRepeat: con.resetPrayer,
        doneText: AppString.KZakarPrayerFeaturesDes,
        KZakarFeaturesTitle: AppString.KPrayerDaialogText,
        KDaialogText: AppString.KZakarPrayerFeaturesTitle,
      )
      // قائمة أذكار ما بعد الصلاة
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.w),
          ),
          Expanded(
            child: ListView.separated(

              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, zPrayerIndex) {
                // الذكر خلص لما عدّاده <= 0
                final bool isDone =
                    Azkary.azkarPrayerRepate[zPrayerIndex] <= 0;

                final Color cardColor = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDark
                    ? Colors.black
                    : const Color(AppStyle.whiteColor));


                final Color primaryColorLocal =
                const Color(AppStyle.primaryColor);

                final Color cardAccent = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDark
                    ? Colors.black
                    : primaryColorLocal);

                final Color chipBg = isDone
                    ? const Color(AppStyle.yellowColor)
                    : (isDark
                    ? Colors.black
                    : const Color(0xFFECFDF3));

                final Color chipText = isDone
                    ? Colors.black
                    : (isDark
                    ? Colors.white
                    : KColors.primaryColor);

                return ScrollAppearAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: GestureDetector(
                    onTap: () {
                      con.decrementPrayer(zPrayerIndex);
                    },
                    child: AzkerItemBuilder(
                      azkarTitle: Azkary.azkarPrayer[zPrayerIndex],
                      azkarDes: Azkary.azkarPrayerDes[zPrayerIndex],
                      fontSize: fontSize,
                      azkarRepate: isDone
                          ? '0'
                          : '${Azkary.azkarPrayerRepate[zPrayerIndex]}',
                      color: cardAccent,
                      repertColor: chipText,
                      repertColor2: chipBg,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, zPrayerIndex) =>
                  SizedBox(height: 15.h),
              itemCount: Azkary.azkarPrayer.length,
            ),
          ),
        ],
      ),
    );
  }
}


// class PrayerAzkar extends StatefulWidget {
//   const PrayerAzkar({super.key});
//
//   @override
//   State<PrayerAzkar> createState() => _PrayerAzkarState();
// }
//
// class _PrayerAzkarState extends State<PrayerAzkar> {
//
//   var selectedFontSize;
//
//
//   @override
//   Widget build(BuildContext context) {
//     final con = Provider.of<AzkarProvider>(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final double fontSize = CentralizedCubit.get(context).azkarFontSize();
//
//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
//           child: AppBar(
//
//             leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white
//                 : Colors.black,),
//             centerTitle: true,
//
//             title:   Text(
//               AppString.KPrayer,
//               style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
//             ),
//
//           ),
//         ),
//
//         // backgroundColor: Azkary.azkarMassaRepate.isEmpty? Colors.white :        AppStyle.bgColors,
//         body:Azkary.azkarPrayerRepate.isEmpty? Center(
//           child:  SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                     child: Image.asset(
//                       doneZakar,
//                     )),
//                 SizedBox(
//                   height: 10.h,
//                 ),
//                 Text(
//                   AppString.KPrayerDaialogText,
//                   style: GoogleFonts.cairo(
//                       fontWeight: FontWeight.bold, fontSize: 15.sp),
//                 ),
//                 SizedBox(
//                   height: 15.h,
//                 ),
//                 Text(
//                   AppString.KZakarPrayerFeaturesTitle,
//                   style: GoogleFonts.cairo(
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18.sp),
//                 ),
//                 SizedBox(
//                   height: 10.h,
//                 ),
//                 const Divider(
//                   color: Color(AppStyle.primaryColor),
//                   thickness: 2,
//                   indent: 150,
//                   endIndent: 150,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Text(
//                     AppString.KZakarPrayerFeaturesDes,
//                     textAlign: TextAlign.justify,
//                     style: TextStyle(
//                         fontFamily: AppStyle.fontFamily,
//                         height: 1.8.h,
//                         fontSize: 17.5.sp),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ) :  Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.0.w),
//             ),
//             Expanded(
//               child: ListView.separated(
//                   physics: const BouncingScrollPhysics(),
//                   itemBuilder: (context, zPrayerIndex) {
//                     return ScrollAppearAnimation(
//                       duration: const Duration(milliseconds: 700),
//                       child: GestureDetector(
//                         onTap: () {
//                           con.decrementPrayer(zPrayerIndex);
//
//                           // navigate(context, PrayerCounter(
//                           //     azkarConten: Azkary.azkarPrayer[index],
//                           //     azkarContenDes: Azkary.azkarPrayerDes[index],
//                           //     azkarContenRepate: '${Azkary.azkarPrayerRepate[index]}'));
//                         },
//                         child: AzkerItemBuilder(
//                           azkarTitle: Azkary.azkarPrayer[zPrayerIndex],
//                           azkarDes: Azkary.azkarPrayerDes[zPrayerIndex],
//                           fontSize: fontSize,
//                           azkarRepate: con.zPrayerIndex >=
//                                   Azkary.azkarPrayerRepate[zPrayerIndex]
//                               ? '0'
//                               : '${Azkary.azkarPrayerRepate[zPrayerIndex]}',
//                           color: con.zPrayerIndex >=
//                                   Azkary.azkarPrayerRepate[zPrayerIndex]
//                               ? const Color(AppStyle.yellowColor)
//                               : isDark?Colors.black: Color(AppStyle.whiteColor),
//                         ),
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, zPrayerIndex) => SizedBox(
//                         height: 15.h,
//                       ),
//                   itemCount: Azkary.azkarPrayer.length),
//             )
//           ],
//         ));
//   }
// }
