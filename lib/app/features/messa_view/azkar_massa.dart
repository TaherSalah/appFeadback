import 'dart:ui' as ui;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';




class AzkarMassa extends StatefulWidget {
  const AzkarMassa({super.key});

  @override
  State<AzkarMassa> createState() => _AzkarMassaState();
}

class _AzkarMassaState extends State<AzkarMassa> {
  // var selectedFontSize;


  @override
  Widget build(BuildContext context) {
    final con =Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
          child: AppBar(

            leading:  CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,),
            centerTitle: true,

            title:   Text(
              AppString.KMessa,
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
            ),

          ),
        ),

        // backgroundColor: Colors.black.withOpacity(0.1),
        // backgroundColor: Azkary.azkarMassaRepate.isEmpty? Colors.white :        AppStyle.bgColors
      // ,
        body:Azkary.azkarMassaRepate.isEmpty? Center(
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
                  AppString.KMessaDaialogText,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 15.sp),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Text(
                  AppString.KZakarMessaFeaturesTitle,
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
                    AppString.doneText,
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
                  itemBuilder: (context, zMessaIndex) {
                    return ScrollAppearAnimation(
                      duration: const Duration(milliseconds: 700),
                      child: GestureDetector(
                        onTap: () {
                         con.decrementMessa(zMessaIndex);
                        },
                        child: AzkerItemBuilder(
                            azkarTitle: Azkary.azkarMassa[zMessaIndex],
                            azkarDes: Azkary.azkarMassaDes[zMessaIndex],
                            fontSize: fontSize,
                            azkarRepate: con.zMessaIndex >= Azkary.azkarMassaRepate[zMessaIndex]?'0':'${Azkary.azkarMassaRepate[zMessaIndex]}',
                          color: con.zMessaIndex >= Azkary.azkarMassaRepate[zMessaIndex]?  const Color(AppStyle.yellowColor):isDark?Colors.black: Color(AppStyle.whiteColor),

                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, zMessaIndex) => SizedBox(
                        height: 15.h,
                      ),
                  itemCount: Azkary.azkarMassa.length),
            )
          ],
        ));
  }
}
