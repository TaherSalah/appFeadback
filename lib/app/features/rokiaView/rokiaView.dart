import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/shard/constanc/app_string.dart';
import 'package:muslimdaily/app/core/shard/widgets/done_widget.dart';
import 'package:provider/provider.dart';

import 'rokia_controller.dart';
import 'widgets/rokia_fab.dart';
import 'widgets/rokia_list.dart';
import 'widgets/rokia_player_ui.dart';

class RokiaScreen extends StatelessWidget {
  const RokiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RokiaController());
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final bool allDone = con.isQuranDone;

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context, isDark, con),
          body: allDone
              ? DoneDialogWidget(
                  repratBtn: "إعادة الرقية",
                  onPressedRepeat: con.resetQuran,
                  doneText: AppString.KZakarRokiaFeaturesDes,
                  KZakarFeaturesTitle: AppString.KRokiaFeaturesTitle,
                  KDaialogText: AppString.KRokiaDaialogText,
                )
              : const RokiaList(),
        ),
        if (!allDone) const RokiaFAB(),
        const RokiaPlayerUI(),
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
            onPressed: con.resetQuran,
          ),
        ],
        title: Text(
          AppString.KRokia,
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
