import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/extensions/extensions.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_string.dart';
import 'package:muslimdaily/app/core/shard/widgets/done_widget.dart';
import 'package:provider/provider.dart';

import '../../core/controller/azkar_controller.dart';
import 'sleep_controller.dart';
import 'widgets/sleep_fab.dart';
import 'widgets/sleep_list.dart';
import 'widgets/sleep_player_ui.dart';

import 'package:muslimdaily/app/core/services/wakelock_service.dart';

class SleepAzkar extends StatefulWidget {
  const SleepAzkar({super.key});

  @override
  State<SleepAzkar> createState() => _SleepAzkarState();
}

class _SleepAzkarState extends State<SleepAzkar> {
  @override
  void initState() {
    super.initState();
    WakelockService.enableIfActive();
  }

  @override
  void dispose() {
    WakelockService.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SleepController());
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final bool allDone = con.isSleepDone;

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context, isDark, con),
          body: allDone
              ? DoneDialogWidget(
                  repratBtn: "إعادة الأذكار",
                  onPressedRepeat: con.resetSleep,
                  doneText: AppString.KZakarSleepFeaturesDes,
                  KZakarFeaturesTitle: AppString.KZakarSleepFeaturesTitle,
                  KDaialogText: AppString.KSleepDaialogText,
                )
              : const SleepList(),
        ),
        if (!allDone) const SleepFAB(),
        const SleepPlayerUI(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, AzkarProvider con) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        context.isTab ? 70 : 50,
      ),
      child: AppBar(
        leading: CupertinoNavigationBarBackButton(
          color: isDark ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة العداد',
            onPressed: con.resetSleep,
          ),
        ],
        title: Text(
          AppString.KSleep,
             style: TextStyle(
                          fontFamily: "cairo",
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: context.isTab ? 12.sp : 18.sp,
          ),
        ),
      ),
    );
  }
}
