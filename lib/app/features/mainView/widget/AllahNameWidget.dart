import 'dart:math';

import '../../../core/shard/exports/all_exports.dart';

class AllahNameWidget extends StatefulWidget {
  const AllahNameWidget({super.key});

  @override
  State<AllahNameWidget> createState() => _AllahNameWidgetState();
}

class _AllahNameWidgetState extends State<AllahNameWidget> {
  // قائمة أسماء الله الحسنى (موسعة لتشمل 99 اسمًا)
  final List<Map<String, String>> names = [
    {
      "name": "الله",
      "meaning":
          "عَلَمٌ على الذات الإلهية، الاسم الأعظم الذي تفرد به الحق سبحانه.",
      "reflection": "تذكر أن الله هو الخالق والرازق لكل شيء."
    },
    {
      "name": "الرَّحْمَن",
      "meaning":
          "كثير الرحمة، اسم مقصور عليه فلا يقال لغيره، يرحم بجلائل النعم.",
      "reflection": "رحمة الله واسعة، فكن رحيمًا بمن حولك."
    },
    {
      "name": "الرَّحِيم",
      "meaning":
          "المنعم أبدًا، المتفضل دومًا، فرحمته لا تنتهي، يرحم بدقائق النّعم.",
      "reflection": "رحمة الله لا تنتهي، فاحرص على أن تكون رحيمًا."
    },
    {
      "name": "المَلِك",
      "meaning":
          "ملك الملوك، له الملك، مالك يوم الدين، مليك الخلق، فهو المالك المطلق.",
      "reflection": "تذكر أن الله هو الملك المتفرد بالسلطان."
    },
    {
      "name": "الْقُدُّوس",
      "meaning": "الطاهر المنزه عن العيوب والنقائص، وعن كل ما تحيط به العقول.",
      "reflection": "أنت في حضرة القدوس، الطاهر من كل نقص."
    },
    {
      "name": "السَّلَام",
      "meaning": "ناشر السلام بين الأنام، سلمت ذاته من النقص والعيب والفناء.",
      "reflection": "السلام هو اسم الله، اجعل السلام رفيقًا لك."
    },
    {
      "name": "المُؤْمِن",
      "meaning": "سلَّم أوليائه من عذابه، ويُصدق عباده ما وعدهم.",
      "reflection": "كن مؤمنًا في عملك، تجد سلامة في قلبك."
    },
    {
      "name": "المُهَيْمِن",
      "meaning":
          "الحافظ لكل شيء، القائم على خلقه، والمطلع على خفايا الأمور، وخبايا الصدور.",
      "reflection": "الله المهيمن، فثق بأنه يراقبك في كل وقت."
    },
    {
      "name": "الْعَزِيز",
      "meaning":
          "المنفرد بالعزة، الظاهر الذي لا يُقهر، القوي الممتنع غالب كل شيء.",
      "reflection": "اعرف أن الله عزَّ وجَل هو العزيز الذي لا يُقهر."
    },
    {
      "name": "الْجَبَّار",
      "meaning":
          "تنفذ مشيئته، ولا يخرج أحد عن تقديره، القاهر لخلقه على ما أراد.",
      "reflection": "استشعر قوة الله التي تقهر كل شيء."
    },
    {
      "name": "المُتَكَبِّر",
      "meaning": "المتعالي عن صفات الخلق، المنفرد بالعظمة والكبرياء.",
      "reflection": "تذكر أن الله هو المتكبر وحده."
    },
    {
      "name": "الخَالِق",
      "meaning":
          "المبدع لكل شيء والمُقدّر له، الموجد للأشياء من العدم، خالق كل صانع وصنعته.",
      "reflection": "الله هو الخالق، فاعرف أنه هو الذي أوجدك."
    },
    {
      "name": "الْبَارِئ",
      "meaning":
          "خلق الخلق بقدرته لا عن مثال سابق، القادر على إبراز ما قدره إلى الوجود.",
      "reflection": "الله هو الباريء الذي أوجدك، فاحمده."
    },
    {
      "name": "الْمُصَوِّر",
      "meaning":
          "أعطى كل موجود صورة خاصة تمّيزه، وهيئة منفردة، على اختلاف الموجودات وكثرتها.",
      "reflection": "كل خلق على وجه الأرض هو صورة من صور الله."
    },
    {
      "name": "اَلْغَفَّار",
      "meaning": "يغفر الذنوب ويستر العيوب في الدنيا والآخرة.",
      "reflection": "تذكر دائمًا أن الله غفور رحيم."
    },
    {
      "name": "الْقَهَّار",
      "meaning":
          "الغالب الذي قهر خلقه بسلطانه وقدرته، وخضعت له الرقاب، وذلت له الجبابرة.",
      "reflection": "الله هو القهار، فاستسلم لإرادته."
    },
    {
      "name": "الْوَهَّاب",
      "meaning": "المنعم على العباد، يهب بغير عوض، ويعطي الحاجة بغير سؤال.",
      "reflection": "الله هو الوهّاب، فاطلب منه وكن شاكرًا."
    },
    {
      "name": "الرَّزَّاق",
      "meaning": "خلق الأرزاق، وأعطى كل الخلائق أرزاقها.",
      "reflection": "اعتمد على الرزاق واطلب منه رزقك."
    },
    {
      "name": "الْفَتَّاح",
      "meaning": "يفتح مغلق الأمور، ويسهل العسير.",
      "reflection": "الله هو الفتاح، فاطلب الفتح منه."
    },
    {
      "name": "الْعَلِيم",
      "meaning": "يعلم تفاصيل الأمور، ودقائق الأشياء، وخفايا الضمائر.",
      "reflection": "الله يعلم ما في قلبك، فاعمل بما يرضيه."
    },
    {
      "name": "الْقَابِضُ",
      "meaning": "يقبض الرزق عمن يشاء.",
      "reflection": "اعلم أن الله هو القابض، فأطلب الرزق منه."
    },
    {
      "name": "الْبَاسِطُ",
      "meaning": "يوسع الرزق لمن يشاء.",
      "reflection": "الله هو الباسط، فاسأله أن يوسع رزقك."
    },
    {
      "name": "الخَافِض",
      "meaning": "يخفض كل من طغى وتجبر.",
      "reflection": "الله هو الخافض، فلا تتكبر."
    },
    {
      "name": "الرَّافِعُ",
      "meaning": "يرفع عباده المؤمنين بالطاعات.",
      "reflection": "اطلب من الله أن يرفعك بين عباده الصالحين."
    },
    {
      "name": "المُعِزّ",
      "meaning": "يهب القوة والغلبة لمن شاء.",
      "reflection": "الله هو المعز، فاطلب العزة منه."
    },
    {
      "name": "المُذِلّ",
      "meaning": "ينزع القوة عن من يشاء.",
      "reflection": "الله هو المذل، فلا تجعل نفسك في موقع ذل."
    },
    {
      "name": "السَّمِيعُ",
      "meaning": "سمعه لجميع الأصوات الظاهرة والباطنة.",
      "reflection": "الله يسمع دعاءك، فلا تيأس."
    },
    {
      "name": "الْبَصِير",
      "meaning": "يرى الأشياء كلها ظاهرها وباطنها.",
      "reflection": "الله هو البصير، فثق في تدبيره."
    },
    {
      "name": "الْحَكَم",
      "meaning": "يفصل بين مخلوقاته بما شاء.",
      "reflection": "الله هو الحكام، فلا تخش من الظلم."
    },
    {
      "name": "الْعَدْل",
      "meaning": "حرَّم الظلم على نفسه.",
      "reflection": "الله هو العدل، فثق في عدله."
    },
    {
      "name": "اللَّطِيفُ",
      "meaning": "الرفيق بعباده.",
      "reflection": "الله لطيف بعباده، فاطلب منه اللطف."
    },
    {
      "name": "الْخَبِيرُ",
      "meaning": "العليم بدقائق الأمور.",
      "reflection": "الله خبير بكل شيء، فكن واثقًا."
    },
    {
      "name": "الْحَلِيمُ",
      "meaning": "يمهل ولا يهمل.",
      "reflection": "الله هو الحليم، فكن حليمًا مع الآخرين."
    },
    {
      "name": "الْعَظِيمُ",
      "meaning": "العظيم في كل شيء.",
      "reflection": "الله عظيم في ذاته، فاعرف عظمته."
    },
    {
      "name": "الْغَفُورُ",
      "meaning": "الستر للمذنبين.",
      "reflection": "الله يغفر الذنوب، فاستغفره."
    },
    {
      "name": "الشَّكُورُ",
      "meaning": "يزكو عنده القليل من أعمال العباد.",
      "reflection": "اعمل قليلًا، وسيشكرك الله."
    },
    {
      "name": "الْعَلِيُّ",
      "meaning": "الرفيع القدر.",
      "reflection": "الله علي، فرفع همتك لله."
    },
    {
      "name": "الْكَبِيرُ",
      "meaning": "العظيم الجليل ذو الكبرياء.",
      "reflection": "الله هو الكبير، فلا تظن نفسك كبيرًا."
    },
    {
      "name": "الْحَفِيظُ",
      "meaning": "لا يغرب عن حفظه شيء.",
      "reflection": "الله يحفظك، فتوكل عليه."
    },
    {
      "name": "المُقِيت",
      "meaning": "المتكفل بإيصال أقوات الخلق إليهم.",
      "reflection": "الله هو المقيت، فاطلب رزقك منه."
    },
    {
      "name": "الْحَسِيبُ",
      "meaning": "الكافي الذي منه كفاية العباد.",
      "reflection": "الله هو الحسيب، فثق أنه سيكفيك."
    },
    {
      "name": "الجَلِيل",
      "meaning": "العظيم المطلق المتصف بجميع صفات الكمال.",
      "reflection": "الله جليل، فتعامل معه بكل تقدير."
    },
    {
      "name": "الْكَرِيمُ",
      "meaning": "الكثير الخير، الجواد المعطي.",
      "reflection": "الله كريم، فاطلب منه الخير."
    },
    {
      "name": "الرَّقِيبُ",
      "meaning": "يراقب أحوال العباد.",
      "reflection": "الله رقيب، فاعمل بخوفه."
    },
    {
      "name": "الْمُجِيبُ",
      "meaning": "يجيب دعاء من دعاه.",
      "reflection": "الله مجيب الدعوات، فادعه."
    },
    {
      "name": "الْوَاسِعُ",
      "meaning": "وسع رزقه جميع خلقه.",
      "reflection": "الله واسع، فاطلب رزقك من واسع الرحمة."
    },
    {
      "name": "الْحَكِيمُ",
      "meaning": "المحق في تدبيره.",
      "reflection": "الله حكيم، فثق في تدبيره."
    },
    {
      "name": "الْوَدُودُ",
      "meaning": "المحب لعباده.",
      "reflection": "الله ودود، فكن محبًا لعباده."
    },
    {
      "name": "الْمَجِيدُ",
      "meaning": "تمجَّد بفعاله، ومجَّده خلقه.",
      "reflection": "الله مجيد، فمجده واذكره."
    },
    {
      "name": "البَاعِث",
      "meaning": "يُحيي الخلق يوم القيامة.",
      "reflection": "الله هو الباعث، فثق في قدرته."
    },
    {
      "name": "الشَّهِيدُ",
      "meaning": "الحاضر الذي لا يغيب عنه شيء.",
      "reflection": "الله شهيد على كل شيء، فاستشعر وجوده."
    },
    {
      "name": "الْحَقُّ",
      "meaning": "يحق الحق بكلماته.",
      "reflection": "الله هو الحق، فاتبعه في كل شيء."
    },
    {
      "name": "الْوَكِيلُ",
      "meaning": "الكفيل بالخلق القائم بأمورهم.",
      "reflection": "الله هو الوكيل، فتوكل عليه."
    },
    {
      "name": "الْقَوِيُ",
      "meaning": "صاحب القدرة التامة البالغة الكمال.",
      "reflection": "الله قوي، فتوكل عليه في كل الأمور."
    },
    {
      "name": "الْمَتِينُ",
      "meaning": "الشديد الذي لا يحتاج إلى جند أو مدد.",
      "reflection": "الله متين، فثق في قوته."
    },
    {
      "name": "الْوَلِيُّ",
      "meaning": "المحب الناصر لمن أطاعه.",
      "reflection": "الله هو الولي، فاطلب نصره."
    },
    {
      "name": "الْحَمِيدُ",
      "meaning": "المستحق للحمد والثناء.",
      "reflection": "الله هو الحميد، فاحمده على كل حال."
    },
    {
      "name": "الْمُحْصِي",
      "meaning": "أحصى كل شيء بعلمه.",
      "reflection": "الله يحصي كل شيء، فلا تهمل عملك."
    },
    {
      "name": "المُبْدِئ",
      "meaning": "أنشأ الأشياء ابتداءً من غير سابق مثال.",
      "reflection": "الله هو المبدئ، فكل شيء بيديه."
    },
    {
      "name": "المُعِيد",
      "meaning": "يعيد الخلق بعد الحياة إلى الممات.",
      "reflection": "الله هو المعيد، فاعرف أنه القادر على الإحياء."
    },
    {
      "name": "المُحْيِي",
      "meaning": "خالق الحياة ومعطيها.",
      "reflection": "الله هو المحيي، فاطلب الحياة بيديه."
    },
    {
      "name": "المُمِيت",
      "meaning": "مقدر الموت على كل من أماته.",
      "reflection": "الله هو المميت، فاعرف أنه مالك الموت."
    },
    {
      "name": "الْحَيُّ",
      "meaning": "المتصف بالحياة الأبدية.",
      "reflection": "الله هو الحي، فاستشعر وجوده الدائم."
    },
    {
      "name": "الْقَيُّومُ",
      "meaning": "القائم بنفسه، الغني عن غيره.",
      "reflection": "الله هو القيوم، فاعتمد عليه في كل شيء."
    },
    {
      "name": "الْوَاجِد",
      "meaning": "لا يعوزه شيء ولا يعجزه شيء.",
      "reflection": "الله هو الواجد، فاطلب منه كل شيء."
    },
    {
      "name": "الْمَاجِد",
      "meaning": "له الكمال المتناهي والعز الباهي.",
      "reflection": "الله هو المجيد، فمجده بما يليق."
    },
    {
      "name": "الْوَاحِدُ",
      "meaning": "الفرد المتفرد في ذاته وصفاته وأفعاله.",
      "reflection": "الله هو الواحد، فاعترف بوحدانيته."
    },
    {
      "name": "الصَّمَد",
      "meaning": "المطاع لا يقضى دونه أمر.",
      "reflection": "الله هو الصمد، فاعتمد عليه وحده."
    },
    {
      "name": "الْقَادِرُ",
      "meaning": "يقدر على إيجاد المعدوم وإعدام الموجود.",
      "reflection": "الله هو القادر، فلا حدود لقدراته."
    },
    {
      "name": "الْمُقْتَدِر",
      "meaning": "يقدر على إصلاح الخلائق.",
      "reflection": "الله هو المقتدر، فلا يعجزه شيء."
    },
    {
      "name": "المُقَدِّم",
      "meaning": "يقدم الأشياء ويضعها في مواضعها.",
      "reflection": "الله هو المقدم، فكل شيء في محله."
    },
    {
      "name": "المُؤَخِّر",
      "meaning": "يؤخر الأشياء في مواضعها.",
      "reflection": "الله هو المؤخر، فكل شيء له وقته."
    },
    {
      "name": "الأوَّل",
      "meaning": "لم يسبقه في الوجود شيء.",
      "reflection": "الله هو الأول، فابدأ به في كل شيء."
    },
    {
      "name": "الآخِر",
      "meaning": "الباقي بعد فناء خلقه.",
      "reflection": "الله هو الآخِر، فاعرف أن البقاء له وحده."
    },
    {
      "name": "الظَّاهِرُ",
      "meaning": "ظهر فوق كل شيء وعلا عليه.",
      "reflection": "الله هو الظاهر، فلا أحد فوقه."
    },
    {
      "name": "البَاطِنُ",
      "meaning": "العالم ببواطن الأمور وخفاياها.",
      "reflection": "الله هو الباطن، فاستشعر قربه."
    },
    {
      "name": "الْوَالِي",
      "meaning": "المالك للأشياء المتصرف فيها.",
      "reflection": "الله هو الوالي، فثق في تدبيره."
    },
    {
      "name": "المُتَعَالِ",
      "meaning": "جلّ عن إفك المفترين.",
      "reflection": "الله هو المتعالي، فلا تظن أنك في مكانة أعلى منه."
    },
    {
      "name": "البَرُّ",
      "meaning": "العطوف على عباده ببره ولطفه.",
      "reflection": "الله هو البر، فاطلب بره في حياتك."
    },
    {
      "name": "التَّوَّابُ",
      "meaning": "يوفق عباده للتوبة.",
      "reflection": "الله هو التواب، فتوكل عليه وتب إليه."
    },
    {
      "name": "المُنْتَقِمُ",
      "meaning": "يقصم ظهور الطغاة.",
      "reflection": "الله هو المنتقم، فلا تظن أنه غافل."
    },
    {
      "name": "العَفُو",
      "meaning": "يترك المؤاخذة على الذنوب.",
      "reflection": "الله هو العفو، فاعرف أن هناك دومًا فرصة للتوبة."
    },
    {
      "name": "الرَّؤُوفُ",
      "meaning": "المتعطف على المذنبين.",
      "reflection": "الله هو الرؤوف، فاطلب منه العفو."
    },
    {
      "name": "مَالِكُ الْمُلْكِ",
      "meaning": "المتصرف في ملكه كيف يشاء.",
      "reflection": "الله هو مالك الملك، فاعترف بسيادته."
    },
    {
      "name": "ذُو الْجَلَالِ وَالإكْرَامِ",
      "meaning":
          "المنفرد بصفات الجلال والكمال والعظمة، المختص بالإكرام والكرامة.",
      "reflection": "الله ذو الجلال والإكرام، فتعامل معه بكل إجلال وتقدير."
    },
    {
      "name": "المُقْسِط",
      "meaning": "العادل في حكمه، الذي ينتصف للمظلوم من الظالم.",
      "reflection": "الله هو المقسط، فثق في عدله ورؤيته."
    },
    {
      "name": "الْجَامِعُ",
      "meaning":
          "جمع الكمالات كلها، ذاتًا ووصفًا وفعلًا، يجمع بين الخلائق المتماثلة والمتباينة.",
      "reflection": "الله هو الجامع، فثق في حكمته التي تجمع بين كل شيء."
    },
    {
      "name": "الْغَنِيُّ",
      "meaning": "لا يحتاج إلى شيء، وهو المستغني عن كل ما سواه.",
      "reflection": "الله هو الغني، فاعتمد عليه وحده ولا تعتمد على غيره."
    },
    {
      "name": "المُغْنِي",
      "meaning": "معطي الغنى لعباده، يغني من يشاء غناه.",
      "reflection": "الله هو المغني، فاطلب منه الغنى والبركة."
    },
    {
      "name": "الْمُعْطِي",
      "meaning": "أعطى كل شيء.",
      "reflection": "الله هو المعطي، فاطلب منه ما شئت من خير."
    },
    {
      "name": "المانِع",
      "meaning": "يمنع العطاء عمّن يشاء ابتلاءً أو حماية.",
      "reflection": "الله هو المانع، فاعلم أن كل شيء بحكمة."
    },
    {
      "name": "الضَّارّ",
      "meaning": "المقدر للضر على من أراد.",
      "reflection": "الله هو الضار، فاعرف أن كل ضر يمر بك هو اختبار من الله."
    },
    {
      "name": "النَّافِع",
      "meaning": "المقدر النفع والخير لمن أراد.",
      "reflection": "الله هو النافع، فاطلب النفع من الله وحده."
    },
    {
      "name": "النُّورُ",
      "meaning": "الهادي الرشيد الذي يرشد بهدايته من يشاء.",
      "reflection": "الله هو النور، فاطلب منه أن يهديك إلى طريقه المستقيم."
    },
    {
      "name": "الْهَادِي",
      "meaning": "المبين للخلق طريق الحق بكلامه، يهدي القلوب إلى معرفته.",
      "reflection": "الله هو الهادي، فاطلب الهداية منه."
    },
    {
      "name": "الْبَدِيعُ",
      "meaning": "لا يماثله أحد في صفاته، ولا في حكم من أحكامه.",
      "reflection": "الله هو البديع، فاعرف أن كل ما خلقه هو جديد ومبدع."
    },
    {
      "name": "البَاقِي",
      "meaning": "وحده له البقاء، الدائم الوجود.",
      "reflection": "الله هو الباقي، فاعلم أن كل شيء غيره فانٍ."
    },
    {
      "name": "الْوَارِثُ",
      "meaning": "الأبقى الدائم الذي يرث الخلائق بعد فناء الخلق.",
      "reflection": "الله هو الوارث، فكل شيء سيعود إليه."
    },
    {
      "name": "الرَّشِيد",
      "meaning": "أسعد من شاء بإرشاده، وأشقى من شاء بإبعاده.",
      "reflection": "الله هو الرشيد، فاطلب إرشاده في حياتك."
    },
    {
      "name": "الصَّبُورُ",
      "meaning": "الحليم الذي لا يعاجل العصاة.",
      "reflection": "الله هو الصبور، فكن صبورًا على البلاء."
    }
  ];

