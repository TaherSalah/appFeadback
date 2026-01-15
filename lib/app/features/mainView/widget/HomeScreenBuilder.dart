import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/mainView/widget/IslamicCardWidget.dart';
import 'package:muslimdaily/app/features/settings/settings_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/style/k_helper.dart';
import '../../Khatmah/data/khatmah_model.dart';
import '../../charity/CharityDashboardScreen.dart';
import 'AzkarQuranWidget.dart';
import 'CharityEntryWidget.dart';
import 'KidsCornerScreen.dart';
import 'OtherAzkarWidget.dart';
import '../controllar/MainController.dart';
import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';
import 'PrayerHeaderSection.dart';
import 'SoulComfortWidget.dart';
import 'AllahNameWidget.dart';
import 'KidsEntryPointWidget.dart';
import 'FridayCompanionWidget.dart';
import 'DailyStreakWidget.dart';
import 'FajrAlarmEntryWidget.dart';
import '../../azanView/view/adhan_overlay_screen.dart';
import '../../../core/services/version_check_service.dart';
import '../../../core/services/system_control_service.dart';
import '../../../core/widgets/ScrollingText.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/CustomGradientDialog.dart';
import '../../../core/widgets/SocialBannerWidget.dart';

class MainViewBuilder extends StatefulWidget {
  const MainViewBuilder({super.key});

  @override
  _MainViewBuilderState createState() => _MainViewBuilderState();
}

class _MainViewBuilderState extends StateMVC<MainViewBuilder> {
  _MainViewBuilderState() : super(MainController()) {
    con = controller as MainController;
  }

  late MainController con;
  late CentralizedCubit centralizedCubit;
  int? verseId;
  String? verseName;
  List<SurahModel>? surahModel;
  late final Box<KhatmahModel> box;
  late final Box plansBox;
  String? _locationText;

  // 👇 متغيرات للتحكم في السكرول
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isScrolledNotifier = ValueNotifier(false);
  String _dailyQuote = "جاري التحميل...";
  bool _isQuoteVisible = false;
  Map<String, String>? _newsData;
  List<Map<String, dynamic>> _banners = [];
  Map<String, String> _featureStatuses = {};

