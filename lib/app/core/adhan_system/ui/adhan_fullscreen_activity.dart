import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:google_fonts/google_fonts.dart';

class AdhanFullscreenActivity extends StatelessWidget {
  final String? prayerName;

  const AdhanFullscreenActivity({super.key, this.prayerName});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent dismissing easily
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mosque,
                  size: 100,
                  color: Colors.amberAccent.withOpacity(0.8),
                ),
                const SizedBox(height: 20),
                Text(
                  "حان الآن موعد صلاة",
                  style: GoogleFonts.amiri(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  prayerName ?? "الصلاة المفروضة",
                  style: GoogleFonts.amiri(
                    fontSize: 48,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    // Stop the foreground service directly, passing signal to onDestroy in the isolate
                    FlutterForegroundTask.stopService();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      "إيقاف الأذان",
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