  late Map<String, String> _todaysName;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // تحديث الاسم تلقائيًا كل دقيقة
    _updateName();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateName();
    });
  }

  void _updateName() {
    final seed = DateTime.now().minute +
        DateTime.now().second; // تغيير عشوائي باستخدام الدقيقة والثانية
    final random = Random(seed);
    setState(() {
      _todaysName = names[random.nextInt(names.length)];
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // إيقاف الـ Timer عند التخلص من الودجت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "تعرف على ربك ❤️",
            //   style: GoogleFonts.cairo(
            //     fontSize: 16.sp,
            //     fontWeight: FontWeight.bold,
            //     color: isDark ? Colors.white : Colors.black87,
            //   ),
            // ),
            // const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image:
                      AssetImage("assets/images/pattern.webp"), // خلفية إسلامية
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F2027), const Color(0xFF2C5364)]
                      : [const Color(0xFFE0F7FA), const Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.cyan.withOpacity(0.3)
                      : Colors.cyan.shade100,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                    ).createShader(bounds),
                    child: Text(
                      _todaysName['name']!,
                      style: GoogleFonts.amiri(
                        fontSize: context.isTab ? 15.sp : 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // Color is ignored by ShaderMask but required
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: 50,
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _todaysName['meaning']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                  fontFamily: "cairo",
                      fontSize: context.isTab ? 10.sp : 14.sp,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.cyan.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.cyan.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 20, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _todaysName['reflection']!,
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: context.isTab ? 9.sp : 12.sp,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
