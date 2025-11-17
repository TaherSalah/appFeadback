import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';



class SleepAzkar extends StatefulWidget {
  const SleepAzkar({super.key});

  @override
  State<SleepAzkar> createState() => _SleepAzkarState();
}

class _SleepAzkarState extends State<SleepAzkar> {
  // ignore: prefer_typing_uninitialized_variables
  var selectedFontSize;



  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
          child: AppBar(
            leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,),
            centerTitle: true,
            title: Text(
              AppString.KSleep,
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                  MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        // backgroundColor: Azkary.azkarMassaRepate.isEmpty? Colors.white :        AppStyle.bgColors,
        body:  Azkary.azkarSleepRepate.isEmpty? Center(
          child:  SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Image.asset(
                      doneZakar,
                    )),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  AppString.KSleepDaialogText,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  AppString.KZakarSleepFeaturesTitle,
                  style: GoogleFonts.cairo(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp),
                ),
                SizedBox(
                  height: 10.h,
                ),
                const Divider(
                  color: Color(AppStyle.primaryColor),
                  thickness: 2,
                  indent: 150,
                  endIndent: 150,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    AppString.KZakarSleepFeaturesDes,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontFamily: AppStyle.fontFamily,
                        height: 1.8.h,
                        fontSize: 17.5.sp),
                  ),
                )
              ],
            ),
          ),
        ) :  Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0.w),
            ),
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, zSleepIndex) {
                    return ScrollAppearAnimation(
                      duration: const Duration(milliseconds: 700),
                      child: GestureDetector(
                        onTap: () {
                          con.decrementSleep(zSleepIndex);
                        },
                        child: AzkerItemBuilder(
                          azkarTitle: Azkary.azkarSleep[zSleepIndex],
                          azkarDes: Azkary.azkarSleepDes[zSleepIndex],
                          fontSize: fontSize,
                          azkarRepate: con.zSleepIndex >=
                                  Azkary.azkarSleepRepate[zSleepIndex]
                              ? '0'
                              : '${Azkary.azkarSleepRepate[zSleepIndex]}',
                          color: con.zSleepIndex >=
                                  Azkary.azkarSleepRepate[zSleepIndex]
                              ? const Color(AppStyle.yellowColor)
                              : isDark?Colors.black: Color(AppStyle.whiteColor),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, zSleepIndex) => SizedBox(
                        height: 15.h,
                      ),
                  itemCount: Azkary.azkarSleep.length),
            )
          ],
        ));
  }
}
