import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
// ignore: unused_import
import 'package:muslimdaily/app/core/widgets/kButtons.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';
import 'package:muslimdaily/app/features/Khatmah/view/KhatmahDashboard.dart';
import 'package:share_plus/share_plus.dart';

/// يبني خطة يومية من أرقام الأجزاء: [[1,2], [3], [4,5], ...]
/// - days: عدد الأيام
/// - totalJuz: إجمالي الأجزاء (افتراضي 30)
/// - startJuz: أول جزء يبدأ منه التقسيم (افتراضي 1)

List<List<int>> _buildDailyJuzPlan(
  int days, {
  int totalJuz = 30,
  int startJuz = 1,
}) {
  if (days <= 0 || totalJuz <= 0) return const [];

  // توزيع عادل: أول (remainder) أيام تأخذ +1
  final base = totalJuz ~/ days;
  int remainder = totalJuz % days;

  final perDay = List<int>.generate(
    days,
    (_) => base + (remainder-- > 0 ? 1 : 0),
  );

  final plan = <List<int>>[];
  int current = startJuz; // 1-based

  for (final count in perDay) {
    if (current > (startJuz + totalJuz - 1)) {
      // خلّصنا كل الأجزاء
      plan.add(const []);
      continue;
    }

    final end = (current + count - 1);
    final endClamped = end.clamp(current, startJuz + totalJuz - 1);

    final today = <int>[];
    for (int j = current; j <= endClamped; j++) {
      today.add(j);
    }
    plan.add(today);

    current = endClamped + 1;
  }

  // لو لسه في أيام زيادة بعد انتهاء الأجزاء، تفضل فاضية
  while (plan.length < days) {
    plan.add(const []);
  }

  return plan;
}

// ====== شاشتك مع الدمج ======

class CreateKhatmahScreen extends StatefulWidget {
  const CreateKhatmahScreen({super.key});

  @override
  State<CreateKhatmahScreen> createState() => _CreateKhatmahScreenState();
}

class _CreateKhatmahScreenState extends State<CreateKhatmahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: "ختمة جديدة");
  int _days = 30;
  String _distribution = "صفحات"; // "صفحات" أو "أجزاء"

  void _saveKhatmah() {
    if (!_formKey.currentState!.validate()) return;

    // final khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    final khatmahBox = Hive.box<KhatmahModel>('khatmahBox');
    final plansBox = Hive.box('khatmahPlans');

    const int totalPages = 604; // عدّله لو مصحفك مختلف

    // نولّد id الآن عشان نربط به الخطة في khatmahPlans
    final String khId = DateTime.now().toIso8601String();

    // في وضع "صفحات": نفس منطقك الحالي
    if (_distribution == "صفحات") {
      final int dailyPages = (totalPages / _days).ceil();
      final newKhatmah = KhatmahModel(
        id: khId,
        title: _titleController.text,
        totalPages: totalPages,
        currentPage: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _days)),
        dailyPages: dailyPages,
      );
      khatmahBox.add(newKhatmah);

      // نخزّن نوع التوزيع فقط في plansBox (اختياري للمعلومة)
      plansBox.put(khId, {
        'distributionType': 'pages',
        'days': _days,
      });
    } else {
      // في وضع "أجزاء": نبني خطة يومية بالأجزاء
      final plan = _buildDailyJuzPlan(_days); // [[1,2],[3],[4,5],...]
      final planJson = jsonEncode(plan);

      // في وضع "أجزاء" مش هنستخدم dailyPages (خليه 0 أو سيبه كما تحب)
      final newKhatmah = KhatmahModel(
        id: khId,
        title: _titleController.text,
        totalPages: totalPages,
        currentPage: 0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: _days)),
        dailyPages: 0, // غير مستخدم مع الأجزاء
      );
      khatmahBox.add(newKhatmah);

      // نحفظ الخطة ونوع التوزيع في بوكس منفصل
      plansBox.put(khId, {
        'distributionType': 'ajzaa',
        'days': _days,
        'currentDayIndex': 0, // 0-based
        'dailyPlanJson': planJson, // List<List<int>>
      });

      // (اختياري) للديبج:
      // for (int i = 0; i < plan.length; i++) {
      //   debugPrint('اليوم ${i+1}: ${plan[i].isEmpty ? "—" : "أجزاء ${plan[i].first}..${plan[i].last}"}');
      // }
    }

    // (اختياري) جدولة إشعار… نفس كودك المعلّق

    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const KhatmahDashboard(),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const hadith1 =
        'اقْرَؤوا القُرْآنَ؛ فإنَّهُ يأتي يومَ القيامةِ شفيعًا لأصحابهِ.';
    const source1 = 'رواه مسلم (804)';

    const hadith2 =
        'قال ﷺ لعبد الله بن عمرو: "اقرأِ القُرآنَ في شَهرٍ" ... ثم قال: "فاقرأْه في سَبعٍ ولا تَزِدْ على ذلك".';
    const source2 = 'البخاري (5054) ومسلم (1159)';

