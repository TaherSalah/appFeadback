import 'package:intl/intl.dart' as intl;
import 'package:muslimdaily/app/core/utils/style/k_color.dart';

import '../../../core/shard/exports/all_exports.dart';
import 'morningWidget.dart';

class PrayerHeaderSection extends StatelessWidget {
  final String hijriDate;
  final String location;
  final String gregorian;
  final String nextPrayer;
  final String remainingTime;
  final VoidCallback onSettingsTap;
  final VoidCallback? onLocationTap;
  final double? progressValue;
  final Map<String, DateTime> adjustedPrayers;
  final List<Color>? backgroundGradient;
  final String? iqamaTimeText;
  final bool isRamadan;

  const PrayerHeaderSection({
    super.key,
    required this.hijriDate,
    required this.gregorian,
    required this.nextPrayer,
    required this.remainingTime,
    required this.onSettingsTap,
    required this.location,
    required this.adjustedPrayers,
    required this.isRamadan,
    this.progressValue,
    this.backgroundGradient,
    this.iqamaTimeText,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTab = context.isTab;
    final isDark = context.isDark;

    final size = MediaQuery.sizeOf(context);
    final double headerHeight = isTab ? size.height / 2.0 : size.height / 1.8;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: headerHeight),
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/8495460.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Overlay color
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.white.withOpacity(0.30),
            ),
          ),

          // Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 35),
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onLocationTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.white.withOpacity(0.85),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFD4AF37).withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.1),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFFD4AF37) : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            TextDefaultWidget(
                              title: location,
                              fontSize: isTab ? 8.sp : 10.sp,
                              fontFamily: "cairo",
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: isDark
                                  ? const Color(0xFFD4AF37).withOpacity(0.7)
                                  : AppColors.primary.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onSettingsTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.settings,
                          size: isTab ? 26 : 22,
                          color: isDark ? const Color(0xFFD4AF37) : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer Card
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 19 : 16.0, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: isTab ? 18 : 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1a1a2e).withOpacity(0.85),
                              const Color(0xFF16213e).withOpacity(0.75),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Color(0xFFFDFDFD),
                              Color(0xFFF5F5F5),
                            ],
                          ),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFD4AF37).withOpacity(0.6)
                          : KColors.primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                      if (!isDark)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: -5,
                          offset: const Offset(0, -2),
                        ),
                      BoxShadow(
                        color: isDark
                            ? const Color(0xFFD4AF37).withOpacity(0.1)
                            : KColors.primaryColor.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HalalGreeting(),
                          AdhkarReminder(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                            ),
                            child: TextDefaultWidget(
                              title: gregorian,
                              fontSize: isTab ? 8.sp : 11.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: "cairo",
                              color: isDark ? Colors.white70 : const Color(0xFF5D6D7E),
                            ),
                          ),
                          TextDefaultWidget(
                            title: hijriDate,
                            fontSize: isTab ? 8.sp : 12.sp,
                            fontFamily: "cairo",
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF1B5E20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextDefaultWidget(
                          title: nextPrayer,
                          fontFamily: "cairo",
                          fontSize: isTab ? 8.sp : 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF2C3E50)),
                      const SizedBox(height: 12),
                      _buildPremiumCountdown(context, remainingTime, isDark, isTab),
                      const SizedBox(height: 16),
                      _buildHorizontalPrayerTimes(context, isDark, isTab, isRamadan),
                      const SizedBox(height: 12),
                      _buildSunnahTimes(context, isDark, isTab),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : const Color(0xFFD4AF37).withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Stack(
                            children: [
                              Container(
                                height: isTab ? 8 : 6,
                                decoration: BoxDecoration(
                                  gradient: isDark
                                      ? LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade100,
                                            Colors.grey.shade50,
                                          ],
                                        ),
                                ),
                              ),
                              LinearProgressIndicator(
                                value: progressValue,
                                minHeight: isTab ? 8 : 6,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? const Color(0xFFD4AF37) : const Color(0xFF1B5E20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPrayerTimes(
      BuildContext context, bool isDark, bool isTab, bool isRamadan) {
    final allPrayers = ["الإمساك", "الفجر", "الظهر", "العصر", "المغرب", "العشاء", "السحور"];
    final prayers = allPrayers.where((name) {
      if ((name == "الإمساك" || name == "السحور") && !isRamadan) return false;
      return true;
    }).toList();

    final Map<String, IconData> icons = {
      "الإمساك": Icons.timer_outlined,
      "الفجر": Icons.wb_twilight,
      "الظهر": Icons.light_mode,
      "العصر": Icons.wb_sunny_outlined,
      "المغرب": Icons.wb_twilight,
      "العشاء": Icons.nightlight_round,
      "السحور": Icons.restaurant_menu,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: prayers.map((name) {
          final isUpcoming = nextPrayer.contains(name);
          final time = adjustedPrayers[name];
          if (time == null) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isUpcoming ? (isDark ? Colors.white10 : Colors.blue.shade50) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isUpcoming ? Border.all(color: KColors.primaryColor.withOpacity(0.5)) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 9.sp,
                    fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                    color: isUpcoming ? (isDark ? Colors.white : KColors.primaryColor) : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                Icon(
                  icons[name],
                  size: isTab ? 22 : 16,
                  color: isUpcoming ? KColors.primaryColor : (isDark ? Colors.white38 : Colors.grey.shade400),
                ),
                Text(
                  intl.DateFormat('h:mm a').format(time.toLocal()),
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 8.sp,
                    fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                    color: isUpcoming ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white60 : Colors.black38),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSunnahTimes(BuildContext context, bool isDark, bool isTab) {
    final sunrise = adjustedPrayers["الشروق"];
    final midnight = adjustedPrayers["منتصف الليل"];
    final lastThird = adjustedPrayers["الثلث الأخير"];

    if (sunrise == null && midnight == null && lastThird == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (sunrise != null) _buildSunnahChip("الشروق", sunrise, isDark, isTab),
          if (midnight != null) ...[
            const SizedBox(width: 8),
            _buildSunnahChip("منتصف الليل", midnight, isDark, isTab),
          ],
          if (lastThird != null) ...[
            const SizedBox(width: 8),
            _buildSunnahChip("الثلث الأخير", lastThird, isDark, isTab),
          ],
        ],
      ),
    );
  }

  Widget _buildSunnahChip(String label, DateTime time, bool isDark, bool isTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: TextStyle(fontFamily: "cairo", fontSize: isTap ? 7.sp : 9.sp, color: isDark ? Colors.white70 : Colors.black54)),
          Text(intl.DateFormat('h:mm').format(time.toLocal()), style: TextStyle(fontFamily: "cairo", fontSize: isTap ? 7.sp : 9.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.blue.shade300 : KColors.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildPremiumCountdown(BuildContext context, String time, bool isDark, bool isTab) {
    final parts = time.split(':');
    if (parts.length < 3) return const SizedBox();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCountdownUnit(parts[0], "ساعة", isDark, isTab),
        _buildSeparator(isDark),
        _buildCountdownUnit(parts[1], "دقيقة", isDark, isTab),
        _buildSeparator(isDark),
        _buildCountdownUnit(parts[2], "ثانية", isDark, isTab),
      ],
    );
  }

  Widget _buildCountdownUnit(String value, String label, bool isDark, bool isTab) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isTab ? 10 : 8, vertical: isTab ? 6 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isDark
                ? LinearGradient(colors: [const Color(0xFFD4AF37).withOpacity(0.3), const Color(0xFFD4AF37).withOpacity(0.1)])
                : LinearGradient(colors: [const Color(0xFF1B5E20).withOpacity(0.15), const Color(0xFF1B5E20).withOpacity(0.05)]),
            border: Border.all(color: isDark ? const Color(0xFFD4AF37).withOpacity(0.4) : const Color(0xFF1B5E20).withOpacity(0.2)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: TextDefaultWidget(
              key: ValueKey<String>(value),
              title: value,
              fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: isTab ? 10.sp : 13.sp,
              color: isDark ? Colors.amberAccent : const Color(0xFF1B5E20),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: "cairo", fontSize: isTab ? 6.sp : 8.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
      ],
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4, right: 4),
      child: Text(":", style: TextStyle(color: isDark ? Colors.amberAccent : const Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
