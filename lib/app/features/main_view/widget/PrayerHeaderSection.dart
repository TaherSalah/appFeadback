import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../main.dart';
import '../../Khatmah/data/khatmah_model.dart';
import 'AzkarQuranWidget.dart';
import 'OtherAzkarWidget.dart';
import '../controllar/MainController.dart';
import '../../../core/cubit/centralized_cubit.dart';
import '../../../core/shard/exports/all_exports.dart';
import 'morningWidget.dart';

class PrayerHeaderSection extends StatelessWidget {
  final String hijriDate;
  final String location;
  final String gregorian;
  final String nextPrayer;
  final String remainingTime;
  final VoidCallback onSettingsTap;
  final double? progressValue;

  const PrayerHeaderSection({
    super.key,
    required this.hijriDate,
    required this.gregorian,
    required this.nextPrayer,
    required this.remainingTime,
    required this.onSettingsTap,
    required this.location,
    this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final isTab = ResponsiveUtil.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final size = MediaQuery.sizeOf(context);
    final double headerHeight = isTab ? size.height / 3.1 : size.height / 2.4;

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
          // زر الإعدادات في أعلى اليسار
          Positioned(
            top: 35,
            left: 10,
            child: InkWell(
              onTap: onSettingsTap,
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
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings,
                  size: isTab ? 26 : 22,
                  color: isDark ? AppColors.greyLightColor : Colors.black87,
                ),
              ),
            ),
          ),
          Positioned(
            top: 35,
            right: 10,
            child: Row(children: [
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
                  color: isDark ? KColors.whiteColor : AppColors.primary,
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
                title: location,
                fontSize: isTab ? 8.sp : 11.sp,
                fontFamily: "cairo",
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.greyLightColor : Colors.white,
              ),
            ]),
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
                        Colors.white.withOpacity(0.98),
                        const Color(0xFFFFF8E7).withOpacity(0.95), // لون كريمي ذهبي فاتح
                        const Color(0xFFFFFBF0).withOpacity(0.92),
                      ],
                    ),
                    // حد متدرج يعطي لمعة
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFD4AF37).withOpacity(0.6)
                          : const Color(0xFFD4AF37).withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      // ظل خارجي للعمق
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : const Color(0xFFD4AF37).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: isDark ? 1 : 3,
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
                            : const Color(0xFFD4AF37).withOpacity(0.15),
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HalalGreeting(),
                            AdhkarReminder(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isTab ? 10 : 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isDark
                                        ? LinearGradient(
                                      colors: [
                                        const Color(0xFF1B5E20).withOpacity(0.8),
                                        const Color(0xFF2E7D32).withOpacity(0.6),
                                      ],
                                    )
                                        : const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFFFFBF0),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0xFFD4AF37).withOpacity(0.2)
                                            : const Color(0xFF1B5E20).withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    size: isTab ? 22 : 18,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextDefaultWidget(
                                  title: hijriDate,
                                  fontSize: isTab ? 8.sp : 12.sp,
                                  fontFamily: "cairo",
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.greyLightColor
                                      : const Color(0xFF2C3E50),
                                ),
                              ],
                            ),
                            Container(
                              height: 12,
                              width: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isDark
                                      ? [
                                    const Color(0xFFD4AF37),
                                    const Color(0xFFD4AF37).withOpacity(0.3),
                                  ]
                                      : [
                                    const Color(0xFF1B5E20),
                                    const Color(0xFF1B5E20).withOpacity(0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            TextDefaultWidget(
                              title: gregorian,
                              fontSize: isTab ? 8.sp : 12.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: "cairo",
                              color: isDark
                                  ? AppColors.greyLightColor.withOpacity(0.8)
                                  : const Color(0xFF5D6D7E).withOpacity(0.9),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // خط فاصل جمالي
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                isDark
                                    ? const Color(0xFFD4AF37).withOpacity(0.3)
                                    : const Color(0xFFD4AF37).withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // العنوان + اسم الصلاة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isTab ? 10 : 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isDark
                                        ? LinearGradient(
                                      colors: [
                                        const Color(0xFF1B5E20).withOpacity(0.8),
                                        const Color(0xFF2E7D32).withOpacity(0.6),
                                      ],
                                    )
                                        : const LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Color(0xFFFFFBF0),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? const Color(0xFFD4AF37).withOpacity(0.2)
                                            : const Color(0xFF1B5E20).withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.mosque_outlined,
                                    size: isTab ? 22 : 18,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextDefaultWidget(
                                  title: "الصلاة القادمة",
                                  fontSize: isTab ? 8.sp : 12.sp,
                                  fontFamily: "cairo",
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.greyLightColor
                                      : const Color(0xFF2C3E50),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isDark
                                    ? LinearGradient(
                                  colors: [
                                    const Color(0xFF1B5E20).withOpacity(0.7),
                                    const Color(0xFF2E7D32).withOpacity(0.5),
                                  ],
                                )
                                    : const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFFFBF0),
                                  ],
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFFD4AF37).withOpacity(0.3)
                                      : const Color(0xFF1B5E20).withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                                        : const Color(0xFF1B5E20).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              // child: TextDefaultWidget(
                              //   title: nextPrayer,
                              //   fontFamily: "me",
                              //   fontWeight: FontWeight.bold,
                              //   fontSize: isTab ? 10.sp : 13.sp,
                              //   color: isDark
                              //       ? Colors.white
                              //       : const Color(0xFF1B5E20),
                              // ),
                              child:    TextDefaultWidget(
                                title: nextPrayer,
                                fontSize: isTab ? 8.sp : 12.sp,
                                fontFamily: "cairo",
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.amberAccent
                                    : const Color(0xFF2C3E50),
                              ),

                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // الوقت المتبقي + شريط بسيط
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTab ? 10 : 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isDark
                                    ? LinearGradient(
                                  colors: [
                                    const Color(0xFF1B5E20).withOpacity(0.8),
                                    const Color(0xFF2E7D32).withOpacity(0.6),
                                  ],
                                )
                                    : const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFFFBF0),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                                        : const Color(0xFF1B5E20).withOpacity(0.15),
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
                              title: "الوقت المتبقي",
                              fontFamily: "cairo",
                              fontSize: isTab ? 8.sp : 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF2C3E50),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: isDark
                                    ? LinearGradient(
                                  colors: [
                                    const Color(0xFFD4AF37).withOpacity(0.2),
                                    const Color(0xFFD4AF37).withOpacity(0.1),
                                  ],
                                )
                                    : const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF8E7),
                                    Color(0xFFFFFBF0),
                                  ],
                                ),
                              ),
                              child: TextDefaultWidget(
                                title: remainingTime,
                                fontFamily: "cairo",
                                fontWeight: FontWeight.bold,
                                fontSize: isTab ? 10.sp : 13.sp,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                SizedBox(height:isTab? 5:0,),
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
                      ],
                    ),
                  ),
                ),
                // child: Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(
                //       horizontal: 14, vertical: isTab ? 18 : 12),
                //
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(16),
                //     // تدرج لوني هادئ ومريح للعين في النهار
                //     gradient: isDark
                //         ? null
                //         : LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         Colors.white.withOpacity(0.95),
                //         const Color(0xFFFFFBF0).withOpacity(0.90), // لون كريمي فاتح
                //       ],
                //     ),
                //     color: isDark ? Colors.black.withOpacity(0.45) : null,
                //     border: Border.all(
                //       color: isDark
                //           ? AppColors.primary
                //           : const Color(0xFFD4AF37).withOpacity(0.4), // حد ذهبي شفاف
                //       width: 1.5,
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: isDark
                //             ? Colors.black.withOpacity(0.18)
                //             : const Color(0xFFD4AF37).withOpacity(0.15), // ظل ذهبي خفيف
                //         blurRadius: isDark ? 10 : 15,
                //         spreadRadius: isDark ? 0 : 2,
                //         offset: const Offset(0, 4),
                //       ),
                //       // ظل إضافي للعمق في الوضع النهاري
                //       if (!isDark)
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.05),
                //           blurRadius: 8,
                //           offset: const Offset(0, 2),
                //         ),
                //     ],
                //   ),
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Row(
                //         // crossAxisAlignment: CrossAxisAlignment.center,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         // mainAxisSize: MainAxisSize.min,
                //         children: [
                //           // const SizedBox(width: 8),
                //           // Icon(
                //           //   Icons.calendar_today_rounded,
                //           //   size: 14,
                //           //   color: isDark
                //           //       ? AppColors.greyLightColor
                //           //       : const Color(0xFF1B5E20),
                //           // ),
                //           // const SizedBox(width: 6),
                //           Row(
                //             children: [
                //               Container(
                //                 padding: EdgeInsets.all(isTab ? 10 : 6),
                //                 decoration: BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   color: isDark
                //                       ? Colors.black.withOpacity(0.6)
                //                       : Colors.white.withOpacity(1.00),
                //                 ),
                //                 child: Icon(
                //                   Icons.calendar_month_outlined,
                //                   size: isTab ? 22 : 18,
                //                   color: isDark
                //                       ? KColors.primaryColor
                //                       : const Color(0xFF1B5E20),
                //                 ),
                //               ),
                //               const SizedBox(width: 8),
                //
                //               TextDefaultWidget(
                //                 title: hijriDate,
                //                 fontSize: isTab ? 8.sp : 12.sp,
                //                 fontFamily: "cairo",
                //                 fontWeight: FontWeight.w600,
                //                 color: isDark
                //                     ? AppColors.greyLightColor
                //                     : Colors.black,
                //               ),
                //             ],
                //           ),
                //           Container(
                //             height: 10,
                //             width: 4,
                //             decoration: BoxDecoration(
                //                 color: isDark ? Colors.white : Colors.black,
                //                 borderRadius:
                //                     BorderRadius.all(Radius.circular(15))),
                //           ),
                //           TextDefaultWidget(
                //             title: gregorian,
                //             fontSize: isTab ? 8.sp : 12.sp,
                //             fontWeight: FontWeight.w600,
                //             fontFamily: "cairo",
                //             color: isDark
                //                 ? AppColors.greyLightColor.withOpacity(0.8)
                //                 : Colors.black87.withOpacity(0.7),
                //           ),
                //         ],
                //       ),
                //       const SizedBox(height: 10),
                //
                //       // العنوان + اسم الصلاة
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Row(
                //             children: [
                //               Container(
                //                 padding: EdgeInsets.all(isTab ? 10 : 6),
                //                 decoration: BoxDecoration(
                //                   shape: BoxShape.circle,
                //                   color: isDark
                //                       ? Colors.black.withOpacity(0.6)
                //                       : Colors.white.withOpacity(1.00),
                //                 ),
                //                 child: Icon(
                //                   Icons.mosque_outlined,
                //                   size: isTab ? 22 : 18,
                //                   color: isDark
                //                       ? KColors.primaryColor
                //                       : const Color(0xFF1B5E20),
                //                 ),
                //               ),
                //               const SizedBox(width: 8),
                //               TextDefaultWidget(
                //                 title: "الصلاة القادمة",
                //                 fontSize: isTab ? 8.sp : 12.sp,
                //                 fontFamily: "cairo",
                //                 fontWeight: FontWeight.w600,
                //                 color: isDark
                //                     ? AppColors.greyLightColor
                //                     : Colors.black,
                //               ),
                //             ],
                //           ),
                //           Container(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 10, vertical: 4),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(20),
                //               color: isDark
                //                   ? const Color(0xFF1B5E20)
                //                       .withOpacity(isDark ? 0.6 : 0.30)
                //                   : Colors.white
                //                       .withOpacity(isDark ? 0.6 : 1.00),
                //             ),
                //             child: TextDefaultWidget(
                //               title: nextPrayer,
                //               fontFamily: "me",
                //               fontWeight: FontWeight.w600,
                //               fontSize: isTab ? 10.sp : 13.sp,
                //               color: isDark
                //                   ? AppColors.greyLightColor
                //                   : const Color(0xFF1B5E20),
                //             ),
                //           ),
                //         ],
                //       ),
                //
                //       const SizedBox(height: 10),
                //
                //       // الوقت المتبقي + شريط بسيط (ديكور)
                //       Row(
                //         children: [
                //           Container(
                //             padding: EdgeInsets.all(isTab ? 10 : 6),
                //             decoration: BoxDecoration(
                //               shape: BoxShape.circle,
                //               color: isDark
                //                   ? Colors.black.withOpacity(0.6)
                //                   : Colors.white.withOpacity(1.00),
                //             ),
                //             child: Icon(
                //               Icons.timer_outlined,
                //               size: isTab ? 22 : 18,
                //               color: isDark
                //                   ? KColors.primaryColor
                //                   : const Color(0xFF1B5E20),
                //             ),
                //           ),
                //           const SizedBox(width: 8),
                //           TextDefaultWidget(
                //             title: "الوقت المتبقي",
                //             fontFamily: "cairo",
                //             fontSize: isTab ? 8.sp : 11.sp,
                //             fontWeight: FontWeight.w600,
                //             color: isDark ? Colors.white : Colors.black,
                //           ),
                //           Spacer(),
                //           TextDefaultWidget(
                //             title: remainingTime,
                //             fontFamily: "cairo",
                //             fontWeight: FontWeight.bold,
                //             fontSize: isTab ? 10.sp : 13.sp,
                //             color: isDark ? Colors.white : Colors.black,
                //           ),
                //         ],
                //       ),
                //       const SizedBox(height: 6),
                //       // شريط ديكوري (مش progress حقيقي، بس يعطي إحساس)
                //       ClipRRect(
                //         borderRadius: BorderRadius.circular(999),
                //         child: LinearProgressIndicator(
                //           value: progressValue,
                //           // لو عندك نسبة حقيقية ممكن تمررها هنا
                //           minHeight: isTab ? 8 : 5,
                //
                //           backgroundColor:
                //               isDark ? Colors.white24 : Colors.grey.shade200,
                //           valueColor: AlwaysStoppedAnimation<Color>(
                //             isDark ? KColors.primaryColor : Color(0xFF1B5E20),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

              ),
            ),
          ),
        ],
      ),
    );
  }
}
