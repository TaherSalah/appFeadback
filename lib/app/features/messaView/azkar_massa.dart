import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:muslimdaily/app/core/controller/azkar_controller.dart';
import '../../core/shard/exports/all_exports.dart';
import 'azkar_massa_controller.dart';
import 'widgets/azkar_massa_fab.dart';
import 'widgets/azkar_massa_list.dart';
import 'widgets/azkar_massa_player_ui.dart';

class AzkarMassa extends StatelessWidget {
  const AzkarMassa({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AzkarMassaController());
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final bool allDone = con.isMessaDone;

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50,
            ),
            child: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'إعادة العداد',
                  onPressed: con.resetMessa,
                ),
              ],
              leading: CupertinoNavigationBarBackButton(
                color: isDark ? Colors.white : Colors.black,
              ),
              centerTitle: true,
              title: Text(
                AppString.KMessa,
                   style: TextStyle(
                          fontFamily: "cairo",
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
                ),
              ),
            ),
          ),
          body: allDone
              ? DoneDialogWidget(
                  onPressedRepeat: con.resetMessa,
                  doneText: AppString.doneText,
                  KZakarFeaturesTitle: AppString.KZakarMessaFeaturesTitle,
                  KDaialogText: AppString.KMessaDaialogText,
                )
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0.w),
                    ),
                    const Expanded(
                      child: AzkarMassaList(),
                    ),
                  ],
                ),
        ),
        
        // 🔸 FAB التحكم بالصوت
        if (!allDone) const AzkarMassaFAB(),

        // 🔹 واجهة مشغل الصوت (ميني + كامل)
        const AzkarMassaPlayerUI(),
      ],
    );
  }
}
