import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../../../core/utils/style/k_color.dart';
import '../../../core/utils/style/k_helper.dart';
import '../../../core/utils/style/responsive_util.dart';
import '../../../core/widgets/custom_text_widget.dart';



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
              image:isDark?null: const DecorationImage(image: AssetImage("assets/images/pattern.webp",),fit: BoxFit.cover,opacity: 0.2),

              borderRadius: BorderRadius.circular(10),
              border: const BorderDirectional(
                start: BorderSide(color: Color(0xffd6bb7a), width: 3),
              ),
              color: Theme.of(context).cardColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أدعية مختارة",
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize:MediaQuery.sizeOf(context).width >600?10.sp:  15.sp),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    azkar[currentIndex],
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: MediaQuery.sizeOf(context).width >600?25: 16),
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
                Share.share(
                  subject: "أدعية مختارة",
                  ' أدعية مختارة \n\n${azkar[currentIndex]}\n\n ',
                );
              },
              child: Icon(
                Icons.share,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white: CupertinoColors.darkBackgroundGray,

                size: MediaQuery.sizeOf(context).width>600?25: 20,
              ),
            )),
        Positioned(
            top: 15,
            left: 20,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: azkar[currentIndex]));
                KHelper.showSuccess(message:  'تم نسخ الدعاء إلى الحافظة !');

                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //       backgroundColor: CentralizedCubit.isDarkMode
                //           ? KColors.blackColor
                //           : KColors.whiteColor,
                //       content: TextWidget(
                //           fontSize: ResponsiveUtil.isTablet(context)
                //               ? 10.sp
                //               : 12.sp,
                //           textAlign: TextAlign.right,
                //           title: '! تم نسخ الدعاء إلى الحافظة')),
                // );
              },
              child: Icon(
                Icons.copy,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.deepOrangeAccent: CupertinoColors.systemRed,
                size: MediaQuery.sizeOf(context).width>600?25: 20,
              ),
            )),
      ],
    );
  }
}


