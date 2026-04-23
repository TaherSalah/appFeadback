import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_suggest_outlined,
                size: 100,
                color: Color(0xFFD4AF37),
              ),
              SizedBox(height: 30),
              Text(
                'التطبيق في وضع الصيانة',
                style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'نحن الآن نقوم ببعض التحسينات لخدمتكم بشكل أفضل. سنعود للعمل قريباً إن شاء الله.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "cairo",
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
