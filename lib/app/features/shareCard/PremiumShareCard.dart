import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:muslimdaily/app/core/services/image_share_service.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PremiumShareCard extends StatefulWidget {
  final String text, azkarName;
  final String? source;

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
  late List<ShareImageItem> _backgrounds;
  final Set<int> _loadedIndices = {};
  final Set<int> _failedIndices = {};

  // Personalization States
  String _selectedFont = "Amiri";
  double _bgDimming = 0.4;
  Color _titleColor = const Color(0xFFFFD700); // Default Gold

  final List<String> _fonts = ["Amiri", "Cairo", "Changa", "Lateef", "Tajawal"];
  final List<Color> _palette = [
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFFFFFF), // White
    const Color(0xFFA7FFEB), // Teal Light
    const Color(0xFFF48FB1), // Pink Light
    const Color(0xFF90CAF9), // Blue Light
    const Color(0xFFA5D6A7), // Green Light
  ];

  @override
  void initState() {
    super.initState();
    _backgrounds = ImageShareService.getAllBackgrounds();
    // Local images are always considered loaded
    for (int i = 0; i < _backgrounds.length; i++) {
      if (!_backgrounds[i].isRemote) {
        _loadedIndices.add(i);
      }
    }
  }

  Future<void> _shareImage() async {
    if (!_loadedIndices.contains(_selectedBgIndex)) return;
    
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

  bool _isImageLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isRemote = _backgrounds[_selectedBgIndex].isRemote;
    
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
            child: Directionality(
              textDirection: TextDirection.rtl,
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
                          // 1. Fallback / Base Layer
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28.r),
                              child: Image.asset(
                                ImageShareService.localBackgrounds[0],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
              
                          // 2. Remote Image Layer (with loading handling)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28.r),
                              child: isRemote 
                                ? CachedNetworkImage(
                                    imageUrl: _backgrounds[_selectedBgIndex].path,
                                    cacheManager: ImageShareService.customCacheManager,
                                    fit: BoxFit.cover,
                                    imageBuilder: (context, imageProvider) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (mounted && !_loadedIndices.contains(_selectedBgIndex)) {
                                          setState(() => _loadedIndices.add(_selectedBgIndex));
                                        }
                                      });
                                      return Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return Container(color: Colors.black26);
                                    },
                                    errorWidget: (context, url, error) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        if (mounted && !_failedIndices.contains(_selectedBgIndex)) {
                                          setState(() => _failedIndices.add(_selectedBgIndex));
                                        }
                                      });
                                      return Container(
                                        color: Colors.black45,
                                        child: const Center(
                                          child: Icon(Icons.cloud_off, color: Colors.white54, size: 40),
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    _backgrounds[_selectedBgIndex].path,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
              
                          // 3. Premium Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28.r),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(_bgDimming),
                                    Colors.black.withOpacity(_bgDimming + 0.3 > 1.0 ? 1.0 : _bgDimming + 0.3),
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
                                        LinearGradient(
                                      colors: [
                                        _titleColor,
                                        _titleColor.withOpacity(0.7),
                                        _titleColor.withOpacity(0.9),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      widget.azkarName,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        _selectedFont,
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
                                        style: GoogleFonts.getFont(
                                          _selectedFont,
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
              
                                SizedBox(height: 14.h),
                                Image.asset(
                                  "assets/images/logoApp.png",
                                  height: 55.h,
                                  width: 55.h,
                                  color: Colors.white,
                                ),
                                Text(
                                  "رفيق المسلم اليومي",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // App Branding Section
                                SizedBox(height: 20.h),
              
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                      // Internet Requirement Hint
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_download_outlined, color: Colors.amber.withOpacity(0.7), size: 14.sp),
                            SizedBox(width: 6.w),
                            Text(
                              "خلفيات إضافية (تحتاج اتصال بالإنترنت) ✨",
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Background Selector
                      SizedBox(
                        height: 60.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _backgrounds.length,
                          itemBuilder: (context, index) {
                            bool isCurrentRemote = _backgrounds[index].isRemote;
                            bool isFailed = _failedIndices.contains(index);
                            return GestureDetector(
                              onTap: () {
                                if (isFailed) {
                                  // Manual Retry: Clear from failed and select to trigger re-fetch
                                  setState(() {
                                    _failedIndices.remove(index);
                                    _selectedBgIndex = index;
                                  });
                                } else {
                                  setState(() => _selectedBgIndex = index);
                                }
                              },
                              child: Opacity(
                                opacity: isFailed ? 0.3 : 1.0,
                                child: SizedBox(
                                  width: 60.w,
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14.r),
                                          border: _selectedBgIndex == index
                                              ? Border.all(
                                                  color: Colors.amber, width: 2.5)
                                              : Border.all(
                                                  color: Colors.white24, width: 1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.r),
                                          child: isCurrentRemote 
                                            ? CachedNetworkImage(
                                                imageUrl: _backgrounds[index].path,
                                                cacheManager: ImageShareService.customCacheManager,
                                                fit: BoxFit.cover,
                                                imageBuilder: (context, imageProvider) {
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted && !_loadedIndices.contains(index)) {
                                                      setState(() => _loadedIndices.add(index));
                                                    }
                                                  });
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                    ),
                                                  );
                                                },
                                                placeholder: (context, url) => Shimmer.fromColors(
                                                  baseColor: Colors.grey[800]!,
                                                  highlightColor: Colors.grey[700]!,
                                                  child: Container(color: Colors.white),
                                                ),
                                                errorWidget: (context, url, error) {
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted && !_failedIndices.contains(index)) {
                                                      setState(() => _failedIndices.add(index));
                                                    }
                                                  });
                                                  return Container(
                                                    color: Colors.black45,
                                                    child: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                _backgrounds[index].path,
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                      ),
                                      // Offline Ready Indicator
                                      if (_loadedIndices.contains(index))
                                        Positioned(
                                          top: 4.w,
                                          right: 4.w,
                                          child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 14.sp),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: 12.h),

                      // Personalization Tools
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Font Selector
                            ..._fonts.map((f) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: ChoiceChip(
                                label: Text(f, style: GoogleFonts.getFont(f, color: Colors.white, fontSize: 12.sp)),
                                selected: _selectedFont == f,
                                onSelected: (val) => setState(() => _selectedFont = f),
                                backgroundColor: Colors.white10,
                                selectedColor: Colors.amber.shade800,
                              ),
                            )),
                            
                            SizedBox(width: 10.w),
                            // Color Picker for Title
                            ..._palette.map((c) => GestureDetector(
                              onTap: () => setState(() => _titleColor = c),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: _titleColor == c ? Border.all(color: Colors.white, width: 2) : null,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),

                      // Opacity Slider
                      Row(
                        children: [
                          Icon(Icons.opacity, color: Colors.white70, size: 16.sp),
                          Expanded(
                            child: Slider(
                              value: _bgDimming,
                              onChanged: (val) => setState(() => _bgDimming = val),
                              min: 0.0,
                              max: 0.8,
                              activeColor: Colors.amber,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                        ],
                      ),

                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_isExporting || !_loadedIndices.contains(_selectedBgIndex)) ? null : _shareImage,
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: Colors.amber.shade700,
                            backgroundColor: KColors.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[800],
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 8,
                            shadowColor: Colors.amber.withOpacity(0.5),
                          ),
                          icon: _isExporting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : (!_loadedIndices.contains(_selectedBgIndex) 
                                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                                 : const Icon(Icons.share)),
                          label: Text(
                            _isExporting 
                                ? "جاري الحفظ..." 
                                : (!_loadedIndices.contains(_selectedBgIndex) ? "جاري التحميل..." : "مشاركة كصورة"),
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