// داخل الواجهة:
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          // backgroundColor: AppStyle.bgColors,
          // appBar: AppBar(
          //   leading: const CupertinoNavigationBarBackButton(color: Colors.black),
          //   centerTitle: true,
          //   title: TextWidget(title:
          //   'إنشاء ختمة جديدة',
          //     // style: GoogleFonts.cairo(
          //     //   color: Colors.green,
          //     //   fontWeight: FontWeight.bold,
          //     //   fontSize: context.isTab ? 12.sp : 18.sp,
          //     // ),
          //   ),
          // ),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                context.isTab ? 70 : 50),
            child: AppBar(
              leading: CupertinoNavigationBarBackButton(
                color: isDark ? Colors.white : Colors.black,
              ),
              // actions: [
              //   IconButton(
              //     onPressed: () => Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => CreateKhatmahScreen(),
              //       ),
              //     ),
              //     icon: const Icon(Icons.add),
              //   )
              // ],
              centerTitle: true,
              title: Text(
                'إنشاء ختمة جديدة',
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
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AnimationLimiter(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        const HadithCarouselCard(),
                        const SizedBox(height: 30),

                        // اسم الختمة
                        _buildSectionLabel("اسم الختمة"),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _titleController,
                               style: TextStyle(
                          fontFamily: "cairo",fontSize: 14.sp),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              border: InputBorder.none,
                              hintText: "مثال: ختمة رمضان",
                              hintStyle: TextStyle(
                                  fontFamily: "cairo",color: Colors.grey),
                              prefixIcon:
                                  Icon(Icons.edit, color: Colors.green),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "أدخل اسم الختمة"
                                : null,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // مدة الختمة بالأيام
                        _buildSectionLabel("مدة الختمة (بالأيام)"),
                        const SizedBox(height: 10),
                        FormField<int>(
                          validator: (value) => value == null
                              ? "من فضلك اختر مدة الختمة بالأيام"
                              : null,
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<int>(
                                      isExpanded: true,
                                      hint: Text(
                                        "اختر عدد الايام",
                                        style: TextStyle(
                                            fontFamily: "cairo",
                                            fontSize: 14.sp,
                                            color: Colors.grey),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          alignment: AlignmentGeometry.centerRight,
                                            value: 7, child: Text("7 أيام")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 10, child: Text("10 أيام")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 15, child: Text("15 يوم")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 20, child: Text("20 يوم")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 30, child: Text("30 يوم")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 60, child: Text("60 يوم")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: 90, child: Text("90 يوم")),
                                      ],
                                      value: _days,
                                      onChanged: (v) {
                                        setState(() => _days = v!);
                                        state.didChange(v);
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 55,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, right: 10),
                                    child: Text(state.errorText!,
                                        style: TextStyle(
                                            fontFamily: "cairo",
                                            color: Colors.red, fontSize: 12.sp)),
                                  )
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 25),

                        // طريقة التوزيع
                        _buildSectionLabel("طريقة التوزيع"),
                        const SizedBox(height: 10),
                        FormField<String>(
                          validator: (value) => value == null || value.isEmpty
                              ? "من فضلك اختر طريقة التوزيع"
                              : null,
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text(
                                        "اختر طريقة التوزيع",
                                        style: TextStyle(
                                            fontFamily: "cairo",
                                            fontSize: 14.sp,
                                            color: Colors.grey),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: "صفحات",
                                            child: Text("صفحات")),
                                        DropdownMenuItem(
                                            alignment: AlignmentGeometry.centerRight,
                                            value: "أجزاء",
                                            child: Text("أجزاء")),
                                      ],
                                      value: _distribution,
                                      onChanged: (v) {
                                        setState(() => _distribution = v!);
                                        state.didChange(v);
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 55,
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, right: 10),
                                    child: Text(state.errorText!,
                                           style: TextStyle(
                          fontFamily: "cairo",
                                            color: Colors.red, fontSize: 12.sp)),
                                  )
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // زرار الحفظ
                        Center(
                          child: InkWell(
                            onTap: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _saveKhatmah();
                              }
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.7,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                // gradient: LinearGradient(
                                //   colors: [KColors.primaryColor, Color(0xFF4CAF50)],
                                //   begin: Alignment.topLeft,
                                //   end: Alignment.bottomRight,
                                // ),
                                color: KColors.primaryColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: KColors.primaryColor.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "ابدأ الختمة",
                                     style: TextStyle(
                          fontFamily: "cairo",
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Text(
        text,
           style: TextStyle(
                          fontFamily: "cairo",
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: context.isDark
              ? Colors.white70
              : Colors.black87,
        ),
      ),
    );
  }
}
// class CustomButton extends StatelessWidget {
//   const CustomButton(
//       {Key? key,
//         required this.title,
//         this.width = 425,
//         this.height,
//         this.radius = 30,
//         this.backgroundColor,
//         this.fontSize,
//         this.horizontalPadding,
//         this.verticalPadding,
//         this.fontWeight,
//         this.margin,
//         required this.onTap,
//         this.style,
//         this.decoration,
//         this.textColor,
//         this.hasBackgroundColor = true,
//         this.borderColor,
//         this.iconWidget})
//       : super(key: key);
//
//   final void Function()? onTap;
//   final String title;
//   final double? width, height;
//   final Color? backgroundColor;
//   final double? radius;
//   final FontWeight? fontWeight;
//   final double? fontSize;
//   final TextStyle? style;
//   final double? horizontalPadding, verticalPadding;
//   final BoxDecoration? decoration;
//   final Widget? iconWidget;
//   final bool hasBackgroundColor;
//   final Color? textColor, borderColor;
//   final EdgeInsetsGeometry? margin;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         alignment: Alignment.center,
//         // height: height,
//         // width: width.w,
//         padding: EdgeInsets.symmetric(
//             vertical: verticalPadding ?? 14.h,
//             horizontal: horizontalPadding ?? 0),
//         // margin: margin?? EdgeInsets.symmetric(horizontal: 8.w),
//         decoration: decoration ??
//             BoxDecoration(
//                 color: backgroundColor,
//                 // gradient: hasBackgroundColor ? KColors.gradientBtn : null,
//                 borderRadius: radius == null
//                     ? BorderRadius.circular(10.w)
//                     : BorderRadius.circular(radius!.w),
//                 border: Border.all(
//                     color: borderColor ??
//                         (CentralizedCubit.isDarkMode == true
//                             ? KColors.greyColor
//                             : KColors.whiteColor))),
//         child: iconWidget != null
//             ? Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Expanded(
//               child: TextWidget(
//                 title: title,
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 color: textColor ?? Colors.white,
//               ),
//             ),
//             iconWidget!
//           ],
//         )
//             : TextWidget(
//           title: title,
//           color: textColor ?? Colors.white,
//           fontSize: fontSize,
//           textAlign: TextAlign.center,
//           maxLines: 1,
//         ),
//       ),
//     );
//   }
// }

