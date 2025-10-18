

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/shard/constanc/app_string.dart';
import '../../core/shard/constanc/app_style.dart';
import '../../core/shard/widgets/about_item_builder.dart';




class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 70:50),
        child: AppBar(
          leading:CupertinoNavigationBarBackButton(color:   Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,),
          centerTitle: true,
          title: Text(
            AppString.KAbout,
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),

      // backgroundColor: AppStyle.bgColors,
      body: const SingleChildScrollView(
          physics: BouncingScrollPhysics(), child: AboutItemBuilder()),
    );
  }
}