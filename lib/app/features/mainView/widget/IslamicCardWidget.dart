import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/style/app_theme_colors.dart';

class IslamicCardWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const IslamicCardWidget({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDark = context.isDark;

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use the available height of the card, not the whole screen
          final iconSize = constraints.maxHeight * 0.45; // ~45% of card height

          return Container(
            // Let the parent (Grid / Row / etc.) decide the size
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? Theme.of(context).scaffoldBackgroundColor : null,
              image: isDark
                  ? null
                  : const DecorationImage(
                      opacity: 0.4,
                      image: AssetImage("assets/images/8180jjj00005.webp"),
                      fit: BoxFit.cover,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).cardColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDark ? Colors.white : const Color(0xFFD4AF37),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding:  EdgeInsets.all(isTablet?8:0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon takes flexible space
                  SizedBox(
                    height: iconSize,
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Text can wrap and will not overflow
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beiruti(
                        fontSize: isTablet ? 9.sp : 15.sp,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void showThemeSheet(
  BuildContext ctx, {
  VoidCallback? onLocationChanged, // 👈 باراميتر مُسمّى
}) {
  final cubit = CentralizedCubit.get(ctx);
  final currentTheme = cubit.themeMode();
  final currentFont = cubit.azkarFontSize();

  double tempFont = currentFont;
  ThemeMode tempTheme = currentTheme;
  final isDark = Theme.of(ctx).brightness == Brightness.dark;

  final Color primary = Theme.of(ctx).primaryColor;
  const Color accentGold = Color(0xFFD4AF37);

  // مفاتيح SharedPreferences
  const String kCountryKey = 'selected_country';
  const String kCityKey = 'selected_city';
  const String kAllowLocationKey = 'allow_location_usage';

  // بيانات الموقع داخل الـ BottomSheet
  Map<String, dynamic> countries = {};
  String? selectedCountry;
  String? selectedCity;
  bool isLocationLoading = true;
  bool locationInitialized = false;
  bool allowLocationUsage = true;

  // نفس منطق حساب المسافة من TimingScreen
  double haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * (math.pi / 180);
    final dLon = (lon2 - lon1) * (math.pi / 180);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return R * c;
  }

  Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> loadLocationData(void Function(void Function()) setState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString(kCountryKey);
      final savedCity = prefs.getString(kCityKey);
      final savedAllow = prefs.getBool(kAllowLocationKey);

      final String response =
          await rootBundle.loadString('assets/images/egypt_governorates.json');
      final data = json.decode(response) as Map<String, dynamic>;

      final Map<String, dynamic> loadedCountries = data;

      final defaultCountry = loadedCountries.keys.contains('مصر')
          ? 'مصر'
          : loadedCountries.keys.first;

      String country =
          savedCountry != null && loadedCountries.keys.contains(savedCountry)
              ? savedCountry
              : defaultCountry;

      Map<String, dynamic> loadedCities = (loadedCountries[country]
          as Map<String, dynamic>)
        ..removeWhere((k, v) => v == null);

      String city = (savedCity != null && loadedCities.keys.contains(savedCity))
          ? savedCity
          : loadedCities.keys.first;

      setState(() {
        countries = loadedCountries;
        selectedCountry = country;
        selectedCity = city;
        allowLocationUsage = savedAllow ?? true;
        isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        isLocationLoading = false;
      });
    }
  }

  Future<void> saveLocation(bool saveAllow) async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedCountry != null) {
      await prefs.setString(kCountryKey, selectedCountry!);
    }
    if (selectedCity != null) {
      await prefs.setString(kCityKey, selectedCity!);
    }
    await prefs.setBool('is_using_gps', allowLocationUsage);
  }

  // تحديد أقرب مدينة تلقائيًا داخل الـ BottomSheet
  Future<void> selectByLocationInSheet(
    void Function(void Function()) setState,
    BuildContext context,
  ) async {
    final ok = await ensureLocationPermission();
    if (!ok) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('تعذّر استخدام الموقع. تحقق من الصلاحيات وخدمة الموقع.'),
      //     ),
      //   );
      KHelper.showError(
          message: 'تعذّر استخدام الموقع. تحقق من الصلاحيات وخدمة الموقع.');

      setState(() {
        allowLocationUsage = false;
      });
      await saveLocation(true);
      if (onLocationChanged != null) onLocationChanged(); // 👈 بعد الحفظ

      return;
    }

    // الحصول على إحداثيات المستخدم
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final userLat = pos.latitude;
    final userLng = pos.longitude;

    String? bestCountry;
    String? bestCity;
    double bestDist = double.infinity;

    countries.forEach((country, cityMap) {
      final Map<String, dynamic> m = cityMap ?? {};
      m.forEach((cityName, v) {
        final lat = (v?['lat'])?.toDouble();
        final lng = (v?['lng'])?.toDouble();
        if (lat == null || lng == null) return;
        final d = haversine(userLat, userLng, lat, lng);
        if (d < bestDist) {
          bestDist = d;
          bestCountry = country;
          bestCity = cityName;
        }
      });
    });

    if (bestCountry != null && bestCity != null) {
      // إذا كانت أقرب مدينة تبعد أكثر من 100 كم، نعرض "موقعي الحالي"
      final String displayCity = (bestDist > 100) ? 'موقعي الحالي' : bestCity!;
      final String displayCountry = (bestDist > 100) ? 'GPS' : bestCountry!;

      setState(() {
        selectedCountry = displayCountry;
        selectedCity = displayCity;
      });
      await saveLocation(true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', userLat);
      await prefs.setDouble('longitude', userLng);

      if (onLocationChanged != null) onLocationChanged();
      KHelper.showSuccess(message: 'تم تحديد الموقع: $bestCountry - $bestCity');

      // ScaffoldMessenger.of(context).showSnackBar(
      // SnackBar(
      //   content: Text('تم تحديد الموقع: $bestCountry - $bestCity'),
      // ),

      // );
    } else {
      KHelper.showError(message: 'لم يتم العثور على مدينة مناسبة في البيانات.');

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('لم يتم العثور على مدينة مناسبة في البيانات.'),
      //   ),
      // );
    }
  }

  showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (bc) {
      return SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          const Color(0xFF0B0F16),
                          const Color(0xFF111827),
                        ]
                      : [
                          const Color(0xFFFDFCF8),
                          const Color(0xFFF3F1E8),
                        ],
                ),
                border: Border.all(
                  color: accentGold.withOpacity(0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  if (!locationInitialized) {
                    locationInitialized = true;
                    loadLocationData(setState);
                  }

                  final bool hasChanges =
                      tempTheme != currentTheme || tempFont != currentFont;

                  Widget sectionTitle(String text, IconData icon) {
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.1),
                          ),
                          child: Icon(icon, size: 18, color: primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize:
                                ResponsiveUtil.isTablet(context) ? 16 : 13.sp,
                            fontFamily: "cairo",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }

                  Widget themeChip(
                      String title, IconData icon, ThemeMode mode) {
                    final bool selected = tempTheme == mode;
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            tempTheme = mode;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: selected
                                ? primary.withOpacity(0.12)
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? primary
                                  : (isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300),
                              width: selected ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  size: 18,
                                  color: selected ? primary : Colors.grey[600]),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "cairo",
                                    color: selected
                                        ? primary
                                        : (isDark
                                            ? Colors.grey[200]
                                            : Colors.grey[800]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),

                        Text(
                          'الإعدادات',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "cairo",
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضبط مظهر التطبيق وحجم الخط والموقع بما يناسبك لقراءة الأذكار والقرآن براحة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "cairo",
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // مظهر التطبيق
                        sectionTitle('مظهر التطبيق', Icons.palette_outlined),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            themeChip(
                                'فاتح', Icons.light_mode, ThemeMode.light),
                            themeChip('داكن', Icons.dark_mode, ThemeMode.dark),
                            themeChip('حسب النظام', Icons.phone_android,
                                ThemeMode.system),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Divider(
                          color: isDark ? Colors.white10 : Colors.grey.shade300,
                          height: 24,
                        ),

                        // حجم الخط
                        sectionTitle('حجم خط الأذكار', Icons.text_fields),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'أصغر',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: "cairo",
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              tempFont.toInt().toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "cairo",
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                            Text(
                              'أكبر',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: "cairo",
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14),
                          ),
                          child: Slider(
                            overlayColor: WidgetStatePropertyAll(
                                primary.withOpacity(0.2)),
                            activeColor: primary,
                            inactiveColor:
                                isDark ? Colors.white10 : Colors.grey.shade300,
                            value: tempFont,
                            min: 10,
                            max: 100,
                            divisions: 90,
                            onChanged: (v) {
                              setState(() {
                                tempFont = v;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 6),

                        // معاينة
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'معاينة',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: "cairo",
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سبحان الله وبحمده، سبحان الله العظيم',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: tempFont,
                                  fontFamily: "cairo",
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // الموقع لمواقيت الصلاة
                        sectionTitle(
                            'الموقع لمواقيت الصلاة', Icons.place_outlined),
                        const SizedBox(height: 12),

                        if (isLocationLoading)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.03)
                                  : Colors.blue.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.blue.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (allowLocationUsage
                                                ? Colors.green
                                                : Colors.orange)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        allowLocationUsage
                                            ? Icons.gps_fixed
                                            : Icons.location_on,
                                        color: allowLocationUsage
                                            ? Colors.green
                                            : Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            allowLocationUsage
                                                ? 'تحديد تلقائي (GPS) مفعّل'
                                                : 'تحديد يدوي',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontFamily: "cairo",
                                              fontWeight: FontWeight.bold,
                                              color: allowLocationUsage
                                                  ? Colors.green
                                                  : Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            '${selectedCity ?? "غير محدد"}، ${selectedCountry ?? ""}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "cairo",
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            allowLocationUsage = true;
                                          });
                                          await selectByLocationInSheet(
                                              setState, context);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: allowLocationUsage
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: allowLocationUsage
                                                  ? Colors.green
                                                      .withOpacity(0.3)
                                                  : Colors.grey
                                                      .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'تفعيل الـ GPS',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "cairo",
                                                fontWeight: FontWeight.bold,
                                                color: allowLocationUsage
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          setState(() {
                                            allowLocationUsage = false;
                                          });
                                          await saveLocation(true);
                                          KHelper.showSuccess(
                                              message:
                                                  'يمكنك تغيير المدينة يدوياً من صفحة مواقيت الصلاة.');
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !allowLocationUsage
                                                ? Colors.orange.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: !allowLocationUsage
                                                  ? Colors.orange
                                                      .withOpacity(0.3)
                                                  : Colors.grey
                                                      .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'تحديد يدوي',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "cairo",
                                                fontWeight: FontWeight.bold,
                                                color: !allowLocationUsage
                                                    ? Colors.orange
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // الأزرار
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(bc),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontFamily: "cairo",
                                  color: isDark
                                      ? Colors.grey[200]
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: hasChanges
                                  ? () {
                                      setState(() {
                                        tempTheme = currentTheme;
                                        tempFont = currentFont;
                                      });
                                    }
                                  : null,
                              child: Text(
                                'استرجاع',
                                style: TextStyle(
                                  fontFamily: "cairo",
                                  color: hasChanges
                                      ? primary
                                      : (isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              style: ButtonStyle(
                                elevation: const WidgetStatePropertyAll(0),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                backgroundColor: WidgetStatePropertyAll(
                                    hasChanges
                                        ? primary
                                        : primary.withOpacity(0.4)),
                              ),
                              onPressed: hasChanges
                                  ? () async {
                                      await cubit.setThemeMode(tempTheme);
                                      await cubit.setAzkarFontSize(tempFont);
                                      Navigator.pop(bc);
                                    }
                                  : null,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: Text(
                                  'حفظ',
                                  style: TextStyle(
                                      fontFamily: "cairo", fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

// 📍 عرض الموقع الحالي
Widget buildCurrentLocation(
  BuildContext context,
  bool isDark,
  String selectedCountry,
  String selectedCity,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors:
        //      [Colors.indigo.shade800, Colors.purple.shade900]
        //       // : [Colors.blue.shade100, Colors.purple.shade100],
        // ),
        borderRadius: BorderRadius.circular(16),
        // boxShadow: [
        //   BoxShadow(
        //     color: isDark ? Colors.black38 : Colors.blue.withOpacity(0.2),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
        color: AppThemeColors.cardBackgroundColor(context)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.place_rounded,
          color: isDark ? Colors.amberAccent : Colors.blue.shade800,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '$selectedCountry - $selectedCity',
          style: TextStyle(
            fontFamily: "cairo",
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    ),
  );
}

// void showThemeSheet(BuildContext ctx) {
//   final cubit = CentralizedCubit.get(ctx);
//   final currentTheme = cubit.themeMode();
//   final currentFont = cubit.azkarFontSize();
//
//   double tempFont = currentFont;
//   ThemeMode tempTheme = currentTheme;
//   final isDark = Theme.of(ctx).brightness == Brightness.dark;
//
//   final Color primary = isDark ? AppColors.primary : const Color(0xFF1B5E20); // أخضر هادئ
//   final Color accentGold = const Color(0xFFD4AF37);
//
//   showModalBottomSheet(
//     context: ctx,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (bc) {
//       return SafeArea(
//         child: Directionality(
//           textDirection: TextDirection.rtl,
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: isDark
//                       ? [
//                     const Color(0xFF0B0F16),
//                     const Color(0xFF111827),
//                   ]
//                       : [
//                     const Color(0xFFFDFCF8),
//                     const Color(0xFFF3F1E8),
//                   ],
//                 ),
//                 border: Border.all(
//                   color: accentGold.withOpacity(0.7),
//                   width: 1.2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: StatefulBuilder(
//                 builder: (context, setState) {
//                   final bool hasChanges =
//                       tempTheme != currentTheme || tempFont != currentFont;
//
//                   Widget sectionTitle(String text, IconData icon) {
//                     return Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: primary.withOpacity(0.1),
//                           ),
//                           child: Icon(icon, size: 18, color: primary),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           text,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontFamily: "cairo",
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//
//                   Widget themeChip(String title, IconData icon, ThemeMode mode) {
//                     final bool selected = tempTheme == mode;
//                     return Expanded(
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(12),
//                         onTap: () {
//                           setState(() {
//                             tempTheme = mode;
//                           });
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 180),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 10),
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: selected
//                                 ? primary.withOpacity(0.12)
//                                 : Colors.transparent,
//                             border: Border.all(
//                               color: selected
//                                   ? primary
//                                   : (isDark
//                                   ? Colors.white24
//                                   : Colors.grey.shade300),
//                               width: selected ? 1.4 : 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(icon,
//                                   size: 18,
//                                   color:
//                                   selected ? primary : Colors.grey[600]),
//                               const SizedBox(width: 6),
//                               Flexible(
//                                 child: Text(
//                                   title,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     fontFamily: "cairo",
//                                     color: selected
//                                         ? primary
//                                         : (isDark
//                                         ? Colors.grey[200]
//                                         : Colors.grey[800]),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//
//                   return SingleChildScrollView(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 4,
//                           margin: const EdgeInsets.only(bottom: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(100),
//                           ),
//                         ),
//
//                         // عنوان رئيسي
//                         Text(
//                           'الإعدادات',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontFamily: "cairo",
//                             fontWeight: FontWeight.bold,
//                             color: isDark ? Colors.white : Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'اضبط مظهر التطبيق وحجم الخط بما يناسبك لقراءة الأذكار والقرآن براحة.',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontFamily: "cairo",
//                             color: isDark
//                                 ? Colors.grey[300]
//                                 : Colors.grey.shade700,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//
//                         // قسم الثيم
//                         sectionTitle('مظهر التطبيق', Icons.palette_outlined),
//                         const SizedBox(height: 10),
//
//                         Row(
//                           children: [
//                             themeChip('فاتح', Icons.light_mode, ThemeMode.light),
//                             themeChip('داكن', Icons.dark_mode, ThemeMode.dark),
//                             themeChip('حسب النظام', Icons.phone_android,
//                                 ThemeMode.system),
//                           ],
//                         ),
//
//                         const SizedBox(height: 18),
//                         Divider(
//                           color: isDark
//                               ? Colors.white10
//                               : Colors.grey.shade300,
//                           height: 24,
//                         ),
//
//                         // قسم حجم الخط
//                         sectionTitle('حجم خط الأذكار', Icons.text_fields),
//                         const SizedBox(height: 8),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'أصغر',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontFamily: "cairo",
//                                 color: isDark
//                                     ? Colors.grey[300]
//                                     : Colors.grey.shade700,
//                               ),
//                             ),
//                             Text(
//                               tempFont.toInt().toString(),
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontFamily: "cairo",
//                                 fontWeight: FontWeight.w600,
//                                 color: primary,
//                               ),
//                             ),
//                             Text(
//                               'أكبر',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontFamily: "cairo",
//                                 color: isDark
//                                     ? Colors.grey[300]
//                                     : Colors.grey.shade700,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         SliderTheme(
//                           data: SliderTheme.of(context).copyWith(
//                             trackHeight: 3,
//                             thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 7),
//                             overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 14),
//                           ),
//                           child: Slider(
//                             overlayColor:
//                             WidgetStatePropertyAll(primary.withOpacity(0.2)),
//                             activeColor: primary,
//                             inactiveColor: isDark
//                                 ? Colors.white10
//                                 : Colors.grey.shade300,
//                             value: tempFont,
//                             min: 10,
//                             max: 100,
//                             divisions: 90,
//                             onChanged: (v) {
//                               setState(() {
//                                 tempFont = v;
//                               });
//                             },
//                           ),
//                         ),
//
//                         const SizedBox(height: 6),
//
//                         // معاينة بسيطة
//                         Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: isDark
//                                 ? Colors.white.withOpacity(0.03)
//                                 : Colors.white,
//                             border: Border.all(
//                               color: isDark
//                                   ? Colors.white12
//                                   : Colors.grey.shade300,
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               Text(
//                                 'معاينة',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontFamily: "cairo",
//                                   color: isDark
//                                       ? Colors.grey[300]
//                                       : Colors.grey.shade700,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'سبحان الله وبحمده، سبحان الله العظيم',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: tempFont,
//                                   fontFamily: "cairo",
//                                   height: 1.4,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 18),
//
//                         // الأزرار
//                         Row(
//                           children: [
//                             TextButton(
//                               onPressed: () => Navigator.pop(bc),
//                               child: Text(
//                                 'إلغاء',
//                                 style: TextStyle(
//                                   fontFamily: "cairo",
//                                   color: isDark
//                                       ? Colors.grey[200]
//                                       : Colors.grey.shade800,
//                                 ),
//                               ),
//                             ),
//                             const Spacer(),
//                             TextButton(
//                               onPressed: hasChanges
//                                   ? () {
//                                 setState(() {
//                                   tempTheme = currentTheme;
//                                   tempFont = currentFont;
//                                 });
//                               }
//                                   : null,
//                               child: Text(
//                                 'استرجاع',
//                                 style: TextStyle(
//                                   fontFamily: "cairo",
//                                   color: hasChanges
//                                       ? primary
//                                       : (isDark
//                                       ? Colors.grey[600]
//                                       : Colors.grey[400]),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             ElevatedButton(
//                               style: ButtonStyle(
//                                 elevation: const WidgetStatePropertyAll(0),
//                                 shape: WidgetStatePropertyAll(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 backgroundColor:
//                                 WidgetStatePropertyAll(hasChanges
//                                     ? primary
//                                     : primary.withOpacity(0.4)),
//                               ),
//                               onPressed: hasChanges
//                                   ? () async {
//                                 await cubit.setThemeMode(tempTheme);
//                                 await cubit.setAzkarFontSize(tempFont);
//                                 Navigator.pop(bc);
//                               }
//                                   : null,
//                               child: const Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 10, vertical: 4),
//                                 child: Text(
//                                   'حفظ',
//                                   style: TextStyle(
//                                       fontFamily: "cairo", fontSize: 14),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
