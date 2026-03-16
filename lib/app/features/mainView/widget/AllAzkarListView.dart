import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';

import '../../../core/utils/style/responsive_util.dart';
import 'IslamicCardWidget.dart';

class Allazkarlistview extends StatelessWidget {
  const Allazkarlistview({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> iconsApp = [
      {
        "title": "أَذْكَارُ الصَّبَاحِ",
        "icon": "assets/images/contrast.png",
        "navigate": "/azkarSabah"
      },
      {
        "title": "أَذْكَارُ الْمَسَاءِ",
        "icon": "assets/images/islam.png",
        "navigate": "/azkarMassa"
      },
      {
        "title": AppString.KSleep,
        "icon": "assets/images/sleep.png",
        "navigate": "/sleepAzkar",
      },
      {
        "title": AppString.KPrayer,
        "icon": "assets/images/prayer-mat.png",
        "navigate": "/prayerAzkar",
      },
      {
        "title": AppString.KRokia,
        "icon": "assets/images/tasbih.png",
        "navigate": "/rokiaScreen",
      },
      {
        "title": AppString.KOtherZakar,
        "icon": "assets/images/praying.png",
        "navigate": "/azkarOthers",
      },
      {
        "title": AppString.KHazbNawawi,
        "icon": "assets/images/rub-el-hizb.png",
        "navigate": "/hazbNawawi",
      },
    ];
    bool isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
        child: AppBar(
leading: Navigator.canPop(context) ? CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ) : null,
          centerTitle: true,
          title: Text(
            "أذكار المسلم",
            style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
          ),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 15),
                  child: SizedBox(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: isTab ? 30 : 15,
                      mainAxisSpacing: isTab ? 20 : 25,
                      childAspectRatio: isTab ? 2.9 : 01.80,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // عشان المكون يكون جزء من ScrollView تانية
                      children: iconsApp.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return StaggeredItemAnimation(
                          index: index,
                          duration: const Duration(milliseconds: 400),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, item['navigate']!);
                            },
                            child: IslamicCardWidget(
                                title: item["title"]!, iconPath: item["icon"]!),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
