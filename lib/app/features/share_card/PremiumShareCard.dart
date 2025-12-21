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
  final String text, azkarName;
  final String? source; // e.g., "سورة البقرة - آية 255" or "أذكار الصباح"

  const PremiumShareCard({
    super.key,
    required this.text,
    this.source,
    required this.azkarName,
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
            text:
                '💫 من تطبيق *رفيق المسلم اليومي* 💫  حمل التطبيق الآن واستفد من كل الذكر اليومي:');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Font Scaling Logic
    double dynamicFontSize = 24.sp;
    if (widget.text.length > 500) {
      dynamicFontSize = 14.sp;
    } else if (widget.text.length > 300) {
      dynamicFontSize = 16.sp;
    } else if (widget.text.length > 150) {
      dynamicFontSize = 18.sp;
    } else if (widget.text.length < 50) {
      dynamicFontSize = 26.sp;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16.w),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Image Preview area
                RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 450.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      image: DecorationImage(
                        image: AssetImage(_backgrounds[_selectedBgIndex]),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Premium Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28.r),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 22.w, vertical: 35.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category Name with Gradient Shader
                              if (widget.azkarName.isNotEmpty) ...[
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFF7AD),
                                      Color(0xFFB8860B)
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    widget.azkarName,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      fontSize: 22.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                // Elegant Divider
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSmallDivider(isLeft: true),
                                    Container(
                                      padding: EdgeInsets.all(5.r),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                Colors.amber.withOpacity(0.5),
                                            width: 1.5),
                                      ),
                                      child: Container(
                                        width: 5.r,
                                        height: 5.r,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    _buildSmallDivider(isLeft: false),
                                  ],
                                ),
                                SizedBox(height: 35.h),
                              ],

                              // Main Text Box with Glass effect
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18.w, vertical: 24.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1),
                                ),
                                child: Column(
                                  children: [
                                    SelectableText(
                                      widget.text,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiri(
                                        fontSize: dynamicFontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        height: 1.7,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 12,
                                            color: Colors.black54,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (widget.source != null &&
                                        widget.source!.isNotEmpty) ...[
                                      SizedBox(height: 25.h),
                                      Text(
                                        widget.source!,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12.sp,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              SizedBox(height: 45.h),

                              // App Branding Section
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1),
                                ),
                                child: Row(
                                  children: [
                                    // QR Code Placeholder Area
                                    Container(
                                      padding: EdgeInsets.all(6.r),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.qr_code_2_rounded,
                                        size: 45.r,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    // Logo and Name
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                "assets/images/logoApp.png",
                                                height: 35.h,
                                                width: 35.h,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "رفيق المسلم اليومي",
                                                style: GoogleFonts.cairo(
                                                  color: Colors.white,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              _buildStoreIcon(
                                                  "assets/images/playstore.png"),
                                              SizedBox(width: 8.w),
                                              _buildStoreIcon(
                                                  "assets/images/app-store.png"),
                                              SizedBox(width: 8.w),
                                              _buildStoreIcon(
                                                  "assets/images/huawei.png"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "شارك التطبيق لتنال الأجر",
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 130.h), // Spacer for the floating controls
              ],
            ),
          ),

          // Floating Controls (Backdrop Blur Effect)
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.r),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Background Selector
                      SizedBox(
                        height: 60.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _backgrounds.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedBgIndex = index),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.w),
                                width: 60.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: _selectedBgIndex == index
                                      ? Border.all(
                                          color: Colors.amber, width: 2.5)
                                      : Border.all(
                                          color: Colors.white24, width: 1),
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
                      SizedBox(height: 16.h),
                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _shareImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 8,
                            shadowColor: Colors.amber.withOpacity(0.5),
                          ),
                          icon: _isExporting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.share),
                          label: Text(
                            _isExporting ? "جاري الحفظ..." : "مشاركة كصورة",
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDivider({required bool isLeft}) {
    return Container(
      height: 1.5,
      width: 50.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? [Colors.transparent, Colors.amber.withOpacity(0.8)]
              : [Colors.amber.withOpacity(0.8), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildStoreIcon(String path) {
    return Image.asset(
      path,
      height: 28.h,
      opacity: const AlwaysStoppedAnimation(0.95),
    );
  }
}
