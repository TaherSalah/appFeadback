import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:muslimdaily/app/core/services/AdhanDiagnosticHelper.dart';
import 'package:muslimdaily/app/features/azanView/view/AdhanDiagnosticScreen.dart';

class AdhanStatusBanner extends StatefulWidget {
  const AdhanStatusBanner({super.key});

  @override
  State<AdhanStatusBanner> createState() => _AdhanStatusBannerState();
}

class _AdhanStatusBannerState extends State<AdhanStatusBanner> {
  bool _isUnhealthy = false;
  bool _isLoading = true;
  String _brand = 'unknown';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final unhealthy = await AdhanDiagnosticHelper.isAdhanUnhealthy();
    final brand = await AdhanDiagnosticHelper.getDeviceBrand();
    if (mounted) {
      setState(() {
        _isUnhealthy = unhealthy;
        _brand = brand;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isUnhealthy) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تخصيص الرسالة بناءً على نوع الجهاز
    String message = "تنبيه: الأذان قد لا يعمل بكفاءة بسبب إعدادات الهاتف.";
    if (_brand.contains('realme') || _brand.contains('oppo')) {
      message =
          "تنبيه لمستخدمي Realme/Oppo: يلزم ضبط إعدادات البطارية لضمان عمل الأذان.";
    } else if (_brand.contains('xiaomi')) {
      message =
          "تنبيه لمستخدمي Xiaomi: يرجى تفعيل التشغيل التلقائي لضمان عمل الأذان.";
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)] // Dark Red
                : [
                    const Color(0xFFFEE2E2),
                    const Color(0xFFFECACA)
                  ], // Light Red
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark
                ? Colors.redAccent.withOpacity(0.3)
                : Colors.red.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdhanDiagnosticScreen()),
              );
              // إعادة الفحص عند العودة من شاشة التشخيص
              _checkStatus();
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: isDark ? Colors.redAccent : Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "مشكلة في تنبيهات الأذان",
                          style: TextStyle(
                  fontFamily: "cairo",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.red.shade900,
                          ),
                        ),
                        Text(
                          message,
                          style: TextStyle(
                  fontFamily: "cairo",
                            fontSize: 12,
                            color:
                                isDark ? Colors.white70 : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.red.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
