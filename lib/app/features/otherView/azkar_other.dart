import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/shard/widgets/done_widget.dart';
import 'azkar_other_controller.dart';
import 'widgets/azkar_other_list.dart';

class AzkarOthers extends StatelessWidget {
  const AzkarOthers({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AzkarOtherController());
    final con = Provider.of<AzkarProvider>(context);
    final bool allDone = con.isOtherDone;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
        ),
        child: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة العداد',
              onPressed: con.resetOther,
            ),
          ],
          leading: CupertinoNavigationBarBackButton(
            color: context.isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            AppString.KOtherZakar,
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: allDone
          ? DoneDialogWidget(
              onPressedRepeat: con.resetOther,
              doneText: AppString.KZakarOtherFeaturesDes,
              KZakarFeaturesTitle: AppString.KAzkarDaialogText,
              KDaialogText: AppString.KZakarFeaturesTitle,
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.w),
                ),
                const Expanded(
                  child: AzkarOtherList(),
                ),
              ],
            ),
    );
  }
}
