import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/core/widgets/kButtons.dart';
import 'package:muslimdaily/app/features/Khatmah/data/PlanData.dart';
import 'package:muslimdaily/app/features/Khatmah/data/khatmah_model.dart';
import 'package:muslimdaily/app/features/Khatmah/view/CreateKhatmahView.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:quran_library/quran.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';


class KhatmahDashboard extends StatefulWidget {
  const KhatmahDashboard({super.key});

  @override
  State<KhatmahDashboard> createState() => _KhatmahDashboardState();
}

class _KhatmahDashboardState extends State<KhatmahDashboard>
    with TickerProviderStateMixin {
  late final Box<KhatmahModel> box;
  late final Box plansBox; // khatmahPlans
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    box = Hive.box<KhatmahModel>('khatmahBox');
    plansBox = Hive.box('khatmahPlans'); // لازم يكون مفتوح في main
    _tabController = TabController(length: 2, vsync: this);
  }

  // ------------------ Helpers خاصة بوضع "أجزاء" ------------------

  bool _isAjzaa(KhatmahModel k) {
    final data = plansBox.get(k.id);
    if (data is Map && data['distributionType'] == 'ajzaa') return true;
    return false;
  }

  PlanData? _getPlanData(KhatmahModel k) {
    final data = plansBox.get(k.id);
    if (data is! Map) return null;
    if (data['distributionType'] != 'ajzaa') return null;

    final int days = (data['days'] ?? 0) as int;
    final int currentDayIndex = (data['currentDayIndex'] ?? 0) as int;
    final String json = (data['dailyPlanJson'] ?? '[]') as String;

    final List<dynamic> raw = jsonDecode(json);
    final List<List<int>> plan =
        raw.map<List<int>>((e) => (e as List).cast<int>()).toList();

    return PlanData(days: days, currentDayIndex: currentDayIndex, plan: plan);
  }

  /// صياغة نص ورد اليوم في وضع الأجزاء
  String _todayWirdAjzaa(PlanData p) {
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) {
      return "لا يوجد ورد اليوم";
    }
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return "—";
    if (today.length == 1) return "الجزء ${today.first}";
    return "الأجزاء ${today.first}–${today.last}";
  }

  /// تقدّم تقريبي في وضع الأجزاء = (اليوم الحالي / إجمالي الأيام)
  double _progressPercentAjzaa(PlanData p) {
    if (p.days <= 0) return 0;
    final readDays = p.currentDayIndex; // أيام تم إكمالها
    final pct = readDays / p.days;
    return pct.clamp(0.0, 1.0);
  }

  /// الأيام المتبقية في وضع الأجزاء
  int _daysLeftAjzaa(PlanData p) {
    final left = p.days - p.currentDayIndex;
    return left < 0 ? 0 : left;
    // لو عايز تخصم اليوم الجاري: p.days - (p.currentDayIndex + 1)
  }

  void jumpToJoz({required int jozNumber, required BuildContext context}) {
    QuranLibrary().jumpToJoz(jozNumber);
    Navigator.pop(context);
    debugPrint("jumpToJoz($jozNumber) called");
  }

  /// الانتقال لأوّل جزء في ورد اليوم باستخدام jumpToJoz
  void _goToTodayAjzaa(KhatmahModel k) {
    final p = _getPlanData(k);
    if (p == null) return;
    if (p.currentDayIndex < 0 || p.currentDayIndex >= p.plan.length) return;
    final today = p.plan[p.currentDayIndex];
    if (today.isEmpty) return;

    final firstJoz = today.first;
    jumpToJoz(jozNumber: firstJoz, context: context);
  }

  void jumpToPage({required int pageNumber, required BuildContext context}) {
    QuranLibrary().jumpToPage(pageNumber);
    Navigator.pop(context);
    debugPrint("jumpToJoz($pageNumber) called");
  }

  /// الانتقال لأول صفحة في ورد اليوم في وضع الصفحات
  void _goToTodayPages(KhatmahModel k) {
    if (k.isCompleted) return;

    // الصفحة الحالية التي المفروض يبدأ منها اليوم
    final todayPage = k.currentPage + 1;

    if (todayPage > k.totalPages) return;

    jumpToPage(pageNumber: todayPage, context: context);
  }

  /// Dialog التهنئة عند اكتمال الختمة
  void _showCompletionDialog(KhatmahModel k) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: [
                Lottie.asset("assets/json/congrats.json"),
                const SizedBox(width: 8),
                Text(
                  "تهانينا!",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              textAlign: TextAlign.center,
              'لقد أتممت الختمة "${k.title}". بارك الله فيك وجعلها في ميزان حسناتك.',
              style: GoogleFonts.cairo(height: 1.4),
            ),
            actions: [
              // TextButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: Text("موافق", style: GoogleFonts.cairo()),
              // ),
              Center(
                  child: KButtons.circularIconButton(
                      fillColor: KColors.primaryColor,
                      iconSize: 35,
                      iconData: CupertinoIcons.check_mark_circled,
                      radius: 60,
                      onPressed: () => Navigator.pop(context),
                      iconColor: Colors.white))
            ],
          ),
        );
      },
    );
  }

  /// تأشير اليوم كمقروء في وضع الأجزاء - ترجع true لو الختمة اكتملت الآن
  bool _markTodayReadAjzaa(KhatmahModel k) {
    final raw = plansBox.get(k.id);
    if (raw is! Map) return false;
    if (raw['distributionType'] != 'ajzaa') return false;

    final data = Map<String, dynamic>.from(raw);
    final int days = (data['days'] ?? 0) as int;
    int idx = (data['currentDayIndex'] ?? 0) as int;

    // لو الختمة خلصت، لا تفعل شيء
    if (idx >= days) return false;

    // اعتبر اليوم الحالي تمّ قراءته → انتقل لليوم التالي
    idx = (idx + 1).clamp(0, days);

    data['currentDayIndex'] = idx;
    plansBox.put(k.id, data);

    // سجّل تاريخ التأشير في موديلك (لأجل الإحصاءات)
    k.progressDates.add(DateTime.now());

    bool justCompleted = false;
    if (idx >= days) {
      k.isCompleted = true;
      k.endDate = DateTime.now(); // التاريخ الفعلي
      justCompleted = true;
    }

    k.save();
    setState(() {});
    return justCompleted;
  }

  /// منطق الصفحات: ترجع true لو الختمة اكتملت الآن
  bool _markTodayReadPages(KhatmahModel k) {
    if (k.isCompleted) return false;

    final increment = k.dailyPages;
    k.currentPage += increment;

    bool justCompleted = false;

    if (k.currentPage >= k.totalPages) {
      k.currentPage = k.totalPages;
      k.isCompleted = true;
      k.endDate = DateTime.now(); // التاريخ الفعلي
      justCompleted = true;
    }

    k.progressDates.add(DateTime.now());
    k.save();
    setState(() {});
    return justCompleted;
  }

  // واجهة موحّدة للزر
  void _markTodayRead(int index) {
    final khatma = box.getAt(index);
    if (khatma == null) return;
    if (khatma.isCompleted) return;

    bool completedNow;
    if (_isAjzaa(khatma)) {
      completedNow = _markTodayReadAjzaa(khatma);
    } else {
      completedNow = _markTodayReadPages(khatma);
    }

    if (completedNow) {
      _showCompletionDialog(khatma);
    }
  }

  // حذف ختمة
  void _deleteKhatmah(int index) {
    final k = box.getAt(index);
    if (k != null) {
      // احذف خطتها إن وُجدت
      plansBox.delete(k.id);
    }
    box.deleteAt(index);
    KHelper.showSuccess(message: "تم حذف ${k?.title} بنجاح");
    setState(() {});
  }

  // ------------------ UI ------------------

  Widget _buildKhatmahCard(KhatmahModel k, int index) {
    final isAjzaa = _isAjzaa(k);
    double progressPercent;
    int daysLeft;
    String todayWirdText;

    if (isAjzaa) {
      final p = _getPlanData(k)!;
      progressPercent = _progressPercentAjzaa(p);
      daysLeft = _daysLeftAjzaa(p);
      todayWirdText = _todayWirdAjzaa(p);
    } else {
      progressPercent = k.progressPercent;
      daysLeft = k.daysLeft;
      todayWirdText = k.todayWird; // من موديلك
    }

    final pagesLeft =
        k.pagesLeft; // قد لا يعكس “أجزاء”، لكنه لا يضر للعرض العام

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)], // Premium Dark Teal Gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decoration
            Positioned(
              top: -20,
              left: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircularPercentIndicator(
                        radius: 55,
                        lineWidth: 8,
                        percent: progressPercent > 1 ? 1 : progressPercent,
                        center: Text(
                          "${(progressPercent * 100).toStringAsFixed(1)}%",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        progressColor: const Color(0xFFFFD700), // Gold
                        backgroundColor: Colors.white.withOpacity(0.1),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 1000,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    k.title,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _openKhatmahOptions(k, index),
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white70,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "ورد اليوم: $todayWirdText",
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(pagesLeft.toString(), "صفحات باقية", Icons.auto_stories),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _statItem(daysLeft.toString(), "أيام متبقية", Icons.calendar_today),
                        Container(width: 1, height: 30, color: Colors.white24),
                        _statItem(
                          k.isCompleted ? "Completed" : "Active", 
                          k.isCompleted ? "مكتملة" : "جارية", 
                          k.isCompleted ? Icons.check_circle : Icons.timelapse,
                           color: k.isCompleted ? Colors.greenAccent : Colors.amberAccent
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons Functionality
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: k.isCompleted
                              ? null
                              : () => _markTodayRead(index),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("أتممت ورد اليوم",style: TextStyle(fontFamily: "cairo"),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                              onPressed: k.isCompleted
                                  ? null
                                  : () => isAjzaa ? _goToTodayAjzaa(k) : _goToTodayPages(k),
                          icon: const Icon(Icons.play_arrow_sharp),
                          label: const Text("اذهب لورد اليوم",style: TextStyle(fontFamily: "cairo"),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KColors.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withOpacity(0.15),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: IconButton(
                      //     onPressed: k.isCompleted
                      //         ? null
                      //         : () => isAjzaa ? _goToTodayAjzaa(k) : _goToTodayPages(k),
                      //     icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      //     tooltip: "اذهب لورد اليوم",
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white54,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  void _openKhatmahOptions(KhatmahModel k, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.redAccent,
                  ),
                  title: const TextWidget(title: "حذف الختمة"),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteKhatmah(index);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.replay_outlined),
                  title: const TextWidget(title: "إعادة تعيين التقدم"),
                  onTap: () {
                    Navigator.pop(context);

                    // Reset في الصفحات
                    k.currentPage = 0;
                    k.isCompleted = false;
                    k.progressDates.clear();
                    k.save();

                    // Reset في الأجزاء (لو موجود)
                    final data = plansBox.get(k.id);
                    if (data is Map && data['distributionType'] == 'ajzaa') {
                      final newMap = Map<String, dynamic>.from(data);
                      newMap['currentDayIndex'] = 0;
                      plansBox.put(k.id, newMap);
                    }
                    KHelper.showSuccess(
                        message: "تم اعاده التعيين ${k.title} بنجاح");

                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = box.values.where((k) => !k.isCompleted).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateKhatmahScreen(),
                  ),
                ),
                icon: const Icon(Icons.add),
              )
            ],
            centerTitle: true,
            title: Text(
              "الختمات الحالية",
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: currentList.isEmpty
            ? Center(
                child: Column(
                  spacing: 25,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/json/Koran im Ramadan lesen.json"),
                    TextWidget(
                      title: "لاتوجد اي ختمات قد قمت بإنشأها من قبل ",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    TextWidget(
                      title: "قم بانشاء ختمتك الان.",
                      fontSize: 14.sp,
                      height: 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width / 2,
                        child: CustomButton(
                          fontSize: 14.sp,
                          verticalPadding: 10,
                          backgroundColor: KColors.primaryColor,
                          width: MediaQuery.sizeOf(context).width / 3,
                          title: "انشاء ختمة جديدة",
                          borderColor: KColors.primaryColor,
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateKhatmahScreen(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 80, left: 16, right: 16),
                  itemCount: currentList.length,
                  itemBuilder: (_, i) {
                    final k = currentList[i];
                    final index = box.values.toList().indexOf(k);
                    return AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildKhatmahCard(k, index),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
