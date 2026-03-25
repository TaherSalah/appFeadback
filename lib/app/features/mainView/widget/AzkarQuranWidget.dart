import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/style/app_theme_colors.dart';

class AzkarQuranWidget extends StatefulWidget {
  const AzkarQuranWidget({super.key});

  @override
  _AzkarQuranWidgetState createState() => _AzkarQuranWidgetState();
}

class _AzkarQuranWidgetState extends State<AzkarQuranWidget> {
  List<String> quranicAzkar = [
    "رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ",
    "وَتُبْ عَلَيْنَا إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ",
    "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
    "رَبَّنَا لاَ تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا",
    "رَبَّنَا لاَ تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا",
    "رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا",
    "رَبِّ هَبْ لِي مِن لَّدُنكَ ذُرِّيَّةً طَيِّبَةً",
    "رَبَّنَا آمَنَّا بِمَا أَنزَلْتَ وَاتَّبَعْنَا الرَّسُولَ",
    "رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا",
    "رَبَّنَا مَا خَلَقْتَ هَذَا بَاطِلًا",
    "رَبَّنَا آمَنَّا فَاكْتُبْنَا مَعَ الشَّاهِدِينَ",
    "رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا",
    "رَبَّنَا لاَ تَجْعَلْنَا مَعَ الْقَوْمِ الظَّالِمِينَ",
    "حَسْبِيَ اللَّهُ لَا إِلَـهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ",
    "رَبَّنَا لَا تَجْعَلْنَا فِتْنَةً لِّلْقَوْمِ الظَّالِمِينَ",
    "رَبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ",
    "رَبِّ قَدْ آتَيْتَنِي مِنَ الْمُلْكِ وَعَلَّمْتَنِي مِن تَأْوِيلِ الْأَحَادِيثِ",
    "رَبِّ اجْعَلْ هَذَا الْبَلَدَ آمِنًا وَاجْنُبْنِي وَبَنِيَّ أَنْ نَعْبُدَ الْأَصْنَامَ",
    "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي",
    "رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا",
    "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ",
    "رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَن يَحْضُرُونِ",
    "رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
  ];

  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startZikrRotation();
  }

  void _startZikrRotation() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % quranicAzkar.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                image: isDark
                    ? null
                    : const DecorationImage(
                        image: AssetImage(
                          "assets/images/pattern.webp",
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: const BorderDirectional(
                  start:
                      BorderSide(color: CupertinoColors.systemGreen, width: 3),
                ),
                // color: Theme.of(context).cardColor,
                color: AppThemeColors.cardBackgroundColor(context)),
            width: MediaQuery.sizeOf(context).width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أدعية من القرآن",
                    style: TextStyle(
                  fontFamily: "cairo",
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.sizeOf(context).width > 600
                            ? 10.sp
                            : 15.sp),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    quranicAzkar[currentIndex],
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize:
                            MediaQuery.sizeOf(context).width > 600 ? 25 : 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 15,
          left: 55,
          child: InkWell(
            onTap: () {
              final shareText = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 *أدعية من القرآن*  

${quranicAzkar[currentIndex]}

🌿✨🌸✨🌿✨🌸✨🌿✨

💫 من تطبيق *رفيق المسلم اليومي* 💫  
حمل التطبيق الآن واستفد من كل الأذكار اليومية:

📱 **Android:**  
➡️ https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily

📱 **Huawei AppGallery:**  
➡️ https://appgallery.huawei.com/app/C114956477

📱 **iOS App Store:**  
➡️ https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338

🌟 شارك هذا الدعاء مع أصدقائك لتعمّ الفائدة 🌟

🌺✨🌿✨🌺✨🌿✨🌺✨🌿
""";

              Share.share(
                shareText,
                subject: "أدعية مختارة من رفيق المسلم اليومي",
              );
            },
            child: Icon(
              Icons.share,
              size: MediaQuery.sizeOf(context).width > 600 ? 25 : 20,
            ),
          ),
        ),

        Positioned(
          top: 15,
          left: 20,
          child: InkWell(
            onTap: () {
              final copyText = """
📿 *أدعية من القرآن*

${quranicAzkar[currentIndex]}

💫 من تطبيق رفيق المسلم اليومي  
حمل التطبيق الآن واستفد من كل الأذكار اليومية:  

Android: https://play.google.com/store/apps/details?id=com.rafiq.muslimdaily  
Huawei AppGallery: https://appgallery.huawei.com/app/C114956477  
iOS App Store: https://apps.apple.com/us/app/%D8%B1%D9%81%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%B3%D9%84%D9%85-%D8%A7%D9%84%D9%8A%D9%88%D9%85%D9%8A/id6749927338
""";

              Clipboard.setData(ClipboardData(text: copyText));
              KHelper.showSuccess(message: 'تم نسخ الدعاء إلى الحافظة!');
            },
            child: Icon(
              Icons.copy,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF00897B)
                  : CupertinoColors.systemRed,
              size: MediaQuery.sizeOf(context).width > 600 ? 25 : 20,
            ),
          ),
        ),

        // Positioned(
        //     top: 15,
        //     left: 55,
        //     child: InkWell(
        //       onTap: () {
        //         Share.share(
        //           subject: "أدعية من القرآن",
        //           ' أدعية من القرآن \n\n${quranicAzkar[currentIndex]}\n\n ',
        //         );
        //       },
        //       child: Icon(
        //         Icons.share,
        //         color: Theme.of(context).brightness == Brightness.dark ? Colors.white: CupertinoColors.darkBackgroundGray,
        //         size: MediaQuery.sizeOf(context).width>600?25: 20,
        //       ),
        //     )),
        // Positioned(
        //     top: 15,
        //     left: 20,
        //     child: InkWell(
        //       onTap: () {
        //         Clipboard.setData(
        //             ClipboardData(text: quranicAzkar[currentIndex]));
        //         KHelper.showSuccess(message:  'تم نسخ الدعاء إلى الحافظة !');
        //         // ScaffoldMessenger.of(context).showSnackBar(
        //         //   SnackBar(
        //         //       backgroundColor: CentralizedCubit.isDarkMode
        //         //           ? KColors.blackColor
        //         //           : KColors.whiteColor,
        //         //       content: TextWidget(
        //         //           fontSize: ResponsiveUtil.isTablet(context)
        //         //               ? 10.sp
        //         //               : 12.sp,
        //         //           textAlign: TextAlign.right,
        //         //
        //         //           title: '! تم نسخ الدعاء إلى الحافظة')),
        //         // );
        //       },
        //       child: Icon(
        //         Icons.copy,
        //         color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00897B): CupertinoColors.systemRed,
        //
        //         size: MediaQuery.sizeOf(context).width>600?25: 20,
        //       ),
        //     )),
      ],
    );
  }
}
