import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/DrawerWidget.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:quran_library/quran.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranViewItemBuilder extends StatefulWidget {
  const QuranViewItemBuilder({super.key});

  @override
  _QuranViewItemBuilderState createState() => _QuranViewItemBuilderState();
}

class _QuranViewItemBuilderState extends State<QuranViewItemBuilder>
    with SingleTickerProviderStateMixin {
  var selectedFontSize;

  // late List<DrawerModle?> topBar = [
  //   DrawerModle(
  //       icon: Icons.search, title: "البحث بالاية", route: "/ayaSearchScreen"),
  //   DrawerModle(
  //       icon: Icons.gpp_good_outlined,
  //       title: "التفسير",
  //       route: Routes.tafsirQuranRoute),
  //
  //   DrawerModle(
  //       icon: Icons.list, title: "فهرس القران الكريم", route: "/ListScreen"),
  //   DrawerModle(
  //       icon: Icons.dashboard_customize_outlined,
  //       title: "الاجزاء",
  //       route: Routes.jozzaListScreenRoute),
  //   DrawerModle(
  //       icon: Icons.category_outlined,
  //       title: "الاحزاب",
  //       route: Routes.hizbeListScreenRoute),
  //   DrawerModle(
  //       icon: Icons.chrome_reader_mode_outlined,
  //       title: "انشاء ختمة جديدة",
  //       isRepl: true,
  //       route: "/KhatmahHome"),
  //   DrawerModle(
  //       icon: Icons.preview_outlined,
  //       title: "الختمات المنجزه",
  //       route: "/compplateKhatna"),
  //
  //   DrawerModle(
  //     icon: Icons.bookmark_add_outlined,
  //     title: "اضافة علامة للصفحة",
  //     onTap: () => _saveBookmark(_currentPage!),
  //   ),
  //   DrawerModle(
  //     icon: Icons.bookmark_remove_outlined,
  //     title: " ازالة العلامه",
  //     onTap: _delBookmark,
  //   ),
  //   DrawerModle(
  //     icon: Icons.navigation_outlined,
  //     title: "انتقال الي العلامه",
  //     onTap: _goToBookmark,
  //   ),
  //   DrawerModle(
  //       icon: Icons.bookmarks_outlined,
  //       title: "الايات المحفوظة",
  //       route: "/ayaBookmarkScreen"),
  //   DrawerModle(
  //       icon: Icons.info_outline,
  //       title: "دعاء ختم القران الكريم",
  //       route: Routes.quranKhitamRoute),
  //   DrawerModle(
  //       icon: Icons.favorite_border,
  //       title: "فضل قرأه القران",
  //       route: Routes.quranLoveRoute),
  //
  //   // DrawerModle(
  //   //     icon: Icons.dark_mode_outlined,
  //   //     title: "الوضع الليلي",
  //   //     onTap: _changeMode),
  // ];
  late List<DrawerSection> drawerSections = [
    DrawerSection(
      title: "بَحْثٌ وَتَفْسِيرٌ",
      items: [
        DrawerModle(
          icon: Icons.search,
          title: "البَحْثُ بِالآيَةِ",
          route: "/ayaSearchScreen",
        ),
        DrawerModle(
          icon: Icons.gpp_good_outlined,
          title: "التَّفْسِيرُ",
          route: Routes.tafsirQuranRoute,
        ),
      ],
    ),
    DrawerSection(
      title: "فِهْرِسُ القُرْآنِ",
      items: [
        DrawerModle(
          icon: Icons.list,
          title: "فِهْرِسُ القُرْآنِ الكَرِيمِ",
          route: "/ListScreen",
        ),
        DrawerModle(
          icon: Icons.dashboard_customize_outlined,
          title: "الأَجْزَاءُ",
          route: Routes.jozzaListScreenRoute,
        ),
        DrawerModle(
          icon: Icons.category_outlined,
          title: "الأَحْزَابُ",
          route: Routes.hizbeListScreenRoute,
        ),
      ],
    ),
    DrawerSection(
      title: "الخَتْمَاتُ",
      items: [
        DrawerModle(
          icon: Icons.chrome_reader_mode_outlined,
          title: "إِنْشَاءُ خَتْمَةٍ جَدِيدَةٍ",
          isRepl: true,
          route: "/KhatmahHome",
        ),
        DrawerModle(
          icon: Icons.preview_outlined,
          title: "الخَتْمَاتُ المُنْجَزَةُ",
          route: "/compplateKhatna",
        ),
      ],
    ),
    DrawerSection(
      title: "العَلامَاتُ",
      items: [
        DrawerModle(
          icon: Icons.bookmark_add_outlined,
          title: "إِضَافَةُ عَلَامَةٍ لِلصَّفْحَةِ",
          onTap: () => _saveBookmark(_currentPage!),
        ),
        DrawerModle(
          icon: Icons.bookmark_remove_outlined,
          title: "إِزَالَةُ العَلَامَةِ",
          onTap: _delBookmark,
        ),
        DrawerModle(
          icon: Icons.navigation_outlined,
          title: "الِانْتِقَالُ إِلَى العَلَامَةِ",
          onTap: _goToBookmark,
        ),
        DrawerModle(
          icon: Icons.bookmarks_outlined,
          title: "الآيَاتُ المَحْفُوظَةُ",
          route: "/ayaBookmarkScreen",
        ),
      ],
    ),
    DrawerSection(
      title: "عَنِ القُرْآنِ الكَرِيمِ",
      items: [
        DrawerModle(
          icon: Icons.info_outline,
          title: "دُعَاءُ خَتْمِ القُرْآنِ الكَرِيمِ",
          route: Routes.quranKhitamRoute,
        ),
        DrawerModle(
          icon: Icons.favorite_border,
          title: "فَضْلُ قِرَاءَةِ القُرْآنِ",
          route: Routes.quranLoveRoute,
        ),
        // DrawerModle(
        //   icon: Icons.dark_mode_outlined,
        //   title: "الوَضْعُ اللَّيْلِيُّ",
        //   onTap: _changeMode,
        // ),
      ],
    ),
  ];

  int? _currentPage = 0;
  int? _bookmarkedPage;

  @override
  void initState() {
    super.initState();
    _loadPages();
    QuranLibrary.init();
    selectedFontSize = "25";
  }

  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('last_page') ?? 0; // افتراضي الصفحة الأولى
    _bookmarkedPage = prefs.getInt('bookmark_page');

    setState(() {
      _currentPage = lastPage;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPage != null) {
        QuranLibrary().jumpToPage(_currentPage! + 1);
      }
    });
  }

  void _saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', page);
  }

  void _saveBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bookmark_page', page);
    setState(() {
      _bookmarkedPage = page;
    });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('✅ تم حفظ العلامة على الصفحة $page')),
    // );
    KHelper.showSuccess(message: ' ✅ تم حفظ العلامة على الصفحة $page ');
  }

  void _delBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookmark_page');
    setState(() {
      _bookmarkedPage = null;
    });
    KHelper.showSuccess(message: "تم ازالة العلامة");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('✅ تم ازالة العلامة')),
    // );
  }

  void _goToBookmark() {
    if (_bookmarkedPage != null) {
      setState(() {
        _currentPage = _bookmarkedPage!;
        QuranLibrary().jumpToPage(_bookmarkedPage!);
      });
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('⚠️ لا توجد علامة محفوظة')),
      // );
      KHelper.showSuccess(message: " لا توجد علامة محفوظة");
    }
  }

  Widget _buildList(List<String> items, Function(int index) onTap) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, index) => ListTile(
        title: TextWidget(
          title: items[index],
        ),
        onTap: () => onTap(index),
      ),
    );
  }

  // bool isDark = false;
  //
  // void _changeMode() {
  //   setState(() {
  //     isDark = !isDark;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    QuranLibrary().currentPageNumber;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // خلفية السكافولد
        // drawer: DrawerWidget(
        //   "/surahListScreen",
        //   topBar: topBar,
        // ), // <<< هنا بتحط الـ Drawer
