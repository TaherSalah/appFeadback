import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/QiblaView/QiblaDirection.dart';
import 'package:muslimdaily/app/features/azanView/azanView.dart';
import 'package:muslimdaily/app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:muslimdaily/app/features/hadith_books/presentation/nine_books_screen.dart';
import 'package:muslimdaily/app/features/mainView/widget/HomeScreenBuilder.dart';
import 'package:muslimdaily/app/features/radio/QuranRadioView.dart';
import 'package:muslimdaily/app/features/settings/settings_view.dart';
import 'package:muslimdaily/app/core/widgets/CustomGradientDialog.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _radioKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _qiblaKey = GlobalKey();

  int _currentIndex = 0;
  final Set<int> _loadedIndices = {0};

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasShownShowcase = prefs.getBool('showcase_main_nav') ?? false;

    if (!hasShownShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _homeKey,
          _qiblaKey,
          _radioKey,
          _settingsKey,
        ]);
        prefs.setBool('showcase_main_nav', true);
      });
    }
  }

  List<Widget> _buildScreens() {
    return [
      const MainViewBuilder(), // 0: Home
      const CalendarScreen(), // 1: Calendar
      QiblaDirection(isActive: _currentIndex == 2), // 2: Qibla
      const QuranRadioView(), // 3: Radio
      const SettingsView(), // 4: Settings
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _loadedIndices.add(index);
    });
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final navBarColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final selectedItemColor = const Color(0xFFD4AF37); // Gold color
    final unselectedItemColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ShowCaseWidget(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            if (_currentIndex != 0) {
              setState(() {
                _currentIndex = 0;
              });
              return false;
            } else {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return CustomGradientDialog(
                    title: "الخروج من التطبيق",
                    message: "هل أنت متأكد أنك تريد الخروج من التطبيق؟",
                    icon: Icons.power_settings_new_rounded,
                    gradientColors: isDark
                        ? [const Color(0xFF991B1B), const Color(0xFF7F1D1D)]
                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    isDark: isDark,
                    onPrimaryPressed: () => Navigator.of(context).pop(true),
                    primaryButtonText: "خروج",
                    primaryButtonColor: isDark
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFFDC2626),
                    onSecondaryPressed: () => Navigator.of(context).pop(false),
                    secondaryButtonText: "إلغاء",
                  );
                },
              );
              return shouldExit ?? false;
            }
          },
          child: Scaffold(
            extendBody: true, // Allows content to flow behind the FAB
            body: IndexedStack(
              index: _currentIndex,
              children: (() {
                final screens = _buildScreens();
                return List.generate(screens.length, (index) {
                  return _loadedIndices.contains(index)
                      ? screens[index]
                      : const SizedBox.shrink();
                });
              })(),
            ),
            floatingActionButton: Showcase(
              key: _qiblaKey,
              description: 'اضغط هنا لتحديد اتجاه القبلة بدقة',
              child: Container(
                height: 65,
                width: 65,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // gradient: LinearGradient(
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  //   colors: [
                  //     const Color(0xFFD4AF37),
                  //     const Color(0xFFFFD700),
                  //   ],
                  // ),
                  color: Colors.transparent,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: primaryColor.withOpacity(0.4),
                  //     blurRadius: 8,
                  //     spreadRadius: 2,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: FloatingActionButton(
                  onPressed: () =>
                      _onTabTapped(2), // Index 2 is Hadith (Center)
                  backgroundColor: Colors.transparent,
                  elevation: 0,

                  // child: Icon(
                  //   Icons.compass_calibration_rounded,
                  //   size: 30,
                  //   color: Colors.white,
                  // ),
                  child: Image.asset(
                    "assets/images/qibla.png",
                    height: 65,
                    width: 65,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 70,
              color: navBarColor,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              elevation: 10,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Right Side (Home & Prayer)
                  Showcase(
                    key: _homeKey,
                    description: 'العودة للشاشة الرئيسية ومواقيت الصلاة',
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.home_filled,
                      label: 'الرَّئِيسِيَّة',
                      isSelected: _currentIndex == 0,
                      color: selectedItemColor,
                      unselectedColor: unselectedItemColor,
                    ),
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.calendar_month_outlined,
                    label: 'التَّقْوِيمُ',
                    isSelected: _currentIndex == 1,
                    color: selectedItemColor,
                    unselectedColor: unselectedItemColor,
                  ),

                  // Spacer for FAB
                  const SizedBox(width: 48),

                  // Left Side (Radio & Settings)
                  Showcase(
                    key: _radioKey,
                    description: 'استمع للقرآن الكريم مباشرة عبر إذاعاتنا',
                    child: _buildNavItem(
                      index: 3,
                      icon: Icons.radio_rounded,
                      label: 'الرَّادِيُو',
                      isSelected: _currentIndex == 3,
                      color: selectedItemColor,
                      unselectedColor: unselectedItemColor,
                    ),
                  ),
                  Showcase(
                    key: _settingsKey,
                    description: 'تخصيص إعدادات التطبيق والتنبيهات',
                    child: _buildNavItem(
                      index: 4,
                      icon: Icons.settings_rounded,
                      label: 'الإِعْدَادَاتُ',
                      isSelected: _currentIndex == 4,
                      color: selectedItemColor,
                      unselectedColor: unselectedItemColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required Color unselectedColor,
  }) {
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? color : unselectedColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : unselectedColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
