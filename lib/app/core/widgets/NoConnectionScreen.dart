import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../localization/localization_manager.dart';
import '../utils/style/responsive_util.dart';



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
                  fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 8.sp,
                  textAlign: TextAlign.center,
                  title: LocalizationManager.call('no_connection'))
            ],
          )),
    );
  }
}