class HadithCarouselCard extends StatefulWidget {
  const HadithCarouselCard({super.key});

  @override
  State<HadithCarouselCard> createState() => _HadithCarouselCardState();
}

class _HadithCarouselCardState extends State<HadithCarouselCard> {
  // قائمة الأحاديث
  final List<Map<String, String>> _hadiths = [
    {
      "title": "حديث يحث على قراءة القرآن",
      "text":
          " عبد الله بن عمرو أن رسول الله صلى الله عليه وسلم قال: لم يفقه من قرأ القرآن في أقل من ثلاثِ.",
      "source": "رواه الترمذي وأبو داود والدارمي",
    },
    {
      "title": "حديث عن مدة ختم القرآن",
      "text":
          " قال رسول الله صلى الله عليه وسلم: «من قرأ حرفًا من كتاب الله فله به حسنة، والحسنة بعشر أمثالها، لا أقول: ألم حرف، ولكن ألف حرف، ولام حرف، وميم حرف",
      "source": "رواه الترمذي"
    },
    {
      "title": "فضل أهل القرآن",
      "text":
          "قال رسول الله صلى الله عليه وسلم:مثل المؤمن الذي يقرأ القرآن مثل الأُترُجّة ريحها طيب وطعمها طيب، ومثل المؤمن الذي لا يقرأ القرآن مثل التمرة طعمها طيب ولا ريح لها، ومثل الفاجر الذي يقرأ القرآن كمثل الريحانة ريحها طيب وطعمها مر، ومثل الفاجر الذي لا يقرأ القرآن كمثل الحنظلة طعمها مر ولا ريح لها",
      "source": "رواه البخاري",
    },
    {
      "title": "فضل أهل القرآن",
      "text":
          "عن عبد الله بن عمرو: أنه سأل النبي صلى الله عليه وسلم في كم ‏يُقرأ القرآن؟ قال: «في أربعين يومًا، ثم قال في شهر...». وفي رواية البخاري قال له: «اقرأ القرآن في كل شهر، قلت: إني أجد قوة، قال: فاقرأه في سبع ولا تزد",
      "source": "رواه البخاري",
    },
  ];
  final List<Color> _bgColors = [
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
  ];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // مؤقت يغير الحديث كل 5 ثواني
    _timer = Timer.periodic(const Duration(seconds: 14), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _hadiths.length;
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
    final currentHadith = _hadiths[_currentIndex];
    final current = _hadiths[_currentIndex];
    final bgColor =
        _bgColors[_currentIndex % _bgColors.length].withOpacity(0.15);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        // height: 250,
        child: Card(
          color: CupertinoColors.black,
          // elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  style: BorderStyle.solid,
                  color: KColors.accentColor,
                  width: 2.9)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: TextWidget(
                  title: currentHadith["title"]!,
                  color: CupertinoColors.systemYellow,
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 12),
                TextWidget(
                  title: currentHadith["text"]!,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentHadith["source"]!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(
                          text:
                              "${currentHadith["title"]}\n${currentHadith["text"]}\n${currentHadith["source"]}",
                        ));
                        if (context.mounted) {
                          KHelper.showSuccess(message: 'تم نسخ الحديث');
                        }
                      },
                      icon: Icon(
                        Icons.copy,
                        size: 18,
                        color: KColors.orang2Color,
                      ),
                      label: TextWidget(
                        title: 'نسخ',
                        fontSize: 13.sp,
                        color: KColors.orang2Color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TextButton.icon(
                    //   onPressed: () {
                    //     Share.share(
                    //         "${currentHadith["title"]}\n${currentHadith["text"]}\n${currentHadith["source"]}");
                    //   },
                    //   icon:  Icon(Icons.share, size: 18,color: KColors.whiteColor,),
                    //   label:  TextWidget(title: 'مشاركة', fontSize: 13.sp,color:KColors.whiteColor ,),
                    // ),
                    TextButton.icon(
                      onPressed: () {
                        final shareText = """
🌺✨🌿✨🌺✨🌿✨🌺✨🌿

📿 ${currentHadith["title"]}

${currentHadith["text"]}

📘 المصدر: ${currentHadith["source"]}

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
                        Share.share(shareText);
                      },
                      icon: Icon(Icons.share,
                          size: 18, color: KColors.whiteColor),
                      label: TextWidget(
                        title: 'مشاركة',
                        fontSize: 13.sp,
                        color: KColors.whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
