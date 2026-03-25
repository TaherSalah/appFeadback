import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';

import '../localization/localization_manager.dart';



class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset("assets/icons/arrow.svg",color: Colors.black,height: 25,))

            ],
          ),
          body: Column(
            // spacing: 25,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                    child: Lottie.asset(
                        fit: BoxFit.fill,
                        height: 500,
                        width: 500,
                        'assets/json/wifi.json')),
              ),
              const SizedBox(height: 25),
              TextWidget(
                  fontWeight: FontWeight.w700,
                  fontSize: context.isTab ? 10.sp : 8.sp,
                  textAlign: TextAlign.center,
                  title: LocalizationManager.call('no_connection'))
            ],
          )),
    );
  }
}
