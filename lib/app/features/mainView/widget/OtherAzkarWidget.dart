import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/style/app_theme_colors.dart';
import '../../../core/utils/style/k_helper.dart';
// ignore: unused_import
import '../../messaView/azkar_massa.dart';

class OtherAzkarWidget extends StatefulWidget {
  const OtherAzkarWidget({super.key});

  @override
  _OtherAzkarWidgetState createState() => _OtherAzkarWidgetState();
}

class _OtherAzkarWidgetState extends State<OtherAzkarWidget> {
  // final List<String> azkar = [
  //
  //   "لا إله إلا الله ولا نعبد إلا إياه له النعمة وله الفضل وله الثناء الحسن",
  //   "اللهم إني أسألك الجنة وما قرب إليها من قول أو عمل وأعوذ بك من النار وما قرب إليها من قول أو عمل",
  //   "اللهم إني أسألك خير المسألة، وخير الدعاء، وخير النجاح، وخير العمل، وخير الثواب، وخير الحياة، وخير الممات، وثبتني، وثقل موازيني، وحقق إيماني، وارفع درجاتي، وتقبل صلاتي، واغفر خطيئتي، وأسألك الدرجات العلى من الجنة.",
  // ];
  final List<String> azkar = [
    "يا الله .. علّمني خبيئة الصَّدر حتّى أستقيم بِكَ لك، أستغفر الله مِن كُلِّ مَيلٍ لا يَليق، ومِن كُلّ مسارٍ لا يُوافق رضاك، يا رب ثبِّتني اليومَ وغدًا، إنَّ الخُطى دونَك مائلة!",
    "اللهم إنا نسألك بأنك أنت الله الأحد الصمد الذي لم يلد ولم يولد ولم يكن له كفوا أحد أن تنظر إلينا في ساعتنا هذه فتنزل علينا رحمة من عندك وحنانا من لدنك تغننا بها عن رحمة وحنان من سواك.",
    "إلهي... كيف أمتنع بالذنب من الدعاء ولا أراك تمتنع مع الذنب من العطاء؟ فإن غفرت فخير راحم أنت وإن عذبت فغير ظالم أنت.",
    "رب اجعل أيامنا كلها سعادة رب بدد الأحزان وأبرئ الأسقام وابسط الأرزاق وحسن الأخلاق وانشر الرحمات وامح السيئات تباركت يا رب البريات يا رب الأرض والسماوات.",
    "ربنا اجعلنا لك ذكارين، لك شكارين، إليك أواهين منيبين، تقبل يا رب توبتنا، واغسل حوبتنا، وأجب دعواتنا، وثبت حجتنا، واسلل سخائم صدورنا، وعافنا واعف عنا.",
    "إلهي، كيف أفرح وقد عصيتك، وكيف لا أفرح وقد عرفتك، وكيف أدعوك وأنا خاطىء، وكيف لا أدعوك وأنت كريم.",
    "اللهم لك الحمد كله وإليك يرجع الأمر كله.",
    "سبحان الله عدد ما خلق في السماء، وسبحان الله عدد ما خلق في الأرض، وسبحان الله عدد ما بين ذلك، وسبحان الله عدد ما هو خالق، والله أكبر مثل ذلك، والحمد لله مثل ذلك، ولا حول ولا قوة إلا بالله مثل ذلك.",
    "اللهم لا تجعل الدنيا أكبر همنا ولا مبلغ علمنا.",
    "يا أكرم الأكرمين نسألك بركتك وعطفك ولطفك وعافيتك وبرك ورحمتك وحبك، نعوذ بك من تقلبات القلوب والأيام، اعصمنا من المعاصي والآثام، اشغلنا بخير ما يرضيك عنا، احمنا من أذى الناس، اشغلنا بك عن همومنا، اجعل الآخرة كل همنا.",
    "ربنا لك الحمد على جمالك وجلالك وعظمتك وكبريائك، رب اعصمنا من الزلل، واجبر ما بنا من خلل، نعوذ بك من طول الأمل، وحبوط العمل.",
    "يا رحمن الدنيا والآخرة ارحمنا وارض عنا في الدنيا والآخرة، اكتب لنا في هذه الدنيا حسنة، إنا تبنا إليك، اجعلنا ممن يأتيك يوم القيامة بقلب سليم منيب.",
    "اللهم أرنا نعمك علينا واجعلنا من الحامدين الشاكرين وألهمنا الثناء بها عليك، ربنا أعنا بنعمتك على حسن عبادتك، نعوذ بك من كفر النعمة ومن سوء استقبالها أو استعمالها، رب زدنا ولا تحرمنا ولا تقطع عنا ما أوليتنا به.",
    "اللهم لك الحمد أنت نور السماوات والأرض ومن فيهن، ولك الحمد، أنت قيوم السماوات والأرض ومن فيهن، ولك الحمد، أنت الحق، ووعدك الحق، ولقاؤك حق، والجنة حق، والنار حق، والنبيون حق، والساعة حق، ومحمد حق، اللهم لك أسلمت، وبك آمنت، وعليك توكلت، وإليك أنبت، وبك خاصمت، وإليك حاكمت، فاغفر لي ما قدمت وما أخرت، وما أسررت وما أعلنت، أنت إلهي لا إله إلا أنت.",
    "اللهم صل على محمد، وعلى آل محمد، كما صليت على إبراهيم، وعلى آل إبراهيم، إنك حميد مجيد، وبارك على محمد، وعلى آل محمد، كما باركت على إبراهيم، وعلى آل إبراهيم، إنك حميد مجيد.",
    "اللهم أحيني على سنة نبيك، وتوفني على ملته، وأعذني من مضلات الفتن.",
    "أستغفر الله العظيم الذي لا إله إلا هو، الحي القيوم، وأتوب إليه.",
    "رب اغفر لي خطيئتي يوم الدين.",
    "اللهم اهدني فيمن هديت، وعافني فيمن عافيت، وتولني فيمن توليت، وبارك لي فيما أعطيت، وقني شر ما قضيت، إنك تقضي ولا يقضى عليك، إنه لا يذل من واليت، تباركت ربنا وتعاليت.",
    "اللهم اغفر لي، اللهم اجعلني يوم القيامة فوق كثير من خلقك من الناس، اللهم اغفر لي ذنبي، وأدخلني يوم القيامة مدخلا كريما.",
    "اللهم إني أسألك شهادة في سبيلك.",
    "اللهم إني أعوذ بك من عذاب النار، وأعوذ بك من عذاب القبر، وأعوذ بك من الفتن ما ظهر منها وما بطن، وأعوذ بك من فتنة الدجال.",
    "اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والبخل والجبن، وضلع الدين، وغلبة الرجال.",
    "اللهم إني أعوذ بك من علم لا ينفع، وعمل لا يرفع، وقلب لا يخشع، وقول لا يسمع.",
    "اللهم إني أسألك المعافاة في الدنيا والآخرة.",
    "اللهم لا تخزني يوم القيامة.",
    "اللهم إني أعوذ بك من جار السوء، ومن زوج تشيبني قبل المشيب، ومن ولد يكون علي ربا، ومن مال يكون علي عذابا، ومن خليل ماكر عينه تراني، وقلبه يرعاني؛ إن رأى حسنة دفنها، وإذا رأى سيئة أذاعها.",
    "اللهم إني أعوذ بك من صلاة لا تنفع.",
    "اللهم جدد الإيمان في قلبي.",
    "اللهم آتنا في الدنيا حسنة، وفي الآخرة حسنة، وقنا عذاب النار.",
    "اللهم مصرف القلوب صرف قلوبنا على طاعتك.",
    "اللهم اغفر لي وارحمني واهدني وعافني وارزقني.",
    "اللهم أعني على ذكرك وشكرك وحسن عبادتك.",
    "اللهم إني أسألك حبك، وحب من يحبك، وحب عمل يقربني إلى حبك.",
    "اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي إليها معادي.",
    "اللهم إني أعوذ بك من زوال نعمتك، وتحول عافيتك، وفجاءة نقمتك، وجميع سخطك.",
    "اللهم إني أعوذ بك من البرص، والجنون، والجذام، ومن سيئ الأسقام.",
    "اللهم فقهني في الدين، وعلمني التأويل.",
    "اللهم اجعلني من التوابين، واجعلني من المتطهرين.",
    "اللهم إني أسألك الهدى، والتقى، والعفاف، والغنى.",
    "اللهم اجعل في قلبي نوراً، وفي لساني نوراً، وفي سمعي نوراً، وفي بصري نوراً.",
    "اللهم إني أعوذ بك من شر ما عملت، ومن شر ما لم أعمل.",
    "اللهم إني عبدك، ابن عبدك، ناصيتي بيدك، ماضٍ في حكمك، عدل في قضاؤك...",
    "اللهم اجعلني لك شَكَّارًا، لك ذَكَّارًا، لك رَهَّابًا، لك مُطِيعًا، لك مُخْبِتًا، إليك أَوَّاهًا منيبًا.",
  ];

  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startZikrRotation();
  }

  void _startZikrRotation() {
    _timer = Timer.periodic(const Duration(seconds: 40), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % azkar.length;
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
            // height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(10),
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
                start: BorderSide(color: Color(0xffd6bb7a), width: 3),
              ),
              // color: Theme.of(context).cardColor,
              color: AppThemeColors.cardBackgroundColor(context),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أدعية مختارة",
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.sizeOf(context).width > 600
                            ? 10.sp
                            : 15.sp),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    azkar[currentIndex],
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
        // Positioned(
        //     top: 15,
        //     left: 55,
        //     child: InkWell(
        //       onTap: () {
        //         Share.share(
        //           subject: "أدعية مختارة",
        //           ' أدعية مختارة \n\n${azkar[currentIndex]}\n\n ',
        //         );
        //       },
        //       child: Icon(
        //         Icons.share,
        //         // color: Theme.of(context).brightness == Brightness.dark ? Colors.white: CupertinoColors.darkBackgroundGray,
        //
        //         size: MediaQuery.sizeOf(context).width>600?25: 20,
        //       ),
        //     )),
        // Positioned(
        //     top: 15,
        //     left: 20,
        //     child: InkWell(
        //       onTap: () {
        //         Clipboard.setData(ClipboardData(text: azkar[currentIndex]));
        //         KHelper.showSuccess(message:  'تم نسخ الدعاء إلى الحافظة !');
        //
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
        //         //           title: '! تم نسخ الدعاء إلى الحافظة')),
        //         // );
        //       },
        //       child: Icon(
        //         Icons.copy,
        //         color: Theme.of(context).brightness == Brightness.dark ?  const Color(0xFF00897B): CupertinoColors.systemRed,
        //         size: MediaQuery.sizeOf(context).width>600?25: 20,
        //       ),
        //     )),
        Positioned(
          top: 15,
          left: 55,
          child: InkWell(
            onTap: () {
              final shareText = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 *أدعية مختارة*  

${azkar[currentIndex]}

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
📿 أدعية مختارة

${azkar[currentIndex]}

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
      ],
    );
  }
}

