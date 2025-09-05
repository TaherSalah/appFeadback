import 'package:flutter_svg/flutter_svg.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../exports/all_exports.dart';

class AboutItemBuilder extends StatefulWidget {
  const AboutItemBuilder({super.key});

  @override
  State<AboutItemBuilder> createState() => _AboutItemBuilderState();
}

class _AboutItemBuilderState extends State<AboutItemBuilder> {
  @override
  Widget build(BuildContext context) {
    final con = Provider.of<AzkarProvider>(context);
    final bool isTablate = MediaQuery.sizeOf(context).width > 600;

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
