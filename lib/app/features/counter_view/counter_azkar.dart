
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/shard/constanc/app_string.dart';
import '../../core/shard/exports/all_exports.dart';






class AzkarCounter extends StatefulWidget {
  const AzkarCounter({super.key});

  @override
  State<AzkarCounter> createState() => _AzkarCounterState();
}

class _AzkarCounterState extends State<AzkarCounter> {



  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.sizeOf(context).width>600? 80:50),
            child: AppBar(
              leading: const CupertinoNavigationBarBackButton(color: Colors.black,),
              centerTitle: true,
              title: Text(
                AppString.KCounter,
                style: GoogleFonts.cairo(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
              ),
            ),
          ),
      
          body: const CounterWidgetBuilder()),
    );
  }
}