drawer: Padding(
  padding: const EdgeInsets.symmetric(vertical: 20),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25)
    ),
    child: DrawerWidget(
      "/surahListScreen",
      sections: drawerSections,
    ),
  ),
)
        ,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 80 : 50),
          child: AppBar(
            actions: [
              // InkWell(
              //   onTap: () {
              //     Navigator.pushNamed(context, "/ayaSearchScreen");
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(horizontal: 10),
              //     child: Icon(
              //       Icons.search,
              //       size: 30,
              //     ),
              //   ),
              // ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SurahAudioScreen(isDark: isDark),));
                },
                child:  Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    color: isDark?Colors.white:Colors.black,
                    Icons.play_circle_outlined,
                    size: 30,
                  ),
                ),
              ),
              FontsDownloadDialog(
                topBarStyle: QuranTopBarStyle(
                    iconColor: isDark ? Colors.white : AppColors.primary),
                downloadFontsDialogStyle: DownloadFontsDialogStyle(
                  iconColor: isDark ? Colors.white : Colors.blueAccent,
                  headerTitle: 'الخطوط المتاحة',
                  titleColor: isDark ? Colors.white : Colors.black,
                  notes:
                      'لجعل مظهر المصحف مشابه لمصحف المدينة يمكنك تحميل خط مصحف المدينة من اسفل وتفعيله بدلا من الخط الاساسي',

                  // notes: 'لجعل مظهر المصحف مطابقًا لمصحف المدينة قم بتحميل خط مصحف المدينة.',
                  notesColor: isDark ? Colors.white : Colors.black,
                  linearProgressBackgroundColor: Colors.blue.shade100,
                  linearProgressColor: Colors.blue,
                  downloadButtonBackgroundColor: Colors.blue,
                  downloadingText: 'جارِ التحميل',
                  backgroundColor: isDark
                      ? const Color(0xff1E1E1E)
                      : const Color(0xFFF7EFE0),
                ),
                languageCode: 'ar',
                isFontsLocal: false, // تحميل من النت
                isDark: isDark,
              ),
            ],
            centerTitle: true,
            title: Text(
              "القران الكريم",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),

        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            // color: isDark ? Colors.black : AppStyle.bgColors,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black87],
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.zero,
              child: _currentPage == null
                  ? Center(
                      child:
                          KLoading.progressIOSIndicator(context: context)) // لحد ما يجيب الصفحة
                  : QuranLibraryScreen(
                ayahIconColor: isDark?AppStyle.scondColors: AppColors.primary,
                topBottomQuranStyle: TopBottomQuranStyle.defaults(
                  isDark: isDark,
                  context: context,
                ).copyWith(

                  pageNumberColor:isDark ? Colors.white : Colors.black ,
                  surahNameColor: isDark ? Colors.white : Colors.black,
                  hizbTextColor: isDark ? Colors.white : Colors.black,
                  juzTextColor: isDark ? Colors.white : Colors.black,
                ),
                ayahMenuStyle:
                AyahMenuStyle.defaults(isDark: isDark, context: context),
                      isDark: isDark,
                      pageIndex: _currentPage!,

                      topTitleChild: const SizedBox(),
                      useDefaultAppBar: false,

                      indexTabStyle: IndexTabStyle(
                        labelColor: isDark ? Colors.white : Colors.black,
                        accentColor: isDark ? Colors.white : Colors.black,
                      ),


                      // surahNameStyle: SurahNameStyle(
                      //
                      //   surahNameSize: 150,
                      //
                      //   surahNameColor:isDark?Colors.white: Colors.black, // اسم السورة
                      //
                      // ),

                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                          KHelper.showSuccess(
                            message: "الصفحة رقم ${page + 1}",
                            backgroundColor: Colors.black,
                          );
                        });
                        _saveCurrentPage(page);
                      },

                      parentContext: context,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============== نماذج البيانات ===============

