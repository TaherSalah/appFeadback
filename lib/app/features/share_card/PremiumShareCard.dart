import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PremiumShareCard extends StatefulWidget {
  final String text,azkarName;
  final String? source; // e.g., "سورة البقرة - آية 255" or "أذكار الصباح"

  const PremiumShareCard({
    super.key,
    required this.text,
    this.source, required this.azkarName,
  });

  @override
  State<PremiumShareCard> createState() => _PremiumShareCardState();
}

class _PremiumShareCardState extends State<PremiumShareCard> {
  final GlobalKey _globalKey = GlobalKey();
  int _selectedBgIndex = 0;
  bool _isExporting = false;

  final List<String> _backgrounds = [
    "assets/images/beautiful-view-sunset-light.jpg",
    "assets/images/inspiring-view-morning-light.jpg",
    "assets/images/natural-view-night_1112329-37092.jpg",
    "assets/images/vecteezy_islamic-arabic-green-and-white-background-with-geometric_.jpg",
    "assets/images/vecteezy_islamic-celebration-vertical-background_.jpg",
  ];

  Future<void> _shareImage() async {
    setState(() => _isExporting = true);
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/muslim_daily_share.png');
        await file.writeAsBytes(pngBytes);
        await Share.shareXFiles([XFile(file.path)],
            text: '💫 من تطبيق *رفيق المسلم اليومي* 💫  حمل التطبيق الآن واستفد من كل الذكر اليومي:');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Close button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Image Preview area
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: 400.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  image: DecorationImage(
                    image: AssetImage(_backgrounds[_selectedBgIndex]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Overlay for readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            widget.azkarName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: 22.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                              shadows: [
                                const Shadow(
                                  blurRadius: 10,
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
Container(height: 5,width: 250,decoration: BoxDecoration(color:Colors.white,borderRadius: BorderRadius.circular(15) ),),

                          SizedBox(height: 40.h),
                          // The Text
                          SelectableText(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: 15.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 2.4,
                              shadows: [
                                const Shadow(
                                  blurRadius: 10,
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),

                          ),

                          if (widget.source != null) ...[
                            SizedBox(height: 16.h),
                            Text(
                              widget.source!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 9.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          SizedBox(height: 40.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.asset(
                              "assets/images/logoApp.png",
                              height: 70.h,
                              color: Colors.white,
                              width: 70.h,
                            ),
                          ),
                          // App Branding
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Text(
                                "رفيق المسلم اليومي",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Store Icons and CTA
                          Column(
                            children: [
                              Text(
                                "شارك التطبيق لتنال الأجر",
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 15.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStoreIcon(
                                      "assets/images/playstore.png"),
                                  SizedBox(width: 12.w),
                                  _buildStoreIcon(
                                      "assets/images/app-store.png"),
                                  SizedBox(width: 12.w),
                                  _buildStoreIcon("assets/images/huawei.png"),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Background Selection List
            Container(
              height: 70.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _backgrounds.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBgIndex = index),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      width: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: _selectedBgIndex == index
                            ? Border.all(color: Colors.amber, width: 3)
                            : null,
                        image: DecorationImage(
                          image: AssetImage(_backgrounds[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24.h),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _shareImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 5,
                ),
                icon: _isExporting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.share),
                label: Text(
                  _isExporting ? "جاري الحفظ..." : "مشاركة كصورة احترافية",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreIcon(String path) {
    return Image.asset(
      path,
      height: 30.h,
      opacity: const AlwaysStoppedAnimation(0.9),
    );
  }
}
