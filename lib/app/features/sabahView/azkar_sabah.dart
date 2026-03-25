import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/shard/widgets/done_widget.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import '../../core/shard/constanc/app_string.dart';
import 'azkar_sabah_controller.dart';
import 'widgets/azkar_sabah_fab.dart';
import 'widgets/azkar_sabah_player_ui.dart';
import 'widgets/azkar_sabah_list.dart';

class AzkarSabah extends StatelessWidget {
  const AzkarSabah({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AzkarSabahController());
    final con = Provider.of<AzkarProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool allDone = con.isSabahDone;

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context, isDark, con),
          body: allDone
              ? DoneDialogWidget(
                  onPressedRepeat: con.resetSabah,
                  doneText: AppString.doneText,
                  KZakarFeaturesTitle: AppString.KZakarSabahFeaturesTitle,
                  KDaialogText: AppString.KSabahDaialogText,
                )
              : const AzkarSabahList(),
        ),
        if (!allDone) const AzkarSabahFAB(),
        const AzkarSabahPlayerUI(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, AzkarProvider con) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
        MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
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
            onPressed: con.resetSabah,
          ),
        ],
        title: Text(
          AppString.Ksabah,
             style: TextStyle(
                          fontFamily: "cairo",
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
          ),
        ),
      ),
    );
  }
}