// class Dhikr {
//   final String id;
//   final String text;
//   final int targetCount;
//   int currentCount;
//
//   Dhikr({
//     required this.id,
//     required this.text,
//     required this.targetCount,
//     this.currentCount = 0,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'text': text,
//     'targetCount': targetCount,
//     'currentCount': currentCount,
//   };
//
//   factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
//     id: json['id'],
//     text: json['text'],
//     targetCount: json['targetCount'],
//     currentCount: json['currentCount'] ?? 0,
//   );
// }
//
// class Wird {
//   final String id;
//   final String name;
//   final List<Dhikr> adhkar;
//   final DateTime createdAt;
//   int completedCount;
//   DateTime? lastCompletedDate;
//   String? reminderTime;
//   String category;
//   List<DateTime> completionHistory;
//
//   Wird({
//     required this.id,
//     required this.name,
//     required this.adhkar,
//     required this.createdAt,
//     this.completedCount = 0,
//     this.lastCompletedDate,
//     this.reminderTime,
//     this.category = 'عام',
//     List<DateTime>? completionHistory,
//   }) : completionHistory = completionHistory ?? [];
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'adhkar': adhkar.map((d) => d.toJson()).toList(),
//     'createdAt': createdAt.toIso8601String(),
//     'completedCount': completedCount,
//     'lastCompletedDate': lastCompletedDate?.toIso8601String(),
//     'reminderTime': reminderTime,
//     'category': category,
//     'completionHistory': completionHistory.map((d) => d.toIso8601String()).toList(),
//   };
//
//   factory Wird.fromJson(Map<String, dynamic> json) => Wird(
//     id: json['id'],
//     name: json['name'],
//     adhkar: (json['adhkar'] as List).map((d) => Dhikr.fromJson(d)).toList(),
//     createdAt: DateTime.parse(json['createdAt']),
//     completedCount: json['completedCount'] ?? 0,
//     lastCompletedDate: json['lastCompletedDate'] != null
//         ? DateTime.parse(json['lastCompletedDate'])
//         : null,
//     reminderTime: json['reminderTime'],
//     category: json['category'] ?? 'عام',
//     completionHistory: (json['completionHistory'] as List?)
//         ?.map((d) => DateTime.parse(d))
//         .toList() ??
//         [],
//   );
// }
//
// class UserStats {
//   int totalTasbihat;
//   int currentStreak;
//   int longestStreak;
//   int level;
//   List<String> achievements;
//   Map<String, int> dailyCompletions;
//   Map<String, int> hourlyActivity;
//
//   UserStats({
//     this.totalTasbihat = 0,
//     this.currentStreak = 0,
//     this.longestStreak = 0,
//     this.level = 1,
//     List<String>? achievements,
//     Map<String, int>? dailyCompletions,
//     Map<String, int>? hourlyActivity,
//   })  : achievements = achievements ?? [],
//         dailyCompletions = dailyCompletions ?? {},
//         hourlyActivity = hourlyActivity ?? {};
//
//   Map<String, dynamic> toJson() => {
//     'totalTasbihat': totalTasbihat,
//     'currentStreak': currentStreak,
//     'longestStreak': longestStreak,
//     'level': level,
//     'achievements': achievements,
//     'dailyCompletions': dailyCompletions,
//     'hourlyActivity': hourlyActivity,
//   };
//
//   factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
//     totalTasbihat: json['totalTasbihat'] ?? 0,
//     currentStreak: json['currentStreak'] ?? 0,
//     longestStreak: json['longestStreak'] ?? 0,
//     level: json['level'] ?? 1,
//     achievements: List<String>.from(json['achievements'] ?? []),
//     dailyCompletions: Map<String, int>.from(json['dailyCompletions'] ?? {}),
//     hourlyActivity: Map<String, int>.from(json['hourlyActivity'] ?? {}),
//   );
// }
//
// class GroupChallenge {
//   final String id;
//   final String name;
//   final int targetTasbihat;
//   final DateTime deadline;
//   Map<String, int> participants;
//
//   GroupChallenge({
//     required this.id,
//     required this.name,
//     required this.targetTasbihat,
//     required this.deadline,
//     Map<String, int>? participants,
//   }) : participants = participants ?? {};
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'targetTasbihat': targetTasbihat,
//     'deadline': deadline.toIso8601String(),
//     'participants': participants,
//   };
//
//   factory GroupChallenge.fromJson(Map<String, dynamic> json) => GroupChallenge(
//     id: json['id'],
//     name: json['name'],
//     targetTasbihat: json['targetTasbihat'],
//     deadline: DateTime.parse(json['deadline']),
//     participants: Map<String, int>.from(json['participants'] ?? {}),
//   );
// }
//
// // =============== مدير الإشعارات ===============
//
// class NotificationManager {
//   static final FlutterLocalNotificationsPlugin _notifications =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings();
//     const settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//     await _notifications.initialize(settings);
//   }
//
//   static Future<void> scheduleDailyReminder(
//       String wirdName,
//       TimeOfDay time,
//       ) async {
//     await _notifications.zonedSchedule(
//       wirdName.hashCode,
//       'تذكير بالورد 📿',
//       'حان وقت $wirdName',
//       _nextInstanceOfTime(time),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder',
//           'تذكير يومي',
//           channelDescription: 'إشعارات تذكير الأوراد اليومية',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   static TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final now = DateTime.now();
//     var scheduledDate = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(Duration(days: 1));
//     }
//     return TZDateTime.from(scheduledDate, local);
//   }
//
//   static Future<void> cancelReminder(String wirdName) async {
//     await _notifications.cancel(wirdName.hashCode);
//   }
// }
//
// // =============== مدير البيانات ===============
//
// class WirdManager {
//   static const String _awradKey = 'awrad_data';
//   static const String _statsKey = 'user_stats';
//   static const String _themeKey = 'app_theme';
//   static const String _soundKey = 'sound_enabled';
//   static const String _hapticKey = 'haptic_enabled';
//   static const String _challengesKey = 'group_challenges';
//   static const String _userNameKey = 'user_name';
//
//   Future<List<Wird>> loadAwrad() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_awradKey);
//     if (data == null) return [];
//     final List<dynamic> jsonList = json.decode(data);
//     return jsonList.map((j) => Wird.fromJson(j)).toList();
//   }
//
//   Future<void> saveAwrad(List<Wird> awrad) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String data = json.encode(awrad.map((w) => w.toJson()).toList());
//     await prefs.setString(_awradKey, data);
//
//     // تحديث الويدجت
//     await updateWidget(awrad);
//   }
//
//   Future<void> updateWidget(List<Wird> awrad) async {
//     final totalTasbihat = awrad.fold<int>(
//       0,
//           (sum, w) => sum + w.completedCount * w.adhkar.fold<int>(0, (s, d) => s + d.targetCount),
//     );
//     // await HomeWidget.saveWidgetData('total_tasbihat', totalTasbihat);
//     // await HomeWidget.updateWidget(
//     //   name: 'WirdWidgetProvider',
//     //   androidName: 'WirdWidgetProvider',
//     //   iOSName: 'WirdWidget',
//     // );
//   }
//
//   Future<UserStats> loadStats() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_statsKey);
//     if (data == null) return UserStats();
//     return UserStats.fromJson(json.decode(data));
//   }
//
//   Future<void> saveStats(UserStats stats) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_statsKey, json.encode(stats.toJson()));
//   }
//
//   Future<void> updateStats(int tasbihatCount) async {
//     final stats = await loadStats();
//     stats.totalTasbihat += tasbihatCount;
//
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     stats.dailyCompletions[today] = (stats.dailyCompletions[today] ?? 0) + 1;
//
//     final hour = DateTime.now().hour.toString();
//     stats.hourlyActivity[hour] = (stats.hourlyActivity[hour] ?? 0) + tasbihatCount;
//
//     stats.level = (stats.totalTasbihat / 1000).floor() + 1;
//
//     _updateStreak(stats);
//     _checkAchievements(stats);
//
//     await saveStats(stats);
//   }
//
//   void _updateStreak(UserStats stats) {
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final yesterday = DateFormat('yyyy-MM-dd')
//         .format(DateTime.now().subtract(Duration(days: 1)));
//
//     if (stats.dailyCompletions.containsKey(today)) {
//       if (stats.dailyCompletions.containsKey(yesterday)) {
//         stats.currentStreak++;
//       } else {
//         stats.currentStreak = 1;
//       }
//       if (stats.currentStreak > stats.longestStreak) {
//         stats.longestStreak = stats.currentStreak;
//       }
//     }
//   }
//
//   void _checkAchievements(UserStats stats) {
//     final achievements = <String>[];
//
//     if (stats.totalTasbihat >= 100 && !stats.achievements.contains('beginner')) {
//       achievements.add('beginner');
//     }
//     if (stats.totalTasbihat >= 1000 && !stats.achievements.contains('dedicated')) {
//       achievements.add('dedicated');
//     }
//     if (stats.totalTasbihat >= 10000 && !stats.achievements.contains('master')) {
//       achievements.add('master');
//     }
//     if (stats.currentStreak >= 7 && !stats.achievements.contains('week_streak')) {
//       achievements.add('week_streak');
//     }
//     if (stats.currentStreak >= 30 && !stats.achievements.contains('month_streak')) {
//       achievements.add('month_streak');
//     }
//     if (stats.level >= 10 && !stats.achievements.contains('level_10')) {
//       achievements.add('level_10');
//     }
//
//     stats.achievements.addAll(achievements);
//   }
//
//   Future<String> getTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_themeKey) ?? 'light';
//   }
//
//   Future<void> saveTheme(String theme) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_themeKey, theme);
//   }
//
//   Future<bool> isSoundEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_soundKey) ?? true;
//   }
//
//   Future<void> setSoundEnabled(bool enabled) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_soundKey, enabled);
//   }
//
//   Future<bool> isHapticEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_hapticKey) ?? true;
//   }
//
//   Future<void> setHapticEnabled(bool enabled) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_hapticKey, enabled);
//   }
//
//   Future<String> getUserName() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_userNameKey) ?? 'مستخدم';
//   }
//
//   Future<void> setUserName(String name) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userNameKey, name);
//   }
//
//   Future<List<GroupChallenge>> loadChallenges() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? data = prefs.getString(_challengesKey);
//     if (data == null) return [];
//     final List<dynamic> jsonList = json.decode(data);
//     return jsonList.map((j) => GroupChallenge.fromJson(j)).toList();
//   }
//
//   Future<void> saveChallenges(List<GroupChallenge> challenges) async {
//     final prefs = await SharedPreferences.getInstance();
//     final String data = json.encode(challenges.map((c) => c.toJson()).toList());
//     await prefs.setString(_challengesKey, data);
//   }
//
//   Future<String> exportData() async {
//     final awrad = await loadAwrad();
//     final stats = await loadStats();
//     final data = {
//       'awrad': awrad.map((w) => w.toJson()).toList(),
//       'stats': stats.toJson(),
//       'exportDate': DateTime.now().toIso8601String(),
//     };
//     return json.encode(data);
//   }
//
//   Future<void> importData(String jsonData) async {
//     final data = json.decode(jsonData);
//     final awrad = (data['awrad'] as List).map((w) => Wird.fromJson(w)).toList();
//     final stats = UserStats.fromJson(data['stats']);
//     await saveAwrad(awrad);
//     await saveStats(stats);
//   }
// }
//
// // =============== مولد صور المشاركة ===============
//
// class ShareImageGenerator {
//   static Future<void> shareAchievement({
//     required String userName,
//     required int totalTasbihat,
//     required int streak,
//     required int level,
//   }) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final size = Size(600, 800);
//
//     // خلفية متدرجة
//     final gradient = LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors: [Color(0xFF00897B), Color(0xFF26A69A), Color(0xFF4DB6AC)],
//     );
//
//     final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
//
//     // رسم الزخارف الإسلامية
//     final decorPaint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2;
//
//     for (int i = 0; i < 5; i++) {
//       canvas.drawCircle(
//         Offset(size.width * 0.5, 150 + i * 50),
//         100 - i * 15,
//         decorPaint,
//       );
//     }
//
//     // رسم النصوص
//     final titlePainter = TextPainter(
//       text: TextSpan(
//         text: '✨ إنجازاتي في التسبيح ✨',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       // textDirection: TextDirection.rtl,
//     );
//     titlePainter.layout();
//     titlePainter.paint(canvas, Offset((size.width - titlePainter.width) / 2, 50));
//
//     // بطاقة المعلومات
//     final cardRect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(50, 150, size.width - 100, 500),
//       Radius.circular(20),
//     );
//     canvas.drawRRect(
//       cardRect,
//       Paint()..color = Colors.white,
//     );
//
//     // اسم المستخدم
//     final namePainter = TextPainter(
//       text: TextSpan(
//         text: userName,
//         style: TextStyle(
//           color: Color(0xFF00897B),
//           fontSize: 36,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       // textDirection: TextDirection.rtl,
//     );
//     namePainter.layout();
//     namePainter.paint(canvas, Offset((size.width - namePainter.width) / 2, 200));
//
//     // الإحصائيات
//     final stats = [
//       {'icon': '📿', 'value': '$totalTasbihat', 'label': 'تسبيحة'},
//       {'icon': '🔥', 'value': '$streak', 'label': 'يوم متتالي'},
//       {'icon': '⭐', 'value': 'المستوى $level', 'label': ''},
//     ];
//
//     double yPos = 300;
//     for (var stat in stats) {
//       final iconPainter = TextPainter(
//         text: TextSpan(
//           text: stat['icon'],
//           style: TextStyle(fontSize: 48),
//         ),
//         // textDirection: TextDirection.ltr,
//       );
//       iconPainter.layout();
//       iconPainter.paint(canvas, Offset(100, yPos));
//
//       final valuePainter = TextPainter(
//         text: TextSpan(
//           text: stat['value'],
//           style: TextStyle(
//             color: Color(0xFF00897B),
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         // textDirection: TextDirection.rtl,
//       );
//       valuePainter.layout();
//       valuePainter.paint(canvas, Offset(200, yPos + 10));
//
//       if (stat['label']!.isNotEmpty) {
//         final labelPainter = TextPainter(
//           text: TextSpan(
//             text: stat['label'],
//             style: TextStyle(
//               color: Colors.grey.shade600,
//               fontSize: 20,
//             ),
//           ),
//           // textDirection: TextDirection.rtl,
//         );
//         labelPainter.layout();
//         labelPainter.paint(canvas, Offset(370, yPos + 20));
//       }
//
//       yPos += 100;
//     }
//
//     // توقيع التطبيق
//     final footerPainter = TextPainter(
//       text: TextSpan(
//         text: 'تطبيق أورادي 📱',
//         style: TextStyle(
//           color: Colors.white70,
//           fontSize: 18,
//         ),
//       ),
//       // textDirection: TextDirection.RTL,
//     );
//     footerPainter.layout();
//     footerPainter.paint(canvas, Offset((size.width - footerPainter.width) / 2, 720));
//
//     final picture = recorder.endRecording();
//     final img = await picture.toImage(size.width.toInt(), size.height.toInt());
//     final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//     final buffer = byteData!.buffer.asUint8List();
//
//     // حفظ ومشاركة
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/achievement.png');
//     await file.writeAsBytes(buffer);
//
//     await Share.shareXFiles(
//       [XFile(file.path)],
//       text: 'شاركت في تطبيق أورادي!\n📿 $totalTasbihat تسبيحة\n🔥 $streak يوم متتالي',
//     );
//   }
// }
//
// // =============== الشاشة الرئيسية ===============
//
// class WirdHomeScreen2 extends StatefulWidget {
//   @override
//   _WirdHomeScreen2State createState() => _WirdHomeScreen2State();
// }
//
// class _WirdHomeScreen2State extends State<WirdHomeScreen2> with TickerProviderStateMixin {
//   List<Wird> awrad = [];
//   UserStats stats = UserStats();
//   List<GroupChallenge> challenges = [];
//   final WirdManager manager = WirdManager();
//   bool isLoading = true;
//   String currentTheme = 'light';
//   String selectedCategory = 'الكل';
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     loadData();
//     NotificationManager.initialize();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   Future<void> loadData() async {
//     final data = await manager.loadAwrad();
//     final statsData = await manager.loadStats();
//     final challengesData = await manager.loadChallenges();
//     final theme = await manager.getTheme();
//     setState(() {
//       awrad = data;
//       stats = statsData;
//       challenges = challengesData;
//       currentTheme = theme;
//       isLoading = false;
//     });
//   }
//
//   List<String> get categories {
//     final cats = awrad.map((w) => w.category).toSet().toList();
//     return ['الكل', ...cats];
//   }
//
//   List<Wird> get filteredAwrad {
//     if (selectedCategory == 'الكل') return awrad;
//     return awrad.where((w) => w.category == selectedCategory).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = currentTheme == 'dark';
//
//     return Scaffold(
//       backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
//       appBar: AppBar(
//         title: Text('أورادي اليومية'),
//         centerTitle: true,
//         backgroundColor: isDark ? Colors.grey.shade800 : Colors.teal,
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(icon: Icon(Icons.book), text: 'أورادي'),
//             Tab(icon: Icon(Icons.group), text: 'التحديات'),
//             Tab(icon: Icon(Icons.insights), text: 'التحليلات'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: () async {
//               final userName = await manager.getUserName();
//               await ShareImageGenerator.shareAchievement(
//                 userName: userName,
//                 totalTasbihat: stats.totalTasbihat,
//                 streak: stats.currentStreak,
//                 level: stats.level,
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.settings),
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SettingsScreen(
//                     currentTheme: currentTheme,
//                     onThemeChanged: (theme) {
//                       setState(() => currentTheme = theme);
//                       manager.saveTheme(theme);
//                     },
//                   ),
//                 ),
//               );
//               await loadData();
//             },
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : TabBarView(
//         controller: _tabController,
//         children: [
//           _buildAwradTab(isDark),
//           _buildChallengesTab(isDark),
//           _buildAnalyticsTab(isDark),
//         ],
//       ),
//       floatingActionButton: _tabController.index == 0
//           ? FloatingActionButton.extended(
//         onPressed: () async {
//           final newWird = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddWirdScreen(isDark: isDark),
//             ),
//           );
//           if (newWird != null) {
//             setState(() => awrad.add(newWird));
//             await manager.saveAwrad(awrad);
//           }
//         },
//         icon: Icon(Icons.add),
//         label: Text('ورد جديد'),
//         backgroundColor: Colors.teal,
//       )
//           : _tabController.index == 1
//           ? FloatingActionButton.extended(
//         onPressed: () => _showCreateChallengeDialog(isDark),
//         icon: Icon(Icons.add),
//         label: Text('تحدي جديد'),
//         backgroundColor: Colors.teal,
//       )
//           : null,
//     );
//   }
//
//   Widget _buildAwradTab(bool isDark) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: isDark
//                   ? [Colors.grey.shade800, Colors.grey.shade700]
//                   : [Colors.teal, Colors.teal.shade300],
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildStatCard('🔥', '${stats.currentStreak}', 'يوم', isDark),
//               _buildStatCard('⭐', 'المستوى ${stats.level}', '${stats.totalTasbihat}', isDark),
//               _buildStatCard('🏆', '${stats.achievements.length}', 'إنجاز', isDark),
//             ],
//           ),
//         ),
//
//         if (categories.length > 1)
//           Container(
//             height: 50,
//             margin: EdgeInsets.symmetric(vertical: 8),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final cat = categories[index];
//                 final isSelected = cat == selectedCategory;
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedCategory = cat),
//                   child: Container(
//                     margin: EdgeInsets.only(left: 8),
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? Colors.teal
//                           : (isDark ? Colors.grey.shade800 : Colors.white),
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(
//                         color: isSelected ? Colors.teal : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Text(
//                       cat,
//                       style: TextStyle(
//                         color: isSelected
//                             ? Colors.white
//                             : (isDark ? Colors.white : Colors.black87),
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//         Expanded(
//           child: filteredAwrad.isEmpty
//               ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.book, size: 80, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   selectedCategory == 'الكل'
//                       ? 'لا توجد أوراد بعد'
//                       : 'لا توجد أوراد في هذه الفئة',
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//               ],
//             ),
//           )
//               : ListView.builder(
//             padding: EdgeInsets.all(16),
//             itemCount: filteredAwrad.length,
//             itemBuilder: (context, index) {
//               final wird = filteredAwrad[index];
//               final totalCount = wird.adhkar.fold<int>(
//                 0,
//                     (sum, dhikr) => sum + dhikr.targetCount,
//               );
//
//               return Card(
//                 elevation: 3,
//                 margin: EdgeInsets.only(bottom: 12),
//                 color: isDark ? Colors.grey.shade800 : Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(15),
//                   onTap: () async {
//                     final result = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => TasbihScreen(
//                           wird: wird,
//                           isDark: isDark,
//                         ),
//                       ),
//                     );
//                     if (result == true) {
//                       await manager.saveAwrad(awrad);
//                       await loadData();
//                     }
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             color: Colors.teal.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text('📿', style: TextStyle(fontSize: 30)),
//                           ),
//                         ),
//                         SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 wird.name,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: isDark ? Colors.white : Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 '${wird.adhkar.length} ذكر • $totalCount تسبيحة',
//                                 style: TextStyle(color: Colors.grey, fontSize: 14),
//                               ),
//                               SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   Icon(Icons.check_circle, size: 16, color: Colors.green),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'أكملته ${wird.completedCount} مرة',
//                                     style: TextStyle(color: Colors.green, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         Column(
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.alarm, color: Colors.grey),
//                               onPressed: () => _setReminder(wird, isDark),
//                             ),
//                             if (wird.reminderTime != null)
//                               Text(
//                                 wird.reminderTime!,
//                                 style: TextStyle(fontSize: 10, color: Colors.grey),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildChallengesTab(bool isDark) {
//     return challenges.isEmpty
//         ? Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.group, size: 80, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'لا توجد تحديات جماعية',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           SizedBox(height: 8),
//           Text(
//             'اضغط + لإنشاء تحدي مع أصدقائك',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     )
//         : ListView.builder(
//       padding: EdgeInsets.all(16),
//       itemCount: challenges.length,
//       itemBuilder: (context, index) {
//         final challenge = challenges[index];
//         final daysLeft = challenge.deadline.difference(DateTime.now()).inDays;
//         final totalProgress = challenge.participants.values.fold<int>(0, (a, b) => a + b);
//         final progress = totalProgress / challenge.targetTasbihat;
//
//         return Card(
//           elevation: 3,
//           margin: EdgeInsets.only(bottom: 16),
//           color: isDark ? Colors.grey.shade800 : Colors.white,
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.flag, color: Colors.orange, size: 30),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             challenge.name,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black87,
//                             ),
//                           ),
//                           Text(
//                             'ينتهي خلال $daysLeft يوم',
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 LinearProgressIndicator(
//                   value: progress.clamp(0.0, 1.0),
//                   minHeight: 10,
//                   backgroundColor: Colors.grey.shade300,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   '$totalProgress من ${challenge.targetTasbihat} تسبيحة',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   'المشاركون (${challenge.participants.length}):',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white70 : Colors.grey.shade700,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 ...challenge.participants.entries.map((entry) {
//                   final rank = challenge.participants.entries.toList()
//                     ..sort((a, b) => b.value.compareTo(a.value));
//                   final position = rank.indexWhere((e) => e.key == entry.key) + 1;
//                   final medal = position == 1 ? '🥇' : position == 2 ? '🥈' : position == 3 ? '🥉' : '${position}.';
//
//                   return Padding(
//                     padding: EdgeInsets.only(bottom: 8),
//                     child: Row(
//                       children: [
//                         Text(medal, style: TextStyle(fontSize: 20)),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             entry.key,
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black87,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${entry.value} تسبيحة',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//                 SizedBox(height: 12),
//                 ElevatedButton.icon(
//                   onPressed: () => _contributeToChallenge(challenge, isDark),
//                   icon: Icon(Icons.add),
//                   label: Text('ساهم في التحدي'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                     minimumSize: Size(double.infinity, 45),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAnalyticsTab(bool isDark) {
//     final bestHour = stats.hourlyActivity.entries.isEmpty
//         ? 0
//         : stats.hourlyActivity.entries.reduce((a, b) => a.value > b.value ? a : b).key;
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             elevation: 4,
//             color: isDark ? Colors.grey.shade800 : Colors.white,
//             child: Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Icon(Icons.insights, size: 50, color: Colors.teal),
//                   SizedBox(height: 12),
//                   Text(
//                     'تحليلات ذكية',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             color: isDark ? Colors.grey.shade800 : Colors.white,
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.access_time, color: Colors.orange),
//                       SizedBox(width: 8),
//                       Text(
//                         'أفضل وقت للتسبيح',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     'أنت أكثر نشاطاً في الساعة ${bestHour}:00',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isDark ? Colors.white70 : Colors.grey.shade700,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     '💡 نصيحة: حاول الالتزام بهذا الوقت لأفضل النتائج',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.teal,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             color: isDark ? Colors.grey.shade800 : Colors.white,
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'نشاطك حسب الساعة',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Container(
//                     height: 200,
//                     child: BarChart(
//                       BarChartData(
//                         alignment: BarChartAlignment.spaceAround,
//                         maxY: (stats.hourlyActivity.values.isEmpty ? 10 : stats.hourlyActivity.values.reduce(math.max) + 5).toDouble(),
//                         barTouchData: BarTouchData(enabled: true),
//                         titlesData: FlTitlesData(
//                           show: true,
//                           bottomTitles: AxisTitles(
//                             sideTitles: SideTitles(
//                               showTitles: true,
//                               getTitlesWidget: (value, meta) {
//                                 if (value.toInt() % 4 == 0) {
//                                   return Text(
//                                     '${value.toInt()}',
//                                     style: TextStyle(fontSize: 10),
//                                   );
//                                 }
//                                 return Text('');
//                               },
//                             ),
//                           ),
//                           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                         ),
//                         gridData: FlGridData(show: false),
//                         borderData: FlBorderData(show: false),
//                         barGroups: List.generate(24, (hour) {
//                           final count = stats.hourlyActivity[hour.toString()] ?? 0;
//                           return BarChartGroupData(
//                             x: hour,
//                             barRods: [
//                               BarChartRodData(
//                                 toY: count.toDouble(),
//                                 color: hour == int.parse(bestHour.toString()) ? Colors.orange : Colors.teal,
//                                 width: 8,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ],
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             color: isDark ? Colors.grey.shade800 : Colors.white,
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'توصيات شخصية',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   if (stats.currentStreak == 0)
//                     _buildRecommendation(
//                       '🎯',
//                       'ابدأ سلسلتك اليوم',
//                       'أكمل ورداً واحداً لبدء سلسلة إنجازاتك',
//                       isDark,
//                     )
//                   else if (stats.currentStreak < 7)
//                     _buildRecommendation(
//                       '💪',
//                       'استمر!',
//                       'أنت على بعد ${7 - stats.currentStreak} أيام من إنجاز الأسبوع',
//                       isDark,
//                     )
//                   else
//                     _buildRecommendation(
//                       '🌟',
//                       'ممتاز!',
//                       'أنت تواظب بشكل رائع، استمر على هذا المنوال',
//                       isDark,
//                     ),
//                   SizedBox(height: 12),
//                   if (stats.totalTasbihat < 1000)
//                     _buildRecommendation(
//                       '🎓',
//                       'الهدف التالي',
//                       'أنت على بعد ${1000 - stats.totalTasbihat} تسبيحة من المستوى التالي',
//                       isDark,
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRecommendation(String emoji, String title, String desc, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.teal.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.teal.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Text(emoji, style: TextStyle(fontSize: 30)),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   desc,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: isDark ? Colors.white70 : Colors.grey.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String emoji, String value, String label, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Text(emoji, style: TextStyle(fontSize: 24)),
//           SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(fontSize: 12, color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _setReminder(Wird wird, bool isDark) async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData(
//             colorScheme: ColorScheme.light(primary: Colors.teal),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (time != null) {
//       wird.reminderTime = time.format(context);
//       await NotificationManager.scheduleDailyReminder(wird.name, time);
//       await manager.saveAwrad(awrad);
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('تم تعيين التذكير للساعة ${time.format(context)}')),
//       );
//     }
//   }
//
//   void _showCreateChallengeDialog(bool isDark) {
//     final nameController = TextEditingController();
//     final targetController = TextEditingController(text: '1000');
//     int selectedDays = 7;
//
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
//           title: Text(
//             'إنشاء تحدي جماعي',
//             style: TextStyle(color: isDark ? Colors.white : Colors.black),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                   decoration: InputDecoration(
//                     labelText: 'اسم التحدي',
//                     hintText: 'مثال: تحدي الأسبوع',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: targetController,
//                   style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                   decoration: InputDecoration(
//                     labelText: 'الهدف (عدد التسبيحات)',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'المدة: $selectedDays أيام',
//                   style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                 ),
//                 Slider(
//                   value: selectedDays.toDouble(),
//                   min: 1,
//                   max: 30,
//                   divisions: 29,
//                   label: '$selectedDays',
//                   onChanged: (value) {
//                     setDialogState(() => selectedDays = value.toInt());
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (nameController.text.isEmpty) return;
//
//                 final userName = await manager.getUserName();
//                 final challenge = GroupChallenge(
//                   id: DateTime.now().toString(),
//                   name: nameController.text,
//                   targetTasbihat: int.tryParse(targetController.text) ?? 1000,
//                   deadline: DateTime.now().add(Duration(days: selectedDays)),
//                   participants: {userName: 0},
//                 );
//
//                 challenges.add(challenge);
//                 await manager.saveChallenges(challenges);
//                 setState(() {});
//                 Navigator.pop(context);
//               },
//               child: Text('إنشاء'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _contributeToChallenge(GroupChallenge challenge, bool isDark) async {
//     final controller = TextEditingController();
//     final userName = await manager.getUserName();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
//         title: Text(
//           'أضف مساهمتك',
//           style: TextStyle(color: isDark ? Colors.white : Colors.black),
//         ),
//         content: TextField(
//           controller: controller,
//           style: TextStyle(color: isDark ? Colors.white : Colors.black),
//           decoration: InputDecoration(
//             labelText: 'عدد التسبيحات',
//             border: OutlineInputBorder(),
//           ),
//           keyboardType: TextInputType.number,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final count = int.tryParse(controller.text) ?? 0;
//               if (count > 0) {
//                 challenge.participants[userName] =
//                     (challenge.participants[userName] ?? 0) + count;
//                 manager.saveChallenges(challenges);
//                 setState(() {});
//               }
//               Navigator.pop(context);
//             },
//             child: Text('إضافة'),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // =============== بقية الشاشات (AddWirdScreen, TasbihScreen, إلخ) تبقى كما هي من الكود السابق ===============