  @override
  void initState() {
    centralizedCubit = context.read<CentralizedCubit>();
    centralizedCubit.checkConnectivity();
    centralizedCubit.trackConnectivityChange();
    super.initState();

    // 🚀 Check for updates & Daily Quote & News & Banners
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      VersionCheckService().checkForUpdates(context);

      final service = SystemControlService();
      final quote = await service.getQuoteOfTheDay();
      final isQuoteVisible = await service.isQuoteVisible();
      final newsData = await service.getNewsMarquee();
      final banners = await service.getBanners();
      final featureStatuses = await service.getFeatureStatuses();

      // 🎨 Update Theme Color dynamically
      final themeColor = await service.getThemePrimaryColor();
      if (mounted) {
        context.read<CentralizedCubit>().updateDynamicColor(themeColor);
      }

      // 📢 Check for Broadcast Message
      _checkBroadcast();

      if (mounted) {
        setState(() {
          _dailyQuote = quote;
          _isQuoteVisible = isQuoteVisible;
          _newsData = newsData;
          _banners = banners;
          _featureStatuses = featureStatuses;
        });
      }
    });

    loadSurahList();
    loadVerseName();
    loadSurahs();
    loadBookmark();
    box = Hive.box<KhatmahModel>('khatmahBox');
    plansBox = Hive.box('khatmahPlans');
    _loadSavedLocation();

    // 👇 استمع للسكرول
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // لما المستخدم يسكرول أكثر من 100 بكسل
    if (_scrollController.offset > 100 && !_isScrolledNotifier.value) {
      _isScrolledNotifier.value = true;
    } else if (_scrollController.offset <= 100 && _isScrolledNotifier.value) {
      _isScrolledNotifier.value = false;
    }
  }

  void _checkAndNavigate(String? navigatePath) {
    if (navigatePath == null) return;

    final featureId = _getFeatureId(navigatePath);

    // 🎯 Log usage for analytics
    SystemControlService().logFeatureUsage(featureId);

    final status = _featureStatuses[featureId] ?? 'active';

    if (status == 'maintenance') {
      _showMaintenanceDialog();
      return;
    }

    Navigator.pushNamed(context, navigatePath);
  }

  void _showMaintenanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return CustomGradientDialog(
          title: "عذراً، القسم قيد الصيانة",
          message:
              "نحن نعمل حالياً على تحسين هذا القسم وإضافة مميزات جديدة.\nيرجى العودة لاحقاً.",
          icon: Icons.construction_rounded,
          gradientColors: isDark
              ? [
                  const Color(0xFF4C1D95),
                  const Color(0xFF5B21B6)
                ] // Dark Purple
              : [
                  const Color(0xFF8B5CF6),
                  const Color(0xFFA78BFA)
                ], // Light Purple
          isDark: isDark,
          onPrimaryPressed: () => Navigator.pop(context),
          primaryButtonText: "حسناً",
          primaryButtonColor:
              isDark ? const Color(0xFF6D28D9) : const Color(0xFF7C3AED),
          infoText: "شكراً لتفهمكم وصبركم، نسعى لتقديم الأفضل لكم دائماً.",
          titleColor: Colors.white,
          messageColor: Colors.white.withOpacity(0.9),
          iconColor: Colors.white,
        );
      },
    );
  }

  Future<void> _checkBroadcast() async {
    final service = SystemControlService();
    final broadcast = await service.getBroadcastMessage();

    if (broadcast != null) {
      final prefs = await SharedPreferences.getInstance();
      final lastShownId = prefs.getString('last_broadcast_id') ?? '';

      if (lastShownId != broadcast['id']) {
        if (mounted) {
          _showBroadcastDialog(broadcast['message']!, broadcast['id']!);
        }
      }
    }
  }

  void _showBroadcastDialog(String message, String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return CustomGradientDialog(
          title: "تنبيه هام",
          message: message,
          icon: Icons.campaign_rounded,
          gradientColors: isDark
              ? [const Color(0xFF92400E), const Color(0xFFB45309)] // Dark Amber
              : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)], // Amber
          isDark: isDark,
          onPrimaryPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_broadcast_id', id);
            if (context.mounted) Navigator.pop(context);
          },
          primaryButtonText: "فهمت",
          primaryButtonColor: Colors.white.withOpacity(0.25),
          titleColor: Colors.white,
          messageColor: Colors.white,
          iconColor: Colors.white,
        );
      },
    );
  }

  String _getFeatureId(String path) {
    if (path == '/surahListScreen') return 'quran';
    if (path == '/azkarSabah' ||
        path == '/azkarMassa' ||
        path == '/allazkarlistview') return 'azkar';
    if (path == '/azkarCounter') return 'sebha';
    if (path == '/compplateKhatna') return 'khatmah';
    if (path == Routes.zakatCalculatorRoute) return 'zakat';
    if (path == '/WirdHomeScreen') return 'charity';
    if (path == '/QuranRadioView') return 'radio';
    if (path == '/NineBooksScreen' || path == Routes.categoriesRoute)
      return 'hadith';
    if (path == '/mosquesMap') return 'mosques';
    if (path == '/kidsCorner') return 'kids';
    if (path == '/timingScreen') return 'timing';
    if (path == '/qiblaDirection') return 'qibla';
    if (path == '/fajrAlarm') return 'fajr_alarm';
    if (path == '/settingsRoute') return 'settings';
    return 'none';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isScrolledNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final country = prefs.getString('selected_country');
    final city = prefs.getString('selected_city');

    setState(() {
      if (country != null && city != null) {
        _locationText = '$country - $city';
      } else {
        _locationText = 'لم يتم تحديد الموقع';
      }
    });
  }

  Future<void> _onLocationChanged() async {
    await con.refreshPrayerTimesFromPrefs();
    await _loadSavedLocation();
  }

  void loadBookmark() async {
    final id = await getBookmark();
    setState(() {});
  }

  Future<int?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_verseId');
  }

  void loadVerseId() async {
    final id = await getVerseId();
    setState(() {
      verseId = id;
    });
  }

  void loadVerseName() async {
    final name = await getVerseName();
    setState(() {
      verseName = name;
    });
  }

  Future<String?> getVerseName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bookmark_verseName');
  }

  Future<int?> getVerseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('bookmark_verseId');
  }

  void loadSurahs() async {
    final loadedSurahs = await loadSurahList();
    setState(() {
      surahModel = loadedSurahs;
    });
  }

  Future<List<SurahModel>> loadSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('saved_surahs');
    if (jsonList == null) return [];
    return jsonList
        .map((jsonStr) => SurahModel.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final completed = box.values.where((k) => k.isCompleted).toList();
    bool isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                // المحتوى القابل للسكرول
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // الهيدر الكبير
                    SliverToBoxAdapter(
                      child: PrayerHeaderSection(
                        progressValue: con.progressValue,
                        hijriDate: con.hijriDate,
                        gregorian: con.gregorian ?? "",
                        nextPrayer: con.nextPrayer,
                        remainingTime: con.remainingTimeText,
                        location: _locationText ?? 'لم يتم تحديد الموقع',
                        onSettingsTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsView(),
                            ),
                          );
                          _onLocationChanged();
                        },
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // 📢 Social Media Banner
                          const SocialBannerWidget(),

                          if (_featureStatuses['news'] != 'hidden' &&
                              _newsData != null &&
                              _newsData!['text'] != null &&
                              _newsData!['text']!.trim().isNotEmpty)
                            FadeInDown(
                              duration: const Duration(seconds: 1),
                              child: Builder(builder: (context) {
                                final type = _newsData!['type'] ?? 'urgent';
                                final label =
                                    _newsData!['label'] ?? 'تنبيه عاجل';
                                final text = _newsData!['text']!;

                                Color bgColor;
                                switch (type) {
                                  case 'info':
                                    bgColor = Colors.blueAccent;
                                    break;
                                  case 'success':
                                    bgColor = Colors.green;
                                    break;
                                  case 'warning':
                                    bgColor = Colors.orange;
                                    break;
                                  default:
                                    bgColor = Colors.redAccent;
                                }

                                return Container(
                                  width: double.infinity,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: bgColor.withOpacity(0.9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        color: bgColor,
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ScrollingText(
                                          text: text,
                                          style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),

                          // 🖼️ البانرات الإعلانية (Carousel)
                          if (_featureStatuses['banners'] != 'hidden' &&
                              _banners.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 120,
                                  viewportFraction: 0.9,
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  autoPlayInterval: const Duration(seconds: 5),
                                ),
                                items: _banners.map((banner) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (banner['link_url'] != null &&
                                          banner['link_url']
                                              .toString()
                                              .startsWith('http')) {
                                        await launchUrl(
                                            Uri.parse(banner['link_url']),
                                            mode:
                                                LaunchMode.externalApplication);
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: banner['image_url'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              placeholder: (context, url) =>
                                                  Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                            if (banner['title'] != null &&
                                                banner['title']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        Colors.black
                                                            .withOpacity(0.7),
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  child: Text(
                                                    banner['title'],
                                                    style: GoogleFonts.cairo(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 10),
                          // 📜 خـاطـرة اليوم (CMS)
                          if (_isQuoteVisible)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF16213e)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color:
                                      const Color(0xFFD4AF37).withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.format_quote_rounded,
                                      color: Color(0xFFD4AF37), size: 30),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _dailyQuote,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 🔥 قسم بماذا تشعر اليوم؟
                          // const SoulComfortWidget(),

                          // // 🔥 السلسلة اليومية
                          // const DailyStreakWidget(),

                          // 🔥 رفيق الجمعة (يظهر فقط يوم الجمعة)
                          if (_featureStatuses['friday_companion'] != 'hidden')
                            const FridayCompanionWidget(),

                          // 🔥 منبه الفجر المتقدم
                          // const FajrAlarmEntryWidget(),
                          // const SizedBox(height: 10),

                          // 🔥 صندوق الهدايا اليومي
                          // const DailyGiftWidget(),

                          // 🔥 جدول الطاعات
                          // const WorshipTrackerWidget(),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTab ? 10.w : 5.0),
                            child: GridView.count(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              crossAxisCount: 3,
                              crossAxisSpacing: isTab ? 30 : 7,
                              mainAxisSpacing: isTab ? 20 : 15,
                              childAspectRatio: isTab ? 1.9 : 01.20,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: con.iconsApp.where((item) {
                                final featureId =
                                    _getFeatureId(item['navigate'] ?? '');
                                return _featureStatuses[featureId] != 'hidden';
                              }).map((item) {
                                return BlocBuilder<CentralizedCubit,
                                    CentralizedState>(
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap: () async {
                                        bool needsInternet = item["navigate"] ==
                                                Routes.categoriesRoute ||
                                            item["navigate"] ==
                                                "/QuranRadioView";

                                        if (((state is ConnectivityState &&
                                                    state.status ==
                                                        ConnectivityStatus
                                                            .disconnected) ==
                                                true) &&
                                            needsInternet) {
                                          KHelper.showError(
                                              message:
                                                  "يرجي التحقق من اتصالك بالانترنت");
                                        } else {
                                          _checkAndNavigate(item['navigate']);
                                        }
                                      },
                                      child: IslamicCardWidget(
                                          title: item["title"]!,
                                          iconPath: item["icon"]!),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                              height: MediaQuery.sizeOf(context).width > 600
                                  ? 25
                                  : 20),

                          // const SizedBox(height: 10),

                          // 🔥 قسم تعرف على ربك
                          if (_featureStatuses['allah_names'] != 'hidden')
                            const AllahNameWidget(),

                          const SizedBox(height: 10),

                          // 🔥 قسم غراس الجنة
                          // const JannahPlanterWidget(),

                          // const SizedBox(height: 10),

                          if (_featureStatuses['charity'] != 'hidden')
                            InkWell(
                              onTap: () {
                                final status =
                                    _featureStatuses['charity'] ?? 'active';
                                if (status == 'maintenance') {
                                  _showMaintenanceDialog();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            CharityDashboardScreen()),
                                  );
                                }
                              },
                              child: const CharityEntryWidget(),
                            ),
                          const SizedBox(height: 10),

                          if (_featureStatuses['kids'] != 'hidden')
                            InkWell(
                              onTap: () {
                                final status =
                                    _featureStatuses['kids'] ?? 'active';
                                if (status == 'maintenance') {
                                  _showMaintenanceDialog();
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            KidsCornerScreen()),
                                  );
                                }
                              },
                              child: const KidsEntryPointWidget(),
                            ),

                          const SizedBox(height: 20),

                          if (_featureStatuses['quran_azkar'] != 'hidden')
                            const AzkarQuranWidget(),

                          if (_featureStatuses['other_azkar'] != 'hidden')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: const OtherAzkarWidget(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // الهيدر الثابت المصغر (يظهر عند السكرول)
                ValueListenableBuilder<bool>(
                  valueListenable: _isScrolledNotifier,
                  builder: (context, isScrolled, child) {
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      top: isScrolled ? 0 : -150,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isScrolled ? 1.0 : 0.0,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                            bottom: 10,
                            left: 16,
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF1a1a2e).withOpacity(0.98),
                                      const Color(0xFF16213e).withOpacity(0.95),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      KColors.primaryColor,
                                      KColors.primaryColor,
                                      // Colors.white.withOpacity(0.98),
                                      // const Color(0xFFFFFBF0).withOpacity(0.95),
                                    ],
                                  ),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? const Color(0xFFD4AF37).withOpacity(0.3)
                                    : const Color(0xFFD4AF37).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.5)
                                    : const Color(0xFFD4AF37)
                                        .withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Row(
                                //   children: [
                                //     Icon(
                                //       Icons.location_on_rounded,
                                //       size: 16,
                                //       color: isDark
                                //           ? const Color(0xFFD4AF37)
                                //           : const Color(0xFF1B5E20),
                                //     ),
                                //     const SizedBox(width: 4),
                                //     Container(
                                //       constraints: const BoxConstraints(maxWidth: 80),
                                //       child: TextDefaultWidget(
                                //         title: _locationText?.split(' - ').last ??
                                //             'موقع',
                                //         fontSize: isTab ? 7.sp : 9.sp,
                                //         fontFamily: "cairo",
                                //         fontWeight: FontWeight.w600,
                                //         color: isDark
                                //             ? AppColors.greyLightColor
                                //             .withOpacity(0.8)
                                //             : const Color(0xFF2C3E50),
                                //         maxLines: 1,
                                //         // overflow: TextOverflow.ellipsis,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.white.withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: isTab ? 26 : 22,
                                      color: isDark
                                          ? KColors.whiteColor
                                          : AppColors.primary,
                                    ),
                                  ),
                                  // Icon(
                                  //   Icons.location_on_rounded,
                                  //   size:isTab?25: 16,
                                  //   color: isDark
                                  //       ? KColors.primaryColor
                                  //       : AppColors.primary,
                                  // ),
                                  const SizedBox(width: 10),
                                  TextDefaultWidget(
                                    title: _locationText
                                            ?.split(' - ')
                                            .last ??
                                        'موقع',
                                    fontSize: isTab ? 8.sp : 11.sp,
                                    fontFamily: "cairo",
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.greyLightColor
                                        : Colors.white,
                                  ),
                                ]),
                                // زر الإعدادات
                                // InkWell(
                                //   onTap: () => showThemeSheet(
                                //     context,
                                //     onLocationChanged: _onLocationChanged,
                                //   ),
                                //   borderRadius: BorderRadius.circular(20),
                                //   child: Container(
                                //     padding: const EdgeInsets.all(8),
                                //     decoration: BoxDecoration(
                                //       shape: BoxShape.circle,
                                //       gradient: isDark
                                //           ? LinearGradient(
                                //         colors: [
                                //           const Color(0xFF1B5E20)
                                //               .withOpacity(0.6),
                                //           const Color(0xFF2E7D32)
                                //               .withOpacity(0.4),
                                //         ],
                                //       )
                                //           : LinearGradient(
                                //         colors: [
                                //           Colors.white,
                                //           const Color(0xFFFFFBF0),
                                //         ],
                                //       ),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: isDark
                                //               ? const Color(0xFFD4AF37)
                                //               .withOpacity(0.2)
                                //               : const Color(0xFF1B5E20)
                                //               .withOpacity(0.15),
                                //           blurRadius: 6,
                                //           offset: const Offset(0, 2),
                                //         ),
                                //       ],
                                //     ),
                                //     child: Icon(
                                //       Icons.settings,
                                //       size: 20,
                                //       color: isDark
                                //           ? const Color(0xFFD4AF37)
                                //           : const Color(0xFF1B5E20),
                                //     ),
                                //   ),
                                // ),
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsView(),
                                      ),
                                    );
                                    _onLocationChanged();
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.white.withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.settings,
                                      size: isTab ? 26 : 22,
                                      color: isDark
                                          ? AppColors.greyLightColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          /// TODO:- for test Adhan Overlay Screen
        ));
  }
}
