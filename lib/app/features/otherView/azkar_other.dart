import 'dart:ui' as ui;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/cubit/centralized_cubit.dart';
import '../../core/shard/exports/all_exports.dart';
import '../../core/shard/widgets/ui_animations.dart';
import '../../core/utils/style/k_helper.dart';
import '../sleep_view/sleep_azkar.dart';

class AzkarOthers extends StatefulWidget {
  const AzkarOthers({super.key});

  @override
  State<AzkarOthers> createState() => _AzkarOthersState();
}

class _AzkarOthersState extends State<AzkarOthers> {
  var selectedFontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = CentralizedCubit.get(context).azkarFontSize();

    final con = Provider.of<AzkarProvider>(context);
    final bool allDone = Azkary.azkarRepate.every((c) => c <= 0);

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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
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
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, zOtherIndex) {
                      // هل الذكر خلاص خلص؟
                      final bool isFinished =
                          con.zOtherIndex >= Azkary.azkarRepate[zOtherIndex];

                      // النص اللي هيظهر في كبسولة التكرار
                      final String repeatText = isFinished
                          ? "0"
                          : '${Azkary.azkarRepate[zOtherIndex]}';

                      // لون الكارت حسب حالة الانتهاء
                      final Color cardColor = isFinished
                          ? const Color(AppStyle
                              .yellowColor) // نفس اللي كنت مستخدمه قبل كده
                          : (isDark
                              ? Colors.black
                              : const Color(AppStyle.whiteColor));

                      return ScrollAppearAnimation(
                        duration: const Duration(milliseconds: 700),
                        child: GestureDetector(
                          onTap: () {
                            // لما تضغط على الكارت يقلّل العد
                            con.decrementOther(zOtherIndex);
                          },
                          child: AzkerItemBuilder(
                            azkarTitle: Azkary.azkarOtherTitle[zOtherIndex],
                            azkarDes: Azkary.azkarOtherDesc[zOtherIndex],
                            azkarRepate: repeatText,
                            fontSize: fontSize,
                            color: cardColor,
                            // تقدر تزبط ألوان كبسولة التكرار لو حابب
                            repertColor: isFinished
                                ? Colors.black
                                : (isDark ? Colors.white : Colors.black87),
                            repertColor2: isFinished
                                ? const Color(AppStyle.yellowColor)
                                : null,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, zOtherIndex) =>
                        SizedBox(height: 15.h),
                    itemCount: Azkary.azkarOtherTitle.length,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset(doneZakar)),
            SizedBox(height: 10.h),
            Text(
              AppString.KAzkarDaialogText,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              AppString.KZakarFeaturesTitle,
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 10.h),
            const Divider(
              color: Color(AppStyle.primaryColor),
              thickness: 2,
              indent: 150,
              endIndent: 150,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                AppString.KZakarOtherFeaturesDes,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: AppStyle.fontFamily,
                  height: 1.8,
                  fontSize: 17.5.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildOtherZakarItem({
  Color? color,
  required String azkarOtherTitle,
  required String azkarOtherDesc,
  required String azkarRepate,
  double? fontSize,
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final fullText = "$azkarOtherTitle\n\n$azkarOtherDesc";
  final shareFullTextFancy = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 *$fullText*

🌿✨🌸✨🌿✨🌸✨🌿✨

💫 من تطبيق *رفيق المسلم اليومي* 💫  
حمل التطبيق الآن واستفد من كل الذكر اليومي:

📱 **Play Google للاندرويد:**  
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

📱 **App Gallery هواوي:**  
➡️ https://appgallery.huawei.com/app/C114956477

📱 **App Store للايفون:**  
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 شارك هذا الذكر مع أصدقائك لتعمّ الفائدة 🌟

🌺✨🌿✨🌺✨🌿✨🌺✨🌿
""";
  return Stack(
    alignment: Alignment.bottomCenter,
    clipBehavior: Clip.none,
    children: [
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 14,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Text(
                    azkarOtherTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoKufiArabic(
                      fontSize:
                          MediaQuery.sizeOf(context).width > 600 ? 9.sp : 14.sp,
                      height: 3,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    azkarOtherDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'maja',
                      fontSize: fontSize ?? 18.sp,
                      height: 1.8,
                    ),
                  ),
                  SizedBox(height: 35.h),
                ],
              ),
            ),
          ),
        ),
      ),

      // 🔸 دائرة التكرار
      Positioned(
        bottom: -10,
        child: CircleAvatar(
          radius: 25,
          backgroundColor: color ?? const Color(AppStyle.primaryColor),
          child: Text(
            azkarRepate,
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // 🔹 أزرار النسخ والمشاركة بنفس مكان AzkerItemBuilder
      Positioned(
        bottom: -10,
        child: Row(
          spacing: 60,
          children: [
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: shareFullTextFancy));
                // Fluttertoast.showToast(
                //   msg: "تم نسخ الذكر بنجاح",
                //   gravity: ToastGravity.BOTTOM,
                //   backgroundColor: Colors.green.shade600,
                //   textColor: Colors.white,
                // );
                KHelper.showError(message: "تم نسخ الذكر بنجاح");

              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: isDark ? Colors.black : Colors.white,
                child: const Icon(Icons.copy, color: Colors.green, size: 20),
              ),
            ),
            SizedBox(width: 15.w),
            GestureDetector(
              onTap: () {
                Share.share(shareFullTextFancy, subject: azkarOtherTitle);
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: isDark ? Colors.black : Colors.white,
                child: const Icon(Icons.share, color: Colors.blue, size: 20),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
