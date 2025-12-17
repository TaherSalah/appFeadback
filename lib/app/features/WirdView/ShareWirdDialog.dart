import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareWirdDialog extends StatefulWidget {
  final String dhikrText;
  final bool isDark;

  const ShareWirdDialog({
    super.key,
    required this.dhikrText,
    required this.isDark,
  });

  @override
  State<ShareWirdDialog> createState() => _ShareWirdDialogState();
}

class _ShareWirdDialogState extends State<ShareWirdDialog> {
  final GlobalKey _globalKey = GlobalKey();

  // قائمة الخلفيات المقترحة من مجلد الأصول
  final List<String> _backgrounds = [
    "assets/images/beautiful-view-sunset-light.jpg",
    "assets/images/inspiring-view-morning-light.jpg",
    "assets/images/natural-view-night_1112329-37092.jpg",
    "assets/images/1.jpg",
    "assets/images/2.jpg",
    "assets/images/3.jpg",
    "assets/images/4.jpg",
    "assets/images/5.jpg",
    "assets/images/6.jpg",
  ];

  int _selectedImageIndex = 0;
  bool _isSharing = false;

  Future<void> _captureAndShare() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // 1. التقاط الصورة من الـ Widget
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // زيادة pixelRatio لجودة أعلى
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // 2. حفظ الصورة في ملف مؤقت
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/dhikr_share.png');
        await file.writeAsBytes(pngBytes);

        // 3. مشاركة الملف
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'شارك الذكر مع من تحب',
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء المشاركة')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر الإغلاق
          Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // منطقة المعاينة (التي سيتم التقاطها كصورة)
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              width: double.infinity,
              // نسبة أبعاد مربعة أو مستطيلة مناسبة للمشاركة (إنستجرام/واتساب)
              // aspectRatio: 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(_backgrounds[_selectedImageIndex]),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // طبقة تعتيم خفيفة لتحسين قراءة النص
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  // المحتوى
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        // نص الذكر
                        Text(
                          widget.dhikrText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // اللوجو واسم التطبيق
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/logoApp.png",
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "رفيق المسلم",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // قائمة اختيار الخلفيات
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _backgrounds.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedImageIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.teal, width: 3)
                          : null,
                      image: DecorationImage(
                        image: AssetImage(_backgrounds[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: isSelected
                        ? Container(color: Colors.teal.withOpacity(0.3))
                        : null,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // زر المشاركة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSharing ? null : _captureAndShare,
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.share, color: Colors.white),
              label: Text(
                _isSharing ? "جاري التجهيز..." : "مشاركة الصورة",
                style: const TextStyle(
                    fontFamily: "cairo",
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
