import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_style.dart';
import 'package:muslimdaily/app/core/utils/constent/quranLove.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:flutter/cupertino.dart';

class QuranLoveView extends StatelessWidget {
  const QuranLoveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 80:50),
          child: AppBar(

            leading:  CupertinoNavigationBarBackButton(color: Colors.black,),
            centerTitle: true,


            title:   Text(
              "فضل قرأة القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
            ),

          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                Text(quranLove,textAlign: TextAlign.justify,style: TextStyle(fontSize: 14.sp),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuranKhitamView extends StatelessWidget {
  const QuranKhitamView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 80:50),
          child: AppBar(

            leading:  CupertinoNavigationBarBackButton(color: Colors.black,),
            centerTitle: true,


            title:   Text(
              "دعاء ختم القرآن الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.sizeOf(context).width >600?12.sp: 18.sp),
            ),

          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                Text(quranKhatem.replaceAll("۞", ""),textAlign: TextAlign.justify,style: TextStyle(fontSize: 15.sp),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
