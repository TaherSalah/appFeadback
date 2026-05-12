import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/core/services/settings_service.dart';
import 'package:muslimdaily/app/core/shard/widgets/ui_animations.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/features/azanView/adhan_workmanager_service.dart';

import '../../../core/utils/style/app_theme_colors.dart';

class AdvancedFajrAlarmWidget extends StatefulWidget {
  const AdvancedFajrAlarmWidget({super.key});

  @override
  State<AdvancedFajrAlarmWidget> createState() =>
      _AdvancedFajrAlarmWidgetState();
}

class _AdvancedFajrAlarmWidgetState extends State<AdvancedFajrAlarmWidget> {
  final SettingsService _settingsService = SettingsService();
  bool _isEnabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 4, minute: 0);
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  int _repetitions = 1;
  bool _vibrate = true;
  bool _fadeIn = false;
  String? _currentFajrTime;

  Timer? _countdownTimer;
  String _timeLeft = "";

  // Motivational Quotes
  // final List<String> _fajrQuotes = [
  //   "صلاة الفجر تجعل الإنسان في ذمة الله طوال اليوم.",
  //   "ركعتا الفجر خير من الدنيا وما فيها.",
  //   "بشر المشائين في الظلم إلى المساجد بالنور التام يوم القيامة.",
  //   "من صلى الفجر في جماعة فكأنما قام الليل كله.",
  //   "الفجر وقت توزيع الأرزاق، فلا تكن نائماً.",
  //   "نور الفجر يمحو ظلام القلوب والهموم.",
  // ];
  final List<String> _fajrQuotes = [
    // من السنة النبوية
    "قال رسول الله ﷺ: «من صلى الصبح فهو في ذمة الله، فلا يطلبنكم الله من ذمته بشيء».",
    "قال رسول الله ﷺ: «من حافظ على الصلوات الخمس كتبت له براءة من النار».",
    "قال رسول الله ﷺ: «يعقد الشيطان على قافية رأس أحدكم إذا هو نام ثلاث عقد… فإن صلى انحلت عقده كلها».",
    "قال رسول الله ﷺ: «أفضل الصلاة بعد الفريضة صلاة الليل».",
    "قال رسول الله ﷺ: «أحب الأعمال إلى الله الصلاة على وقتها».",
    "قال رسول الله ﷺ: «من توضأ فأحسن الوضوء ثم صلى ركعتين لا يحدث فيهما نفسه غفر له ما تقدم من ذنبه».",
    "قال رسول الله ﷺ: «عليكم بقيام الليل فإنه دأب الصالحين قبلكم».",
    // من القرآن الكريم
    "﴿أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ إِلَىٰ غَسَقِ اللَّيْلِ وَقُرْآنَ الْفَجْرِ﴾ [الإسراء: 78].",
    "﴿قَدْ أَفْلَحَ الْمُؤْمِنُونَ • الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ﴾ [المؤمنون: 1-2].",
    "﴿وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ﴾ [البقرة: 43].",
    "﴿وَالَّذِينَ هُمْ عَلَىٰ صَلَوَاتِهِمْ يُحَافِظُونَ﴾ [المؤمنون: 9].",
    "﴿إِنَّ رَبَّكَ يَعْلَمُ أَنَّكَ تَقُومُ أَدْنَىٰ مِن ثُلُثَيِ اللَّيْلِ﴾ [المزمل: 20].",
    "﴿وَمِنَ اللَّيْلِ فَاسْجُدْ لَهُ وَسَبِّحْهُ لَيْلًا طَوِيلًا﴾ [الإنسان: 26].",
    "﴿الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا﴾ [آل عمران: 191].",
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = (_fajrQuotes..shuffle()).first;
    _loadSettings();
    _startCountdown();
    _loadCurrentFajrTime();
  }

  Future<void> _loadCurrentFajrTime() async {
    final nextPrayer = await AdhanWorkManagerService().getNextPrayer();
    if (nextPrayer != null && nextPrayer['name'] == 'الفجر') {
      setState(() {
        _currentFajrTime = nextPrayer['formattedTime'];
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isEnabled) {
        _updateCountdown();
      }
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    DateTime? nextAlarm;

    // Find the next occurrence
    for (int i = 0; i < 8; i++) {
      final checkDate = now.add(Duration(days: i));
      int weekday = checkDate.weekday; // 1-7 (Mon-Sun)

      if (_selectedDays.contains(weekday)) {
        final alarmDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          _time.hour,
          _time.minute,
        );

        if (alarmDate.isAfter(now)) {
          nextAlarm = alarmDate;
          break;
        }
      }
    }

    if (nextAlarm != null) {
      final diff = nextAlarm.difference(now);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      final seconds = diff.inSeconds % 60;

      setState(() {
        _timeLeft =
            "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
    } else {
      setState(() {
        _timeLeft = "--:--:--";
      });
    }
  }

  Future<void> _loadSettings() async {
    await _settingsService.init();
    setState(() {
      _isEnabled = _settingsService.isFajrAlarmEnabled;
      _time = TimeOfDay(
        hour: _settingsService.fajrAlarmHour,
        minute: _settingsService.fajrAlarmMinute,
      );
      _selectedDays = List<int>.from(_settingsService.fajrAlarmDays);
      _repetitions = _settingsService.fajrAlarmRepetitions;
      _vibrate = _settingsService.fajrAlarmVibrate;
      _fadeIn = _settingsService.fajrAlarmFadeIn;
    });
    _updateCountdown();
  }

  bool _isCheckingPermissions = false;

  Future<void> _applySettings() async {
    if (_isCheckingPermissions) return;
    setState(() => _isCheckingPermissions = true);

    try {
      final bool isPermissionAllowed = await NotificationManager()
          .checkAndRequestExactAlarmPermission()
          .timeout(const Duration(seconds: 12), onTimeout: () => false);

      await _settingsService.setFajrAlarmEnabled(_isEnabled);
      await _settingsService.setFajrAlarmHour(_time.hour);
      await _settingsService.setFajrAlarmMinute(_time.minute);
      await _settingsService.setFajrAlarmDays(_selectedDays);
      await _settingsService.setFajrAlarmRepetitions(_repetitions);
      await _settingsService.setFajrAlarmVibrate(_vibrate);
      await _settingsService.setFajrAlarmFadeIn(_fadeIn);

      await NotificationManager()
          .scheduleAdvancedFajrAlarm()
          .timeout(const Duration(seconds: 15));

      _updateCountdown();

      if (!mounted) return;
      if (isPermissionAllowed) {
        KHelper.showSuccess(message: "تم حفظ الإعدادات بنجاح");
      } else {
        KHelper.showError(
            message:
                "تم حفظ الإعدادات، لكن يلزم السماح بالتنبيهات الدقيقة ليعمل المنبّه دائمًا");
      }
    } catch (_) {
      if (mounted) {
        KHelper.showError(
            message: "تعذّر حفظ إعدادات منبّه الفجر، حاول مرة أخرى");
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingPermissions = false);
      }
    }
  }

  String _getDayAbbr(int day) {
    switch (day) {
      case 1:
        return "اثن"; // إثنين
      case 2:
        return "ثلا"; // ثلاثاء
      case 3:
        return "ارب"; // أربعاء
      case 4:
        return "خم"; // خميس
      case 5:
        return "جم"; // جمعة
      case 6:
        return "سب"; // سبت
      case 7:
        return "حد"; // أحد
      default:
        return "";
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return "الأثنين";
      case 2:
        return "الثلاثاء";
      case 3:
        return "الأربعاء";
      case 4:
        return "الخميس";
      case 5:
        return "الجمعة";
      case 6:
        return "السبت";
      case 7:
        return "الأحد";
      default:
        return "";
    }
  }

  // Helper to convert English numbers to Arabic (Indian) numerals
  String _toArabicNums(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  // Format with Arabic AM/PM
  String _formatTime12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "ص" : "م";
    return "${_toArabicNums(hour.toString())}:${_toArabicNums(minute)} $period";
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        } else {
          KHelper.showError(message: "يجب اختيار يوم واحد على الأقل");
        }
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _toggleAllDays() {
    setState(() {
      if (_selectedDays.length == 7) {
        // Keep only today if all selected, else keep day 1 (Monday)
        int today = DateTime.now().weekday;
        _selectedDays = [today];
      } else {
        _selectedDays = [1, 2, 3, 4, 5, 6, 7];
      }
    });
  }

  Future<void> _pickTime() async {
    final isDark = context.isDark;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: isDark
                  ? const ColorScheme.dark(
                      primary: Color(0xFFD4AF37),
                      onPrimary: Colors.white,
                      surface: Colors.black,
                      onSurface: Colors.white,
                    )
                  : const ColorScheme.light(
                      primary: Color(0xFFD4AF37),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final goldColor = KColors.primaryColor;
    final cardColor = AppThemeColors.cardBackgroundColor(context);
    final textColor = isDark ? Colors.white : const Color(0xFF2C3E50);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(context.isTab ? 80 : 50),
          child: AppBar(
            leading: Navigator.canPop(context)
                ? CupertinoNavigationBarBackButton(
                    color: isDark ? Colors.white : Colors.black,
                  )
                : null,
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
              "منبه الفجر",
                 style: TextStyle(
                          fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: context.isTab ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        // backgroundColor: bgColor,
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: Image.asset(
                  "assets/images/pattern.webp",
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: FadeAnimation(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 15.h),
                          // Time Display
                          GestureDetector(
                            onTap: _pickTime,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime12h(_time),
                                  style: GoogleFonts.barlow(
                                    fontSize: 50.sp,
                                    fontWeight: FontWeight.w500,
                                    color: goldColor,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: goldColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit,
                                          color: goldColor, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        "اضغط لتعديل الوقت",
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 12.sp,
                                          color: goldColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15)
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Countdown & Fajr Time Reference
                        if (_isEnabled || _currentFajrTime != null)
                          StaggeredItemAnimation(
                            index: 1,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: goldColor.withOpacity(0.2),
                                    width: 1),
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
                                  if (_isEnabled)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "المتبقي",
                                               style: TextStyle(
                          fontFamily: "cairo",
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _toArabicNums(_timeLeft),
                                            style: GoogleFonts.barlow(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: goldColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_isEnabled && _currentFajrTime != null)
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  if (_currentFajrTime != null)
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "أذان الفجر اليوم",
                                               style: TextStyle(
                          fontFamily: "cairo",
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _toArabicNums(_currentFajrTime!),
                                            style: GoogleFonts.barlow(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        StaggeredItemAnimation(
                          index: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "أيام التنبيه",
                                       style: TextStyle(
                          fontFamily: "cairo",
                                      fontSize:
                                          context.isTab ? 10.sp : 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _toggleAllDays,
                                    icon: Icon(
                                      _selectedDays.length == 7
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      size: 18,
                                      color: goldColor,
                                    ),
                                    label: Text(
                                      _selectedDays.length == 7
                                          ? "إلغاء الكل"
                                          : "تحديد الكل",
                                         style: TextStyle(
                          fontFamily: "cairo",
                                        fontSize:
                                            context.isTab ? 10.sp : 12.sp,
                                        color: goldColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Days Selector (Modern Circular Design)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(7, (index) {
                                    final actualDays = [6, 7, 1, 2, 3, 4, 5];
                                    int day = actualDays[index];
                                    bool isSelected =
                                        _selectedDays.contains(day);
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => _toggleDay(day),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            width: 42.w,
                                            height: 42.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: isSelected
                                                  ? LinearGradient(
                                                      colors: [
                                                        goldColor,
                                                        goldColor
                                                            .withOpacity(0.8),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : null,
                                              color: isSelected
                                                  ? null
                                                  : (isDark
                                                      ? Colors.white
                                                          .withOpacity(0.05)
                                                      : Colors.grey
                                                          .withOpacity(0.1)),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: goldColor
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ]
                                                  : [],
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.transparent
                                                    : (isDark
                                                        ? Colors.white12
                                                        : Colors.black12),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _getDayAbbr(day),
                                                   style: TextStyle(
                          fontFamily: "cairo",
                                                  fontSize: context.isTab
                                                      ? 9.sp
                                                      : 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isDark
                                                          ? Colors.white70
                                                          : Colors.black54),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _getDayName(day).length > 6
                                              ? _getDayName(day).substring(0, 7)
                                              : _getDayName(day),
                                             style: TextStyle(
                          fontFamily: "cairo",
                                            fontSize: 10.sp,
                                            color: isSelected
                                                ? goldColor
                                                : textColor.withOpacity(0.5),
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Challenge Rule Card
                        StaggeredItemAnimation(
                          index: 3,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: goldColor.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: goldColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.info_outline_rounded,
                                      color: goldColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "تنبيه: هذا المنبه مصمم ليوقظك بذكاء؛ لن يتوقف الصوت إلا بعد فتح التطبيق وإتمام 20 صلاة على النبي ﷺ.",
                                    style: TextStyle(
                                      fontFamily: "cairo",
                                      fontSize: 11.sp,
                                      color: textColor.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 32),
                        // Settings List
                        StaggeredItemAnimation(
                          index: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildSettingsTile(
                                  title: "تفعيل المنبه",
                                  subtitle: "تشغيل أو إيقاف المنبه بالكامل",
                                  icon: Icons.alarm,
                                  dragging: Switch(
                                    value: _isEnabled,
                                    activeColor: goldColor,
                                    onChanged: (val) {
                                      setState(() => _isEnabled = val);
                                    },
                                  ),
                                  textColor: textColor,
                                ),
                                const Divider(height: 1, indent: 50),
                                _buildSettingsTile(
                                  title: "اهتزاز الهاتف",
                                  subtitle: "تفعيل الاهتزاز مع الصوت",
                                  icon: Icons.vibration,
                                  dragging: Switch(
                                    value: _vibrate,
                                    activeColor: goldColor,
                                    onChanged: (val) =>
                                        setState(() => _vibrate = val),
                                  ),
                                  textColor: textColor,
                                ),
                                const Divider(height: 1, indent: 50),
                                _buildSettingsTile(
                                  title: "تدرج الصوت",
                                  subtitle: "يبدأ الصوت منخفضاً ثم يرتفع",
                                  icon: Icons.volume_up_rounded,
                                  dragging: Switch(
                                    value: _fadeIn,
                                    activeColor: goldColor,
                                    onChanged: (val) =>
                                        setState(() => _fadeIn = val),
                                  ),
                                  textColor: textColor,
                                ),
                                const Divider(height: 1, indent: 50),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37)
                                          .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.snooze,
                                        color: Color(0xFFD4AF37), size: 20),
                                  ),
                                  title: Text(
                                    "عدد التنبيهات (غفوة)",
                                       style: TextStyle(
                          fontFamily: "cairo",
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => setState(() =>
                                            _repetitions = (_repetitions > 1)
                                                ? _repetitions - 1
                                                : 1),
                                        icon: Icon(Icons.remove_circle_outline,
                                            color: textColor.withOpacity(0.5)),
                                      ),
                                      Text(
                                        _toArabicNums(_repetitions.toString()),
                                        style: GoogleFonts.barlow(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: goldColor,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => setState(() =>
                                            _repetitions = (_repetitions < 5)
                                                ? _repetitions + 1
                                                : 5),
                                        icon: Icon(Icons.add_circle_outline,
                                            color: textColor.withOpacity(0.5)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // const SizedBox(height: 16),
                        // // Test Button
                        // FadeAnimation(
                        //   delay: const Duration(milliseconds: 600),
                        //   child: Center(
                        //     child: TextButton.icon(
                        //       onPressed: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (_) => const AdhanOverlayScreen(
                        //               prayerName: "الفجر",
                        //               cityName: "تجربة المنبه",
                        //               prayerTime: "04:30 ص",
                        //             ),
                        //           ),
                        //         );
                        //       },
                        //       icon: Icon(Icons.play_circle_outline, color: goldColor),
                        //       label: Text(
                        //         "تجربة شكل المنبه",
                        //         style: GoogleFonts.cairo(
                        //             color: goldColor, fontWeight: FontWeight.bold),
                        //       ),
                        //       style: TextButton.styleFrom(
                        //         backgroundColor: goldColor.withOpacity(0.1),
                        //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 32),

                        // Quote
                        FadeAnimation(
                          delay: const Duration(milliseconds: 800),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: goldColor.withOpacity(0.2), width: 1),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.format_quote,
                                    color: goldColor, size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  _currentQuote,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.amiri(
                                    fontSize: 16.sp,
                                    height: 1.8,
                                    color: textColor.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Save Button (Fixed at bottom)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: FadeAnimation(
                delay: const Duration(milliseconds: 1000),
                child: ElevatedButton(
                  onPressed: _applySettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: goldColor.withOpacity(0.4),
                  ),
                  child: _isCheckingPermissions
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              // CircularProgressIndicator(
                              //   color: Colors.white,
                              //   strokeWidth: 2.5,
                              // ),
                              KLoading.progressIOSIndicator(
                                  context: context,
                                  progressColor: Colors.white))
                      : Text(
                          "حفظ التغييرات",
                             style: TextStyle(
                          fontFamily: "cairo",
                            fontSize: context.isTab
                                ? 10.sp
                                : 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget dragging,
    required Color textColor,
  }) {
    final bool isTap = context.isTab;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      ),
      title: Text(
        title,
           style: TextStyle(
                          fontFamily: "cairo",
          fontSize: isTap ? 10.sp : 14.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
           style: TextStyle(
                          fontFamily: "cairo",
          fontSize: isTap ? 8.sp : 11.sp,
          color: textColor.withOpacity(0.6),
        ),
      ),
      trailing: dragging,
    );
  }
}
