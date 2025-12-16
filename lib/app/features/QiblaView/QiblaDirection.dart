import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'package:muslimdaily/app/features/messa_view/azkar_massa.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;

import 'package:geocoding/geocoding.dart';

import '../../core/shard/constanc/app_style.dart';
import '../../core/widgets/kButtons.dart';
import 'ARQiblaCameraWidget.dart';


// class QiblaDirection extends StatefulWidget {
//   const QiblaDirection({super.key});
//
//   @override
//   _QiblaDirectionState createState() => _QiblaDirectionState();
// }
//
// class _QiblaDirectionState extends State<QiblaDirection> {
//   double? _heading;
//   double? _qiblaDirection;
//   String? _locationName;
//
//   StreamSubscription<CompassEvent>? _compassSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _initLocationAndCompass();
//   }
//
//   @override
//   void dispose() {
//     _compassSubscription?.cancel(); // إلغاء الاشتراك عند التخلص من الواجهة
//     super.dispose();
//   }
//
//   Future<void> _initLocationAndCompass() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Fluttertoast.showToast(
//           msg: "يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز.");
//     };
//
//     LocationPermission permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) return;
// print("permission ${permission == LocationPermission.denied}");
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     _qiblaDirection =
//         _calculateQiblaDirection(position.latitude, position.longitude);
//
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//     if (placemarks.isNotEmpty) {
//       Placemark place = placemarks.first;
//       if (mounted) {
//         setState(() {
//           print(place.country);
//           print(place.thoroughfare);
//           print(place.subThoroughfare);
//           print(place.administrativeArea);
//           print(place.locality);
//           _locationName =
//               // "${place.street ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
//               "${place.thoroughfare ?? ''} , ${place.locality ?? ''}  , ${place.administrativeArea ?? ''} , ${place.country ?? ''}"
//                   .trim()
//                   .replaceAll(RegExp(r'\s+,'), ',');
//         });
//       }
//     }
//
//     _compassSubscription = FlutterCompass.events?.listen((event) {
//       if (mounted) {
//         setState(() {
//           _heading = event.heading;
//         });
//       }
//     });
//   }
//
//   double _calculateQiblaDirection(double lat, double lon) {
//     const double kaabaLat = 21.4225;
//     const double kaabaLon = 39.8262;
//
//     final userLat = vector.radians(lat);
//     final userLon = vector.radians(lon);
//     final kLat = vector.radians(kaabaLat);
//     final kLon = vector.radians(kaabaLon);
//
//     final deltaLon = kLon - userLon;
//
//     final y = math.sin(deltaLon) * math.cos(kLat);
//     final x = math.cos(userLat) * math.sin(kLat) -
//         math.sin(userLat) * math.cos(kLat) * math.cos(deltaLon);
//     final direction = math.atan2(y, x);
//
//     return (vector.degrees(direction) + 360) % 360;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double? angle;
//     if (_heading != null && _qiblaDirection != null) {
//       angle = (_qiblaDirection! - _heading!) % 360;
//     }
// final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         // backgroundColor: AppStyle.bgColors,
//         appBar: PreferredSize(
//           preferredSize:
//               Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
//           child: AppBar(
//             leading:  CupertinoNavigationBarBackButton(color:  isDark
//                 ? Colors.white
//                 : Colors.black,),
//             centerTitle: true,
//             title: Text(
//               "اتجاه القبلة",
//               style: GoogleFonts.cairo(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                   fontSize:
//                       MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
//             ),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Center(
//                   child: angle == null
//                       ? const CircularProgressIndicator()
//                       : Transform.rotate(
//                           angle: vector.radians(angle),
//                           child: Image.asset("assets/images/qibla-compass.png",color:isDark ?Colors.white:Colors.black,),
//                         )),
//               const SizedBox(height: 20),
//               Stack(
//                 alignment: Alignment.topCenter,
//                 children: [
//
//                   SizedBox(
//                     width: MediaQuery.sizeOf(context).width,
//                     child: Card(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
//                         child: Column(
//                           children: [
//                             SizedBox(height: 35,),
//                             if (_locationName != null)
//                               Center(
//                                 child: TextWidget(
//                                   textAlign: TextAlign.center,
//                                   title: "الموقع الحالي: $_locationName",
//                                   fontSize: 15,
//                                   color:isDark? Colors.amberAccent:Colors.indigo,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),
//                               child: TextWidget(
//                                 fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
//                                 title:
//                                     "زاوية القبلة: ${_qiblaDirection?.toStringAsFixed(2) ?? "0.0"}°",
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),
//                               child: TextWidget(
//                                 fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
//                                 title:
//                                     "اتجاه الجهاز: ${_heading?.toStringAsFixed(2) ?? "0.0"}°",
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 8.0),                              child: TextWidget(
//                               fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
//                                   title:
//                                       "الفرق: ${angle?.toStringAsFixed(2) ?? "0.0"}°",
//                                   ),
//                             ),
//                             TextWidget(
//                               title:
//                               angle == null ? '' : _getDirectionMessage(angle),
//                               fontSize: ResponsiveUtil.isTablet(context)?10.sp:20,
//                               fontFamily: "maja",
//                               color:
//                               (angle != null && (angle < 10 || angle > 350))
//                                   ? Colors.green
//                                   : Colors.redAccent,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () async {
//                       await _initLocationAndCompass();
//                     },
//                     child: const Icon(Icons.refresh,size: 35,),
//                   ),
//
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // دالة تعطي رسالة حسب الزاوية
//   String _getDirectionMessage(double angle) {
//     if (angle < 10 || angle > 350) {
//       return "القبلة أمامك";
//     } else if (angle >= 10 && angle < 180) {
//       return "استدر يالهاتف يميناً";
//     } else {
//       return "استدر يالهاتف يسار";
//     }
//   }
// }
class QiblaDirection extends StatefulWidget {
  const QiblaDirection({super.key});

  @override
  _QiblaDirectionState createState() => _QiblaDirectionState();
}

class _QiblaDirectionState extends State<QiblaDirection> {
  double? _heading;
  double? _qiblaDirection;
  String? _locationName;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isARMode = false;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndCompass() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      // 1. تحقق من خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _errorMessage = "يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز.";
            _isLoading = false;
          });
        }
        Fluttertoast.showToast(msg: "يرجى تفعيل خدمة الموقع (GPS)");
        return;
      }

      // 2. طلب الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('After request permission: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage = "تم رفض إذن الموقع. يرجى السماح بالوصول إلى الموقع من إعدادات التطبيق.";
            _isLoading = false;
          });
        }
        return;
      }

      // 3. الحصول على الموقع
      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      print('Position: ${position.latitude}, ${position.longitude}');

      // 4. حساب اتجاه القبلة
      _qiblaDirection = _calculateQiblaDirection(position.latitude, position.longitude);
      print('Qibla direction: $_qiblaDirection');

      // 5. الحصول على اسم الموقع
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          if (mounted) {
            setState(() {
              _locationName =
                  "${place.thoroughfare ?? ''} , ${place.locality ?? ''}  , ${place.administrativeArea ?? ''} , ${place.country ?? ''}"
                      .trim()
                      .replaceAll(RegExp(r'\s+,'), ',');
            });
          }
        }
      } catch (e) {
        print('Error getting placemarks: $e');
      }

      // 6. تشغيل البوصلة
      _startCompass();

    } catch (e) {
      print('Error in init: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _startCompass() {
    try {
      // إلغاء الاشتراك السابق إذا كان موجوداً
      _compassSubscription?.cancel();

      // التحقق من توفر البوصلة
      if (FlutterCompass.events == null) {
        if (mounted) {
          setState(() {
            _errorMessage = "البوصلة غير متوفرة على هذا الجهاز";
            _isLoading = false;
          });
        }
        return;
      }

      // الاشتراك في أحداث البوصلة
      _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
        print('Compass event: ${event.heading}');

        if (mounted) {
          setState(() {
            _heading = event.heading;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        print('Compass error: $error');
        if (mounted) {
          setState(() {
            _errorMessage = "خطأ في البوصلة: $error";
            _isLoading = false;
          });
        }
      });

    } catch (e) {
      print('Error starting compass: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "فشل في تشغيل البوصلة";
          _isLoading = false;
        });
      }
    }
  }

  double _calculateQiblaDirection(double lat, double lon) {
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    final userLat = vector.radians(lat);
    final userLon = vector.radians(lon);
    final kLat = vector.radians(kaabaLat);
    final kLon = vector.radians(kaabaLon);

    final deltaLon = kLon - userLon;

    final y = math.sin(deltaLon) * math.cos(kLat);
    final x = math.cos(userLat) * math.sin(kLat) -
        math.sin(userLat) * math.cos(kLat) * math.cos(deltaLon);
    final direction = math.atan2(y, x);

    return (vector.degrees(direction) + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    double? angle;
    if (_heading != null && _qiblaDirection != null) {
      angle = (_qiblaDirection! - _heading!) % 360;
      print('Angle: $angle, Heading: $_heading, Qibla: $_qiblaDirection');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBar: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            "اتجاه القبلة",
            style: GoogleFonts.cairo(
              color: isDark ? Colors.greenAccent : Colors.green[700],
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
            ),
          ),
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isARMode ? Icons.compass_calibration : Icons.camera_alt),
              tooltip: _isARMode ? "الوضع الكلاسيكي" : "AR وضع",
              onPressed: () {
                setState(() {
                  _isARMode = !_isARMode;
                });
                Fluttertoast.showToast(
                  msg: _isARMode ? "AR Mode Enabled" : "Classic Mode Enabled",
                  backgroundColor: Colors.amber,
                  textColor: Colors.black
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _initLocationAndCompass,
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingWidget(isDark)
            : _errorMessage.isNotEmpty
            ? _buildErrorWidget(isDark)
            : _isARMode 
                ? ARQiblaCameraWidget(
                    qiblaDirection: _qiblaDirection ?? 0, 
                    heading: _heading ?? 0
                  )
                : _buildCompassWidget(isDark, size, angle),
      ),
    );
  }

  Widget _buildLoadingWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CircularProgressIndicator(
          //   valueColor: AlwaysStoppedAnimation<Color>(
          //     isDark ? Colors.greenAccent : Colors.green[700]!,
          //   ),
          // ),
          KLoading.progressIOSIndicator(context: context,radius: 20),
          const SizedBox(height: 20),
          Text(
            "جاري تحميل بيانات القبلة...",
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              // color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                // textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width / 2,
                child: CustomButton(
                  fontSize: 14.sp,
                  verticalPadding: 10,
                  backgroundColor: KColors.primaryColor,
                  width: MediaQuery.sizeOf(context).width / 3,
                  title: "إعادة المحاولة",
                  borderColor:KColors.primaryColor ,
                  onTap: _initLocationAndCompass,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildCompassWidget(bool isDark, Size size, double? angle) {
    final baseColor = const Color(AppStyle.primaryColor);


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // البوصلة الرئيسية
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الخلفية الدائرية
                  Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // gradient: LinearGradient(
                      //   begin: Alignment.topLeft,
                      //   end: Alignment.bottomRight,
                      //   colors: isDark
                      //       ? [Colors.grey[800]!, Colors.grey[900]!]
                      //       : [Colors.white, Colors.grey[100]!],
                      // ),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: isDark
                            ? const [
                          Color(0xFF020617),
                          Color(0xFF0F172A),
                        ]
                            : [
                          // baseColor.withOpacity(0.06), // لمسة لون خفيفة
                          Color(0xFFF7F1E1),
                          Colors.white,
                        ],
                      ),
                      // border: Border.all(
                      //   color: baseColor.withOpacity(isDark ? 0.5 : 0.3),
                      //   width: 1.2,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(isDark ? 0.4 : 0.18),
                          blurRadius: 16,
                          spreadRadius: 0.5,
                          offset: Offset(0, isDark ? 5 : 6),
                        ),
                      ],
                    ),
                  ),

                  // البوصلة
                  if (angle != null)
                    Transform.rotate(
                      angle: vector.radians(angle),
                      child: Container(
                        width: size.width * 0.6,
                        height: size.width * 0.6,
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.navigation,
                                size: 50,
                                color: isDark ? Colors.greenAccent : Colors.green[700]!,
                              ),
                            ),
                            // اتجاهات البوصلة
                            ..._buildCompassDirections(size.width * 0.7, isDark),                          ],
                        ),
                      ),
                    )
                  else
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.greenAccent : Colors.green[700]!,
                      ),
                    ),

                  // مؤشر القبلة الثابت
                  Positioned(
                    top: 12,
                    child: Text(
                      "\u{1F54B}",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // معلومات القبلة
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : Colors.grey[300]!,
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: _buildInfoContent(isDark, angle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContent(bool isDark, double? angle) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        // معلومات الموقع
        if (_locationName != null)
          _buildInfoRow(
            Icons.location_on,
            "الموقع",
            _locationName!,
            isDark,
          ),

        const SizedBox(height: 15),

        // معلومات الزوايا
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAngleInfo(
              "زاوية القبلة",
              "${_qiblaDirection?.toStringAsFixed(2) ?? "0.00"}°",
              isDark,
            ),
            _buildAngleInfo(
              "اتجاه الجهاز",
              "${_heading?.toStringAsFixed(2) ?? "0.00"}°",
              isDark,
            ),
            _buildAngleInfo(
              "الفرق",
              "${angle?.toStringAsFixed(2) ?? "0.00"}°",
              isDark,
            ),
          ],
        ),

        const SizedBox(height: 15),

        // رسالة التوجيه
        if (angle != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: (angle < 10 || angle > 350)
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: (angle < 10 || angle > 350)
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  (angle < 10 || angle > 350)
                      ? Icons.check_circle
                      : Icons.navigation,
                  color: (angle < 10 || angle > 350)
                      ? Colors.green
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getDirectionMessage(angle),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (angle < 10 || angle > 350)
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildCompassDirections(double containerSize, bool isDark) {
    double textSize = containerSize * 0.05; // 5% من حجم الحاوية
    textSize = textSize.clamp(12, 18); // بين 12 و 18

    return [
      // الشمال
      Positioned(
        top: 8,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            "شمال",
            style: TextStyle(
              // color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: textSize,
            ),
          ),
        ),
      ),

      // الجنوب
      Positioned(
        bottom: 8,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            "جنوب",
            style: TextStyle(
              // color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: textSize,
            ),
          ),
        ),
      ),

      // الشرق
      Positioned(
        left: 8,
        top: 0,
        bottom: 0,
        child: Align(
          alignment: Alignment.centerLeft,
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              "شرق",
              style: TextStyle(
                // color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: textSize,
              ),
            ),
          ),
        ),
      ),

      // الغرب
      Positioned(
        right: 8,
        top: 0,
        bottom: 0,
        child: Align(
          alignment: Alignment.centerRight,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              "غرب",
              style: TextStyle(
                // color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: textSize,
              ),
            ),
          ),
        ),
      ),
    ];
  }
  Widget _buildInfoRow(IconData icon, String title, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.greenAccent : Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAngleInfo(String title, String value, bool isDark) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.cairo(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.greenAccent : Colors.green[700])),
        ),
      ],
    );
  }

  String _getDirectionMessage(double angle) {
    if (angle < 10 || angle > 350) {
      return "القبلة أمامك مباشرة";
    } else if (angle >= 10 && angle < 180) {
      return "استدر بالهاتف يميناً";
    } else {
      return "استدر بالهاتف يساراً";
    }
  }
}