import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../core/shard/exports/all_exports.dart';
import 'post_prayer_azkar_controller.dart';
import 'widgets/post_prayer_azkar_list.dart';

class PostPrayerAzkarView extends StatelessWidget {
  const PostPrayerAzkarView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PostPrayerAzkarController());
    final con = Provider.of<AzkarProvider>(context);
    final isDark = context.isDark;
    final bool allDone = con.isPrayerDone;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          context.isTab ? 70 : 50,
        ),
        child: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة العداد',
              onPressed: con.resetPrayer,
            ),
          ],
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            AppString.KPrayer,
               style: TextStyle(
                          fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),
      body: allDone
          ? DoneDialogWidget(
              onPressedRepeat: con.resetPrayer,
              doneText: AppString.KZakarPrayerFeaturesDes,
              KZakarFeaturesTitle: AppString.KPrayerDaialogText,
              KDaialogText: AppString.KZakarPrayerFeaturesTitle,
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.w),
                ),
                const Expanded(
                  child: PostPrayerAzkarList(),
                ),
              ],
            ),
    );
  }
}
