import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';

import '../../../core/shard/exports/all_exports.dart';
import 'morningWidget.dart';
import 'package:intl/intl.dart' as intl;

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

  const PrayerHeaderSection({
    super.key,
    required this.hijriDate,
    required this.gregorian,
    required this.nextPrayer,
    required this.remainingTime,
    required this.onSettingsTap,
    required this.location,
    required this.adjustedPrayers,
    this.progressValue,
    this.backgroundGradient,
    this.iqamaTimeText,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.sizeOf(context);
    final double headerHeight = isTab ? size.height / 2.0 : size.height / 1.8;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // الخلفية (الصورة)
          Positioned.fill(
            child: Image.asset(
              "assets/images/8495460.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // طبقة التدرّج فوق الصورة
          // Positioned.fill(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: isDark
          //             ? [
          //           Colors.black.withOpacity(0.40),
          //           Colors.black.withOpacity(0.85),
          //         ]
          //             : [
          //           Colors.white.withOpacity(0.10),
          //           Colors.white.withOpacity(0.20),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black
                      .withOpacity(0.35) // تغميق قوي للصورة في الوضع الليلي
                  : Colors.white
                      .withOpacity(0.30), // تفتيح/بهتان بسيط في الوضع النهاري
            ),
          ),
          // Top Bar: Notification Icon (Left) + Glass Location Chip (Right)
          Positioned(
            top: 35,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // Glass Location Chip (tappable)
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
                          color: isDark ? const Color(0xFFD4AF37).withOpacity(0.7) : AppColors.primary.withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                // Notification/Reminder Bell instead of Settings Gear
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

          // التاريخ في أعلى اليمين (هجري + ميلادي)
          // Padding(
          //   padding: const EdgeInsets.only(top:45),
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: Column(
          //       // crossAxisAlignment: CrossAxisAlignment.end,
          //       children: [
          //         Container(
          //           padding:
          //           const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(20),
          //             // color: isDark
          //             //     ? Colors.black.withOpacity(0.5)
          //             //     : Colors.white.withOpacity(0.95),
          //             // border: Border.all(
          //             //   color: const Color(0xFFD4AF37).withOpacity(0.7),
          //             //   width: 1,
          //             // ),
          //           ),
          //           child: Column(
          //             children: [
          //               Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   Icon(
          //                     Icons.calendar_today_rounded,
          //                     size: 14,
          //                     color: isDark
          //                         ? AppColors.greyLightColor
          //                         : const Color(0xFF1B5E20),
          //                   ),
          //                   const SizedBox(width: 6),
          //                   TextDefaultWidget(
          //                     title: hijriDate,
          //                     fontSize: isTab ? 10.sp : 12.sp,
          //                     fontFamily: "cairo",
          //                     fontWeight: FontWeight.w600,
          //                     color: isDark
          //                         ? AppColors.greyLightColor
          //                         : Colors.black,
          //                   ),
          //                 ],
          //               ),
          //               const SizedBox(height: 10),
          //               TextDefaultWidget(
          //                 title: gregorian,
          //                 fontSize: isTab ? 9.sp : 11.sp,
          //                 fontFamily: "cairo",
          //                 color: isDark
          //                     ? AppColors.greyLightColor.withOpacity(0.8)
          //                     : Colors.black87.withOpacity(0.7),
          //               ),
          //
          //             ],
          //           ),
          //         ),
          //         Row(
          //           mainAxisSize: MainAxisSize.min,
          //
          //           children: [
          //             Icon(
          //               Icons.location_on_rounded,
          //               size:isTab?25: 16,
          //               color: isDark
          //                   ? AppColors.greyLightColor
          //                   : const Color(0xFFd32f2f),
          //             ),
          //             const SizedBox(width: 4),
          //             TextDefaultWidget(
          //               title: location,
          //               fontSize: isTab ? 9.sp : 11.sp,
          //               fontFamily: "cairo",
          //               fontWeight: FontWeight.w500,
          //               color: isDark
          //                   ? AppColors.greyLightColor
          //                   : Colors.black87,
          //             ),
          //           ],
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          // كارت "الصلاة القادمة" في الأسفل

          Padding(
            padding: EdgeInsets.only(top: isTab ? 85 : 80),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 19 : 16.0, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 14, vertical: isTab ? 18 : 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // تدرج لوني جذاب وحيوي
                    gradient: isDark
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1a1a2e).withOpacity(0.85),
                              const Color(0xFF16213e).withOpacity(0.75),
                            ],
                          )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFFFDFDFD),
                          const Color(0xFFF5F5F5),
                        ],
                      ),
                    // حد ناعم
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFD4AF37).withOpacity(0.6)
                          : KColors.primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // ظل خارجي للعمق
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                      // ظل داخلي للإضاءة
                      if (!isDark)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: -5,
                          offset: const Offset(0, -2),
                        ),
                      // ظل ذهبي متوهج
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      // إضافة خلفية داخلية بنقش إسلامي خفيف (اختياري)
                      gradient: isDark
                          ? null
                          : LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFFD4AF37).withOpacity(0.02),
                              ],
                            ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
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
                            // Glass-style date chip (Gregorian)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              ),
                              child: TextDefaultWidget(
                                title: gregorian,
                                fontSize: isTab ? 8.sp : 11.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "cairo",
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF5D6D7E),
                              ),
                            ),

                            // Premium hijri date with icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextDefaultWidget(
                                  title: hijriDate,
                                  fontSize: isTab ? 8.sp : 12.sp,
                                  fontFamily: "cairo",
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFD4AF37)
                                      : const Color(0xFF1B5E20),
                                ),
                                // const SizedBox(width: 6),
                                // Icon(
                                //   Icons.calendar_month_rounded,
                                //   size: isTab ? 20 : 16,
                                //   color: isDark
                                //       ? const Color(0xFFD4AF37).withOpacity(0.8)
                                //       : const Color(0xFF1B5E20).withOpacity(0.8),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // العنوان + اسم الصلاة
                        // الوقت المتبقي + شريط بسيط
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isTab ? 10 : 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isDark
                                        ? LinearGradient(
                                            colors: [
                                              const Color(0xFF1B5E20)
                                                  .withOpacity(0.8),
                                              const Color(0xFF2E7D32)
                                                  .withOpacity(0.6),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Colors.white,
                                              const Color(0xFFFFFBF0),
                                            ],
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0xFFD4AF37)
                                                .withOpacity(0.2)
                                            : const Color(0xFF1B5E20)
                                                .withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.timer_outlined,
                                    size: isTab ? 22 : 18,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextDefaultWidget(
                                    title: nextPrayer,
                                    fontFamily: "cairo",
                                    fontSize: isTab ? 8.sp : 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : const Color(0xFF2C3E50)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildPremiumCountdown(
                                context, remainingTime, isDark, isTab),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // عرض كافة المواقيت أفقيًا
                        _buildHorizontalPrayerTimes(context, isDark, isTab),
                        const SizedBox(height: 12),
                        // عرض أوقات السنن
                        _buildSunnahTimes(context, isDark, isTab),
                        const SizedBox(height: 10),
                        // شريط التقدم بتصميم جذاب
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
                                // الخلفية
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
                                // شريط التقدم
                                LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: isTab ? 8 : 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? const Color(0xFFD4AF37)
                                        : const Color(0xFF1B5E20),
                                  ),
                                ),
                                // لمعة على الشريط
                                if (progressValue != null && progressValue! > 0)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      height: isTab ? 8 : 6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPrayerTimes(BuildContext context, bool isDark, bool isTab) {
    final prayers = ["الإمساك", "الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء", "السحور"];
    final Map<String, IconData> icons = {
      "الإمساك": Icons.timer_outlined,
      "الفجر": Icons.wb_twilight,
      "الشروق": Icons.wb_sunny,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: isUpcoming ? FontWeight.bold : FontWeight.normal,
                    color: isUpcoming ? (isDark ? Colors.white : KColors.primaryColor) : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                Icon(
                  icons[name],
                  size: 18,
                  color: isUpcoming ? KColors.primaryColor : (isDark ? Colors.white38 : Colors.grey.shade400),
                ),
                Text(
                  intl.DateFormat('h:mm a').format(time.toLocal()),
                  style: GoogleFonts.cairo(
                    fontSize: 9.sp,
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
    final midnight = adjustedPrayers["منتصف الليل"];
    final lastThird = adjustedPrayers["الثلث الأخير"];
    
    if (midnight == null || lastThird == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSunnahChip("منتصف الليل", midnight, isDark),
        const SizedBox(width: 8),
        Text("|", style: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade300)),
        const SizedBox(width: 8),
        _buildSunnahChip("الثلث الأخير", lastThird, isDark),
      ],
    );
  }

  Widget _buildSunnahChip(String label, DateTime time, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            intl.DateFormat('h:mm').format(time.toLocal()),
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.blue.shade300 : KColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCountdown(
      BuildContext context, String time, bool isDark, bool isTab) {
    // Expected format "HH:mm:ss"
    final parts = time.split(':');
    if (parts.length < 3) return const SizedBox();

    final hours = parts[0];
    final minutes = parts[1];
    final seconds = parts[2];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCountdownUnit(hours, "ساعة", isDark, isTab),
        _buildSeparator(isDark),
        _buildCountdownUnit(minutes, "دقيقة", isDark, isTab),
        _buildSeparator(isDark),
        _buildCountdownUnit(seconds, "ثانية", isDark, isTab),
      ],
    );
  }

  Widget _buildCountdownUnit(
      String value, String label, bool isDark, bool isTab) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isTab ? 10 : 6, vertical: isTab ? 6 : 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.3),
                      const Color(0xFFD4AF37).withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1B5E20).withOpacity(0.15),
                      const Color(0xFF1B5E20).withOpacity(0.05),
                    ],
                  ),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFD4AF37).withOpacity(0.4)
                  : const Color(0xFF1B5E20).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: TextDefaultWidget(
              key: ValueKey<String>(value),
              title: value,
              fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: isTab ? 11.sp : 14.sp,
              color: isDark ? Colors.amberAccent : const Color(0xFF1B5E20),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTab ? 6.sp : 9.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(bool isDark) {
    return Padding(
      padding: const Offset(0, 2) == const Offset(0, 2) ? const EdgeInsets.only(bottom: 10, left: 4, right: 4) : EdgeInsets.zero,
      child: Text(
        ":",
        style: TextStyle(
          color: isDark ? Colors.amberAccent : const Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

