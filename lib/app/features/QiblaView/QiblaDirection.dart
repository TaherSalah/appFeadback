import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart'; // Added for openAppSettings
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/services/location_service.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:vector_math/vector_math.dart' as vector;

import '../../core/shard/constanc/app_style.dart';
import '../../core/widgets/kButtons.dart';
import 'ARQiblaCameraWidget.dart';

class QiblaDirection extends StatefulWidget {
  final bool isActive;
  const QiblaDirection({super.key, this.isActive = true});

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
    if (widget.isActive) {
      _initLocationAndCompass();
    }
  }

  @override
  void didUpdateWidget(QiblaDirection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _initLocationAndCompass();
      } else {
        _stopCompass();
      }
    }
  }

  void _stopCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
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
      final locationService = LocationService();
      final pos = await locationService.getCurrentPosition();

      if (pos == null) {
        if (mounted) {
          setState(() {
            _errorMessage =
                "تعذر الحصول على الموقع. يرجى تفعيل خدمة الموقع والسماح بالصلاحيات.";
            _isLoading = false;
          });
        }
        return;
      }

      // print('Position: ${pos.latitude}, ${pos.longitude}');

      // 4. حساب اتجاه القبلة
      _qiblaDirection = _calculateQiblaDirection(pos.latitude, pos.longitude);
      // print('Qibla direction: $_qiblaDirection');

      // 6. تشغيل البوصلة فوراً (هام جداً للعمل بدون نت)
      _startCompass();

      // 5. الحصول على اسم الموقع (بشكل منفصل لعدم تعطيل البوصلة)
      _fetchAddress(pos.latitude, pos.longitude);
    } catch (e) {
      debugPrint('Error in init: $e');
      if (mounted) {
        setState(() {
          _errorMessage = "حدث خطأ: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    try {
      final locationService = LocationService();
      final address = await locationService.getAddressFromLatLng(lat, lng);

      if (address != null && mounted) {
        setState(() {
          _locationName = "${address['city']}, ${address['country']}";
        });
      }
    } catch (e) {
      debugPrint("Address fetch skipped (likely offline): $e");
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
      _compassSubscription =
          FlutterCompass.events!.listen((CompassEvent event) {
        // print('Compass event: ${event.heading}');

        if (mounted) {
          setState(() {
            double? heading = event.heading;
            if (heading != null) {
              heading = (heading < 0) ? (360 + heading) : heading;
            }
            _heading = heading;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        debugPrint('Compass error: $error');
        if (mounted) {
          setState(() {
            _errorMessage = "خطأ في البوصلة: $error";
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('Error starting compass: $e');
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
    final isDark = context.isDark;
    final size = MediaQuery.of(context).size;

    double? angle;
    if (_heading != null && _qiblaDirection != null) {
      angle = (_qiblaDirection! - _heading!) % 360;
      // print('Angle: $angle, Heading: $_heading, Qibla: $_qiblaDirection');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        // appBar: AppBar(
        //   leading: (ModalRoute.of(context)?.canPop ?? false)
        //       ? IconButton(
        //           icon: Icon(
        //             CupertinoIcons.back,
        //             color: isDark ? Colors.white : Colors.black,
        //           ),
        //           onPressed: () => Navigator.of(context).pop(),
        //         )
        //       : null,
        //   centerTitle: true,
        //   title: Text(
        //     "اتجاه القبلة",
        //     style: GoogleFonts.cairo(
        //       color: isDark ? Colors.greenAccent : Colors.green[700],
        //       fontWeight: FontWeight.bold,
        //       fontSize: isTablet ? 20 : 18,
        //     ),
        //   ),
        //   backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: Icon(
        //           _isARMode ? Icons.compass_calibration : Icons.camera_alt),
        //       tooltip: _isARMode ? "الوضع الكلاسيكي" : "AR وضع",
        //       onPressed: () {
        //         setState(() {
        //           _isARMode = !_isARMode;
        //         });
        //         // Fluttertoast.showToast(
        //         //     msg: _isARMode ? "AR Mode Enabled" : "Classic Mode Enabled",
        //         //     backgroundColor: Colors.amber,
        //         //     textColor: Colors.black);
        //         KHelper.showSuccess(
        //             message:
        //                 _isARMode ? "AR Mode Enabled" : "Classic Mode Enabled");
        //       },
        //     ),
        //     IconButton(
        //       icon: const Icon(Icons.refresh),
        //       onPressed: _initLocationAndCompass,
        //     ),
        //   ],
        // ),
        appBar: PreferredSize(
          preferredSize:
          Size.fromHeight(context.isTab? 80 : 50),
          child: AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                      _isARMode ? Icons.compass_calibration : Icons.camera_alt),
                  tooltip: _isARMode ? "الوضع الكلاسيكي" : "AR وضع",
                  onPressed: () {
                    setState(() {
                      _isARMode = !_isARMode;
                    });
                    // Fluttertoast.showToast(
                    //     msg: _isARMode ? "AR Mode Enabled" : "Classic Mode Enabled",
                    //     backgroundColor: Colors.amber,
                    //     textColor: Colors.black);
                    KHelper.showSuccess(
                        message:
                            _isARMode ? "AR Mode Enabled" : "Classic Mode Enabled");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _initLocationAndCompass,
                ),
              ],
            iconTheme:
            IconThemeData(color: isDark ? Colors.white : Colors.blue),
            centerTitle: true,
            title: Text(
              "اتجاه القبلة",
                 style: TextStyle(
                          fontFamily: "cairo",
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                  context.isTab?12.sp : 18.sp),
            ),
          ),
        ),

        body: _isLoading
            ? _buildLoadingWidget(isDark)
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget(isDark)
                : _isARMode
                    ? ARQiblaCameraWidget(
                        qiblaDirection: _qiblaDirection ?? 0,
                        heading: _heading ?? 0,
                        isActive: widget.isActive)
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
          KLoading.progressIOSIndicator(context: context, radius: 20),
          const SizedBox(height: 20),
          Text(
            "جاري تحميل بيانات القبلة...",
               style: TextStyle(
                          fontFamily: "cairo",
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
            const Icon(
              Icons.error_outline,
              // color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              _getErrorMessage(_errorMessage),
              textAlign: TextAlign.center,
                 style: TextStyle(
                          fontFamily: "cairo",
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
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
                  title: _getErrorButtonTitle(_errorMessage),
                  borderColor: KColors.primaryColor,
                  onTap: () async {
                    if (_errorMessage == "SERVICE_DISABLED") {
                      await Geolocator.openLocationSettings();
                    } else if (_errorMessage == "PERMISSION_DENIED_FOREVER") {
                      await Geolocator.openAppSettings();
                    }
                    _initLocationAndCompass();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassWidget(bool isDark, Size size, double? angle) {
    const baseColor = Color(AppStyle.primaryColor);

    // Increase bottom padding if we are in the main tab view (cannot pop)
    // to avoid overlap with the BottomNavigationBar and FAB.
    final double bottomPadding =
        (ModalRoute.of(context)?.canPop ?? false) ? 16.0 : 90.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, bottomPadding),
      child: Column(
        children: [
          // البوصلة الرئيسية
          Expanded(
            flex: 1,
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
                                const Color(0xFFF7F1E1),
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
                  // البوصلة
                  if (_heading != null && _qiblaDirection != null) ...[
                    // 1. Compass Rose (N, S, E, W) - Rotates independently to show True North
                    // Rotates by -heading so that "North" stays pointing North relative to the world
                    Transform.rotate(
                      angle: vector.radians(-_heading!),
                      child: SizedBox(
                        width: size.width * 0.6,
                        height: size.width * 0.6,
                        child: Stack(
                          children:
                              _buildCompassDirections(size.width * 0.7, isDark),
                        ),
                      ),
                    ),

                    // 2. Qibla Pointer (Arrow) - Points to Qibla
                    // Rotates by (Qibla - Heading) to point towards Qibla relative to phone
                    Transform.rotate(
                      angle:
                          vector.radians((_qiblaDirection! - _heading!) % 360),
                      child: SizedBox(
                        width: size.width * 0.6,
                        height: size.width * 0.6,
                        child: Center(
                          child: Icon(
                            Icons.navigation,
                            size: 50,
                            color: isDark
                                ? Colors.greenAccent
                                : Colors.green[700]!,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.greenAccent : Colors.green[700]!,
                      ),
                    ),

                  // مؤشر القبلة الثابت
                  const Positioned(
                    top: 12,
                    child: Text(
                      "\u{1F54B}",
                         style: TextStyle(
                          fontFamily: "cairo",
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
            flex: 1,
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
              child: SingleChildScrollView(

                child: _buildInfoContent(isDark, angle),
              ),
            ),
          ),
          const SizedBox(height: 15,),
        ],
      ),
    );
  }

  Widget _buildInfoContent(bool isDark, double? angle) {
    return Column(
      spacing: 6,
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

        const SizedBox(height: 20),

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
                color:
                    (angle < 10 || angle > 350) ? Colors.green : Colors.orange,
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
                     style: TextStyle(
                          fontFamily: "cairo",
                    fontSize: context.isTab ? 16 : 14,
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
          Icon(icon,
              color: isDark ? Colors.greenAccent : Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                       style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600])),
                Text(value,
                       style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    overflow: TextOverflow.ellipsis),
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
        Text(title,
               style: TextStyle(
                          fontFamily: "cairo",
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value,
                 style: TextStyle(
                          fontFamily: "cairo",
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.greenAccent : Colors.green[700])),
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

  String _getErrorMessage(String code) {
    switch (code) {
      case "SERVICE_DISABLED":
        return "خدمة الموقع (GPS) غير مفعلة.\nيرجى تفعيلها للمتابعة.";
      case "PERMISSION_DENIED":
        return "تم رفض صلاحية الموقع.\nيرجى السماح بالصلاحية لعمل البوصلة.\nاضغط إعادة المحاولة.";
      case "PERMISSION_DENIED_FOREVER":
        return "صلاحية الموقع مرفوضة نهائياً.\nيرجى فتح الإعدادات وتفعيلها يدوياً.";
      default:
        return code;
    }
  }

  String _getErrorButtonTitle(String code) {
    if (code == "SERVICE_DISABLED") return "فتح إعدادات الموقع";
    if (code == "PERMISSION_DENIED_FOREVER") return "فتح الإعدادات";
    return "إعادة المحاولة";
  }
}
