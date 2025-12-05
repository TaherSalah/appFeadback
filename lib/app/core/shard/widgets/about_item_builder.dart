import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:share_plus/share_plus.dart';

import '../../../features/aboutView/RateService.dart';
import '../exports/all_exports.dart';

class AboutItemBuilder extends StatefulWidget {
  const AboutItemBuilder({super.key});

  @override
  State<AboutItemBuilder> createState() => _AboutItemBuilderState();
}

class _AboutItemBuilderState extends State<AboutItemBuilder> {
  @override
  Widget build(BuildContext context) {

    void shareGooglePlay() {
      const msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من Google Play:
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }

    void shareAppGallery() {
      const msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من Huawei AppGallery:
➡️ https://appgallery.huawei.com/app/C114956477

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }

    void shareAppStore() {
      const msg = '''
📱✨ تطبيق *رَفِيقُ المُسْلِمِ اليَوْمِيّ* — القرآن والأذكار اليومية في مكان واحد! ✨📱

قم بتحميل التطبيق الآن من App Store:
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 استمتع بقراءة الأذكار والأحاديث اليومية بسهولة وراحة.
''';
      Share.share(msg, subject: 'رَفِيقُ المُسْلِمِ اليَوْمِيّ');
    }


    final con = Provider.of<AzkarProvider>(context);
    final bool isTablate = MediaQuery.sizeOf(context).width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: SizedBox(
              height: 150.h,
              width: 150.w,
              child: Image.asset(
                azkaryLogo,
                height: 150.h,
              ),
            ),
          ),
        ),
        Text(
          "رَفِيقُ المُسْلِمِ اليَوْمِيُ",
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold, fontSize: isTablate ? 9.sp : 14.sp),
        ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppString.KAppAbout,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextDefaultWidget(
                  color: isDark?Colors.white:Colors.black,

                  height: 2,
                  textAlign: TextAlign.justify,
                  title: AppString.KAboutText,
                  fontFamily: "me",
                  fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                  fontWeight: ResponsiveUtil.isTablet(context)
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        AppString.KSadka,
                        style: GoogleFonts.cairo(

                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0.w),
                    child: TextDefaultWidget(
                      height: 2,
                      textAlign: TextAlign.justify,
                      title: AppString.KAboutText2,
                      color: isDark?Colors.white:Colors.black,
                      fontFamily: "me",
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                      fontWeight: ResponsiveUtil.isTablet(context)
                          ? FontWeight.w600
                          : FontWeight.w500,
                    )),
                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        AppString.KContact,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: InkWell(
                          onTap: () async {
                            await con.launchInWeb(Uri.parse(
                                'https://www.facebook.com/taher.salah.7927'));
                          },
                          child: SvgPicture.asset(facebook)),
                    ),
                    InkWell(
                        onTap: () async {
                          await con.launchInWeb(
                              Uri.parse('https://wa.me/+201094529752'));
                        },
                        child: Image.asset(
                          whatsApp,
                          height: 40,
                        )),
                  ],
                ),
                SizedBox(
                  height: 7.h,
                ),
                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        "شارك التطبيق",
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                SizedBox(height: 10.h),

// زر قيّم التطبيق
                Center(
                  child: ElevatedButton.icon(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(KColors.primaryColor)),
                    icon: const Icon(Icons.star_rate_rounded),
                    label: Text(
                      'قيّم التطبيق',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: isTablate ? 9.sp : 14.sp),
                    ),
                    onPressed: () => context.read<RateService>().askForReview(context),
                  ),
                ),

                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        "شارك التطبيق",
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: shareGooglePlay,
                          child: Image.asset(
                            googlePlay,
                            height: 40,
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: InkWell(
                            onTap: shareAppGallery,
                            child: Image.asset(huaweiGallary,height: 40,)),
                      ),
                      InkWell(
                          onTap: shareAppStore,
                          child: Image.asset(
                            appleStore,
                            height: 40,
                          )),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: myDivider()),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(
                        AppString.KDevlop,
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablate ? 9.sp : 14.sp),
                      ),
                    ),
                    Expanded(child: myDivider()),
                  ],
                ),
                SizedBox(
                  height: 7.h,
                ),
                Text(
                  AppString.KAppRights,
                  style: GoogleFonts.merienda(fontSize: ResponsiveUtil.isTablet(context)?8.sp :10.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
