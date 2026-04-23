import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'hazb_nawawi_controller.dart';
import 'widgets/hazb_nawawi_fab.dart';
import 'widgets/hazb_nawawi_player_ui.dart';
import 'widgets/hazb_nawawi_list.dart';

class HazbNawawiView extends StatelessWidget {
  const HazbNawawiView({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Get.put لتهيئة الـ Controller
    final controller = Get.put(HazbNawawiController());
    final isDark = context.isDark;

    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
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
                  onPressed: () {
                    final azkarProvider = Provider.of<AzkarProvider>(context, listen: false);
                    azkarProvider.resetHazbNawawi();
                  },
                ),
              ],
              title: Text(
                AppString.KHazbNawawi,
                style: TextStyle(
                  fontFamily: "cairo",
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      context.isTab ? 12.sp : 18.sp,
                ),
              ),
            ),
          ),
          body: const HazbNawawiList(),
        ),
        // زر التشغيل العائم (FAB)
        Obx(() {
          if (!controller.showMiniPlayer) {
            return const HazbNawawiFAB();
          }
          return const SizedBox.shrink();
        }),
        // واجهة المشغل (كامل أو ميني)
        const HazbNawawiPlayerUI(),
      ],
    );
  }
}