//
// class OtherAzkarWidget extends StatefulWidget {
//   const OtherAzkarWidget({super.key});
//
//   @override
//   _OtherAzkarWidgetState createState() => _OtherAzkarWidgetState();
// }
//
// class _OtherAzkarWidgetState extends State<OtherAzkarWidget> with SingleTickerProviderStateMixin {
//   final List<String> azkar = [
//     "يا الله .. علّمني خبيئة الصَّدر حتّى أستقيم بِكَ لك، أستغفر الله مِن كُلِّ مَيلٍ لا يَليق، ومِن كُلّ مسارٍ لا يُوافق رضاك، يا رب ثبِّتني اليومَ وغدًا، إنَّ الخُطى دونَك مائلة!",
//     "اللهم إنا نسألك بأنك أنت الله الأحد الصمد الذي لم يلد ولم يولد ولم يكن له كفوا أحد أن تنظر إلينا في ساعتنا هذه فتنزل علينا رحمة من عندك وحنانا من لدنك تغننا بها عن رحمة وحنان من سواك.",
//     "إلهي... كيف أمتنع بالذنب من الدعاء ولا أراك تمتنع مع الذنب من العطاء؟ فإن غفرت فخير راحم أنت وإن عذبت فغير ظالم أنت.",
//     "رب اجعل أيامنا كلها سعادة رب بدد الأحزان وأبرئ الأسقام وابسط الأرزاق وحسن الأخلاق وانشر الرحمات وامح السيئات تباركت يا رب البريات يا رب الأرض والسماوات.",
//     "ربنا اجعلنا لك ذكارين، لك شكارين، إليك أواهين منيبين، تقبل يا رب توبتنا، واغسل حوبتنا، وأجب دعواتنا، وثبت حجتنا، واسلل سخائم صدورنا، وعافنا واعف عنا.",
//     "إلهي، كيف أفرح وقد عصيتك، وكيف لا أفرح وقد عرفتك، وكيف أدعوك وأنا خاطىء، وكيف لا أدعوك وأنت كريم.",
//     "اللهم لك الحمد كله وإليك يرجع الأمر كله.",
//     "سبحان الله عدد ما خلق في السماء، وسبحان الله عدد ما خلق في الأرض، وسبحان الله عدد ما بين ذلك، وسبحان الله عدد ما هو خالق، والله أكبر مثل ذلك، والحمد لله مثل ذلك، ولا حول ولا قوة إلا بالله مثل ذلك.",
//     "اللهم لا تجعل الدنيا أكبر همنا ولا مبلغ علمنا.",
//     "يا أكرم الأكرمين نسألك بركتك وعطفك ولطفك وعافيتك وبرك ورحمتك وحبك، نعوذ بك من تقلبات القلوب والأيام، اعصمنا من المعاصي والآثام، اشغلنا بخير ما يرضيك عنا، احمنا من أذى الناس، اشغلنا بك عن همومنا، اجعل الآخرة كل همنا.",
//     "ربنا لك الحمد على جمالك وجلالك وعظمتك وكبريائك، رب اعصمنا من الزلل، واجبر ما بنا من خلل، نعوذ بك من طول الأمل، وحبوط العمل.",
//     "يا رحمن الدنيا والآخرة ارحمنا وارض عنا في الدنيا والآخرة، اكتب لنا في هذه الدنيا حسنة، إنا تبنا إليك، اجعلنا ممن يأتيك يوم القيامة بقلب سليم منيب.",
//     "اللهم أرنا نعمك علينا واجعلنا من الحامدين الشاكرين وألهمنا الثناء بها عليك، ربنا أعنا بنعمتك على حسن عبادتك، نعوذ بك من كفر النعمة ومن سوء استقبالها أو استعمالها، رب زدنا ولا تحرمنا ولا تقطع عنا ما أوليتنا به.",
//     "اللهم لك الحمد أنت نور السماوات والأرض ومن فيهن، ولك الحمد، أنت قيوم السماوات والأرض ومن فيهن، ولك الحمد، أنت الحق، ووعدك الحق، ولقاؤك حق، والجنة حق، والنار حق، والنبيون حق، والساعة حق، ومحمد حق، اللهم لك أسلمت، وبك آمنت، وعليك توكلت، وإليك أنبت، وبك خاصمت، وإليك حاكمت، فاغفر لي ما قدمت وما أخرت، وما أسررت وما أعلنت، أنت إلهي لا إله إلا أنت.",
//     "اللهم صل على محمد، وعلى آل محمد، كما صليت على إبراهيم، وعلى آل إبراهيم، إنك حميد مجيد، وبارك على محمد، وعلى آل محمد، كما باركت على إبراهيم، وعلى آل إبراهيم، إنك حميد مجيد.",
//     "اللهم أحيني على سنة نبيك، وتوفني على ملته، وأعذني من مضلات الفتن.",
//     "أستغفر الله العظيم الذي لا إله إلا هو، الحي القيوم، وأتوب إليه.",
//     "رب اغفر لي خطيئتي يوم الدين.",
//     "اللهم اهدني فيمن هديت، وعافني فيمن عافيت، وتولني فيمن توليت، وبارك لي فيما أعطيت، وقني شر ما قضيت، إنك تقضي ولا يقضى عليك، إنه لا يذل من واليت، تباركت ربنا وتعاليت.",
//     "اللهم اغفر لي، اللهم اجعلني يوم القيامة فوق كثير من خلقك من الناس، اللهم اغفر لي ذنبي، وأدخلني يوم القيامة مدخلا كريما.",
//     "اللهم إني أسألك شهادة في سبيلك.",
//     "اللهم إني أعوذ بك من عذاب النار، وأعوذ بك من عذاب القبر، وأعوذ بك من الفتن ما ظهر منها وما بطن، وأعوذ بك من فتنة الدجال.",
//     "اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والبخل والجبن، وضلع الدين، وغلبة الرجال.",
//     "اللهم إني أعوذ بك من علم لا ينفع، وعمل لا يرفع، وقلب لا يخشع، وقول لا يسمع.",
//     "اللهم إني أسألك المعافاة في الدنيا والآخرة.",
//     "اللهم لا تخزني يوم القيامة.",
//     "اللهم إني أعوذ بك من جار السوء، ومن زوج تشيبني قبل المشيب، ومن ولد يكون علي ربا، ومن مال يكون علي عذابا، ومن خليل ماكر عينه تراني، وقلبه يرعاني؛ إن رأى حسنة دفنها، وإذا رأى سيئة أذاعها.",
//     "اللهم إني أعوذ بك من صلاة لا تنفع.",
//     "اللهم جدد الإيمان في قلبي.",
//     "اللهم آتنا في الدنيا حسنة، وفي الآخرة حسنة، وقنا عذاب النار.",
//     "اللهم مصرف القلوب صرف قلوبنا على طاعتك.",
//     "اللهم اغفر لي وارحمني واهدني وعافني وارزقني.",
//     "اللهم أعني على ذكرك وشكرك وحسن عبادتك.",
//     "اللهم إني أسألك حبك، وحب من يحبك، وحب عمل يقربني إلى حبك.",
//     "اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي إليها معادي.",
//     "اللهم إني أعوذ بك من زوال نعمتك، وتحول عافيتك، وفجاءة نقمتك، وجميع سخطك.",
//     "اللهم إني أعوذ بك من البرص، والجنون، والجذام، ومن سيئ الأسقام.",
//     "اللهم فقهني في الدين، وعلمني التأويل.",
//     "اللهم اجعلني من التوابين، واجعلني من المتطهرين.",
//     "اللهم إني أسألك الهدى، والتقى، والعفاف، والغنى.",
//     "اللهم اجعل في قلبي نوراً، وفي لساني نوراً، وفي سمعي نوراً، وفي بصري نوراً.",
//     "اللهم إني أعوذ بك من شر ما عملت، ومن شر ما لم أعمل.",
//     "اللهم إني عبدك، ابن عبدك، ناصيتي بيدك، ماضٍ في حكمك، عدل في قضاؤك...",
//     "اللهم اجعلني لك شَكَّارًا، لك ذَكَّارًا، لك رَهَّابًا، لك مُطِيعًا، لك مُخْبِتًا، إليك أَوَّاهًا منيبًا.",
//   ];
//
//   int currentIndex = 0;
//   Timer? _timer;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//     _startZikrRotation();
//   }
//
//   void _startZikrRotation() {
//     _timer = Timer.periodic(const Duration(seconds: 40), (timer) {
//       setState(() {
//         _animationController.reset();
//         currentIndex = (currentIndex + 1) % azkar.length;
//         _animationController.forward();
//       });
//     });
//   }
//
//   void _nextDua() {
//     setState(() {
//       _animationController.reset();
//       currentIndex = (currentIndex + 1) % azkar.length;
//       _animationController.forward();
//     });
//   }
//
//   void _previousDua() {
//     setState(() {
//       _animationController.reset();
//       currentIndex = (currentIndex - 1 + azkar.length) % azkar.length;
//       _animationController.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final isTablet = screenWidth > 600;
//
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 15),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//             colors: isDark
//                 ? [
//               const Color(0xFF1a1a2e),
//               const Color(0xFF16213e),
//             ]
//                 : [
//               const Color(0xFFffffff),
//               const Color(0xFFf8f9fa),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: const Color(0xFFd6bb7a).withOpacity(0.3),
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: isDark
//                   ? Colors.black.withOpacity(0.5)
//                   : const Color(0xFFd6bb7a).withOpacity(0.2),
//               blurRadius: 20,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             // النمط الخلفي
//             if (!isDark)
//               Positioned.fill(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(24),
//                   child: Opacity(
//                     opacity: 0.05,
//                     child: Image.asset(
//                       "assets/images/pattern.webp",
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//
//             // الزخرفة الإسلامية في الزوايا
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                     topRight: Radius.circular(24),
//                     bottomLeft: Radius.circular(40),
//                   ),
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFd6bb7a).withOpacity(0.3),
//                       const Color(0xFFd6bb7a).withOpacity(0.1),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             Positioned(
//               bottom: 0,
//               left: 0,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(24),
//                     topRight: Radius.circular(40),
//                   ),
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFd6bb7a).withOpacity(0.3),
//                       const Color(0xFFd6bb7a).withOpacity(0.1),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             // المحتوى الرئيسي
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // الهيدر
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFFd6bb7a), Color(0xFFc9a961)],
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFFd6bb7a).withOpacity(0.3),
//                               blurRadius: 8,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.auto_stories_rounded,
//                           color: Colors.white,
//                           size: isTablet ? 22 : 20,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "أدعية مختارة",
//                               style: GoogleFonts.cairo(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: isTablet ? 12.sp : 18,
//                                 color: isDark ? Colors.white : Colors.black87,
//                               ),
//                             ),
//                             Text(
//                               "${currentIndex + 1} من ${azkar.length}",
//                               style: GoogleFonts.cairo(
//                                 fontSize: isTablet ? 9.sp : 12,
//                                 color: const Color(0xFFd6bb7a),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // أزرار التحكم
//                       Row(
//                         children: [
//                           _buildActionButton(
//                             icon: Icons.share_rounded,
//                             color: const Color(0xFF00897B),
//                             onTap: () {
//                               Share.share(
//                                 subject: "أدعية مختارة",
//                                 'أدعية مختارة\n\n${azkar[currentIndex]}\n\n',
//                               );
//                             },
//                             isTablet: isTablet,
//                           ),
//                           const SizedBox(width: 8),
//                           _buildActionButton(
//                             icon: Icons.copy_rounded,
//                             color: isDark ? Colors.amberAccent : Colors.red,
//                             onTap: () {
//                               Clipboard.setData(
//                                 ClipboardData(text: azkar[currentIndex]),
//                               );
//                               KHelper.showSuccess(
//                                 message: 'تم نسخ الدعاء إلى الحافظة !',
//                               );
//                             },
//                             isTablet: isTablet,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   // نص الدعاء مع الأنيميشن
//                   Expanded(
//                     child: FadeTransition(
//                       opacity: _fadeAnimation,
//                       child: Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? Colors.white.withOpacity(0.05)
//                               : const Color(0xFFd6bb7a).withOpacity(0.05),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: const Color(0xFFd6bb7a).withOpacity(0.2),
//                             width: 1,
//                           ),
//                         ),
//                         child: Center(
//                           child: SingleChildScrollView(
//                             child: Text(
//                               azkar[currentIndex],
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.amiri(
//                                 fontSize: isTablet ? 20 : 18,
//                                 height: 2.0,
//                                 fontWeight: FontWeight.w600,
//                                 color: isDark ? Colors.white : Colors.black87,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // أزرار التنقل
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildNavigationButton(
//                         icon: Icons.arrow_forward_ios_rounded,
//                         onTap: _previousDua,
//                         isDark: isDark,
//                         isTablet: isTablet,
//                       ),
//                       const SizedBox(width: 16),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFFd6bb7a), Color(0xFFc9a961)],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.auto_awesome_rounded,
//                               color: Colors.white,
//                               size: isTablet ? 16 : 14,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               "${currentIndex + 1}",
//                               style: GoogleFonts.cairo(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: isTablet ? 11.sp : 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       _buildNavigationButton(
//                         icon: Icons.arrow_back_ios_rounded,
//                         onTap: _nextDua,
//                         isDark: isDark,
//                         isTablet: isTablet,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//     required bool isTablet,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: color,
//           size: isTablet ? 18 : 20,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavigationButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required bool isDark,
//     required bool isTablet,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFFd6bb7a).withOpacity(0.2),
//               const Color(0xFFc9a961).withOpacity(0.2),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: const Color(0xFFd6bb7a).withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: const Color(0xFFd6bb7a),
//           size: isTablet ? 20 : 24,
//         ),
//       ),
//     );
//   }
// }
