import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class LocationSettingsView extends StatefulWidget {
  const LocationSettingsView({super.key});

  @override
  State<LocationSettingsView> createState() => _LocationSettingsViewState();
}

class _LocationSettingsViewState extends State<LocationSettingsView> {
  static const String kCountryKey = 'selected_country';
  static const String kCityKey = 'selected_city';
  static const String kAllowLocationKey = 'allow_location_usage';

  Map<String, dynamic> countries = {};
  Map<String, dynamic> cities = {};

  // Local state
  String? tempCountry;
  String? tempCity;
  bool tempAllowLocationUsage = true;

  bool isLocationLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    loadLocationData();
  }

  Future<void> loadLocationData() async {
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

      if (mounted) {
        setState(() {
          countries = loadedCountries;
          tempCountry = country;
          cities = loadedCities;
          tempCity = city;
          tempAllowLocationUsage = savedAllow ?? true;
          isLocationLoading = false;
          _hasChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLocationLoading = false;
        });
      }
    }
  }

  Future<void> _saveLocationChanges() async {
    final prefs = await SharedPreferences.getInstance();
    if (tempCountry != null) {
      await prefs.setString(kCountryKey, tempCountry!);
    }
    if (tempCity != null) {
      await prefs.setString(kCityKey, tempCity!);
    }
    await prefs.setBool(kAllowLocationKey, tempAllowLocationUsage);

    KHelper.showSuccess(message: 'تم حفظ إعدادات الموقع بنجاح');
    setState(() => _hasChanges = false);
  }

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

  Future<void> selectByLocation() async {
    final ok = await ensureLocationPermission();
    if (!ok) {
      KHelper.showError(
          message: 'تعذّر استخدام الموقع. تحقق من الصلاحيات وخدمة الموقع.');
      setState(() {
        tempAllowLocationUsage = false;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري تحديد موقعك الحالي...')),
    );

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
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
        setState(() {
          tempCountry = bestCountry;
          cities = (countries[tempCountry!] as Map<String, dynamic>)
            ..removeWhere((k, v) => v == null);
          tempCity = bestCity;
          tempAllowLocationUsage = true;
          _hasChanges = true;
        });
        KHelper.showSuccess(message: 'تم العثور على موقعك: $bestCity');
      }
    } catch (e) {
      KHelper.showError(
          message: 'تعذر الحصول على الموقع، يرجى المحاولة لاحقاً');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'إعدادات الموقع',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: isDark ? Colors.white : Colors.black87),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF0F172A),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A)
                    ]
                  : [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFE9ECEF),
                      const Color(0xFFF8F9FA)
                    ],
            ),
          ),
          child: isLocationLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.top + 60),
                            _buildSectionHeader(context, 'طريقة التحديد'),
                            _buildSettingsCard(
                              context,
                              children: [
                                SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  title: Text(
                                    'تحديد تلقائي (GPS)',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'اختيار أقرب مدينة بناءً على موقعك الحالي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  value: tempAllowLocationUsage,
                                  activeColor: const Color(0xFFD4AF37),
                                  secondary: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.my_location,
                                        color: Colors.blue, size: 22),
                                  ),
                                  onChanged: (val) async {
                                    if (val) {
                                      await selectByLocation();
                                    } else {
                                      setState(() {
                                        tempAllowLocationUsage = false;
                                        _hasChanges = true;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionHeader(context, 'اختيار يدوي'),
                            _buildSettingsCard(
                              context,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildDropdownField(
                                        context,
                                        label: 'الدولة',
                                        value: tempCountry,
                                        items: countries.keys.toList(),
                                        onChanged: (val) {
                                          if (val == null) return;
                                          final newCities = (countries[val]
                                              as Map<String, dynamic>)
                                            ..removeWhere((k, v) => v == null);
                                          setState(() {
                                            tempCountry = val;
                                            cities = newCities;
                                            tempCity = cities.keys.isNotEmpty
                                                ? cities.keys.first
                                                : null;
                                            _hasChanges = true;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDropdownField(
                                        context,
                                        label: 'المدينة',
                                        value: tempCity,
                                        items: cities.keys.toList(),
                                        onChanged: (val) {
                                          if (val == null) return;
                                          setState(() {
                                            tempCity = val;
                                            _hasChanges = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (tempCountry != null && tempCity != null) ...[
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFD4AF37).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37)
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: Color(0xFFD4AF37)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الموقع المختار: $tempCountry - $tempCity',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD4AF37),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedOpacity(
          opacity: _hasChanges ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            height: 56,
            child: FloatingActionButton.extended(
              onPressed: _hasChanges ? _saveLocationChanges : null,
              backgroundColor: const Color(0xFFD4AF37),
              elevation: _hasChanges ? 8 : 0,
              label: Text(
                'حفظ خيارات الموقع',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, right: 8.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white70 : Colors.black54),
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
