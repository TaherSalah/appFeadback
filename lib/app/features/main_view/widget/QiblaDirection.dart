import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;

import 'package:geocoding/geocoding.dart';

import '../../../core/shard/constanc/app_style.dart';


class QiblaDirection extends StatefulWidget {
  const QiblaDirection({super.key});

  @override
  _QiblaDirectionState createState() => _QiblaDirectionState();
}

class _QiblaDirectionState extends State<QiblaDirection> {
  double? _heading;
  double? _qiblaDirection;
  String? _locationName;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initLocationAndCompass();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel(); // إلغاء الاشتراك عند التخلص من الواجهة
    super.dispose();
  }

  Future<void> _initLocationAndCompass() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "يرجى تفعيل خدمة الموقع (GPS) من إعدادات الجهاز.");
    };

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
print("permission ${permission == LocationPermission.denied}");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _qiblaDirection =
        _calculateQiblaDirection(position.latitude, position.longitude);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      if (mounted) {
        setState(() {
          print(place.country);
          print(place.thoroughfare);
          print(place.subThoroughfare);
          print(place.administrativeArea);
          print(place.locality);
          _locationName =
              // "${place.street ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}"
              "${place.thoroughfare ?? ''} , ${place.locality ?? ''}  , ${place.administrativeArea ?? ''} , ${place.country ?? ''}"
                  .trim()
                  .replaceAll(RegExp(r'\s+,'), ',');
        });
      }
    }

    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
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
    double? angle;
    if (_heading != null && _qiblaDirection != null) {
      angle = (_qiblaDirection! - _heading!) % 360;
    }
final isDark = Theme.of(context).brightness == Brightness.dark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor: AppStyle.bgColors,
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading:  CupertinoNavigationBarBackButton(color:  isDark
                ? Colors.white
                : Colors.black,),
            centerTitle: true,
            title: Text(
              "اتجاه القبلة",
              style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: angle == null
                      ? const CircularProgressIndicator()
                      : Transform.rotate(
                          angle: vector.radians(angle),
                          child: Image.asset("assets/images/qibla-compass.png",color:isDark ?Colors.white:Colors.black,),
                        )),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.topCenter,
                children: [

                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
                        child: Column(
                          children: [
                            SizedBox(height: 35,),
                            if (_locationName != null)
                              Center(
                                child: TextWidget(
                                  textAlign: TextAlign.center,
                                  title: "الموقع الحالي: $_locationName",
                                  fontSize: 15,
                                  color:isDark? Colors.amberAccent:Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextWidget(
                                fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
                                title:
                                    "زاوية القبلة: ${_qiblaDirection?.toStringAsFixed(2) ?? "0.0"}°",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextWidget(
                                fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
                                title:
                                    "اتجاه الجهاز: ${_heading?.toStringAsFixed(2) ?? "0.0"}°",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),                              child: TextWidget(
                              fontSize: ResponsiveUtil.isTablet(context)?9.sp:13.sp,
                                  title:
                                      "الفرق: ${angle?.toStringAsFixed(2) ?? "0.0"}°",
                                  ),
                            ),
                            TextWidget(
                              title:
                              angle == null ? '' : _getDirectionMessage(angle),
                              fontSize: ResponsiveUtil.isTablet(context)?10.sp:20,
                              fontFamily: "maja",
                              color:
                              (angle != null && (angle < 10 || angle > 350))
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await _initLocationAndCompass();
                    },
                    child: const Icon(Icons.refresh,size: 35,),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة تعطي رسالة حسب الزاوية
  String _getDirectionMessage(double angle) {
    if (angle < 10 || angle > 350) {
      return "القبلة أمامك";
    } else if (angle >= 10 && angle < 180) {
      return "استدر يالهاتف يميناً";
    } else {
      return "استدر يالهاتف يسار";
    }
  }
}
