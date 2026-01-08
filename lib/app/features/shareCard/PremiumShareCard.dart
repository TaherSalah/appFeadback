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

enum ShareRatio { flexible, square, story, portrait }

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

  // Display & Ratio States
  ShareRatio _selectedRatio = ShareRatio.flexible;

  // Personalization States
  String _selectedFont = "Amiri";
  double _bgDimming = 0.4;
  Color _titleColor = const Color(0xFFFFD700); // Default Gold
  Color _textColor = const Color(0xFFFFFFFF); // Default White for main text
  Color _sourceColor = const Color(0xFFD4AF37); // Default Gold for source

  final List<String> _fonts = ["Amiri", "Cairo", "Changa", "Lateef", "Tajawal"];
  final List<Color> _titlePalette = [
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFFFFFF), // White
    const Color(0xFFA7FFEB), // Teal Light
    const Color(0xFFF48FB1), // Pink Light
    const Color(0xFF90CAF9), // Blue Light
    const Color(0xFFA5D6A7), // Green Light
  ];

  final List<Color> _textPalette = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFFFFF8DC), // Cornsilk
    const Color(0xFFE8F5E9), // Light Green
    const Color(0xFFFCE4EC), // Light Pink
    const Color(0xFFE3F2FD), // Light Blue
    const Color(0xFFFFF3E0), // Light Orange
  ];

  final List<Color> _sourcePalette = [
    const Color(0xFFD4AF37), // Gold
    const Color(0xFFFFFFFF), // White
    const Color(0xFF90CAF9), // Blue Light
    const Color(0xFFA5D6A7), // Green Light
    const Color(0xFFF48FB1), // Pink Light
    const Color(0xFFFFCC80), // Orange Light
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
      insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
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
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Image Preview area
                  RepaintBoundary(
                    key: _globalKey,
                    child: _buildRatioWrapper(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: _selectedRatio == ShareRatio.flexible
                              ? BorderRadius.circular(28.r)
                              : BorderRadius
                                  .zero, // Capture sharp edges for fixed ratios
                          boxShadow: [
                            if (_selectedRatio == ShareRatio.flexible)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 15),
                              ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.antiAlias,
                          children: [
                            // 1. Fallback / Base Layer
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius:
                                    _selectedRatio == ShareRatio.flexible
                                        ? BorderRadius.circular(28.r)
                                        : BorderRadius.zero,
                                child: Image.asset(
                                  ImageShareService.localBackgrounds[0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // 2. Remote Image Layer (with loading handling)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius:
                                    _selectedRatio == ShareRatio.flexible
                                        ? BorderRadius.circular(28.r)
                                        : BorderRadius.zero,
                                child: isRemote
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            _backgrounds[_selectedBgIndex].path,
                                        cacheManager: ImageShareService
                                            .customCacheManager,
                                        fit: BoxFit.cover,
                                        imageBuilder: (context, imageProvider) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (mounted &&
                                                !_loadedIndices.contains(
                                                    _selectedBgIndex)) {
                                              setState(() => _loadedIndices
                                                  .add(_selectedBgIndex));
                                            }
                                          });
                                          return Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          );
                                        },
                                        placeholder: (context, url) =>
                                            Container(color: Colors.black26),
                                        errorWidget: (context, url, error) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (mounted &&
                                                !_failedIndices.contains(
                                                    _selectedBgIndex)) {
                                              setState(() => _failedIndices
                                                  .add(_selectedBgIndex));
                                            }
                                          });
                                          return Container(
                                            color: Colors.black45,
                                            child: const Center(
                                              child: Icon(Icons.cloud_off,
                                                  color: Colors.white54,
                                                  size: 40),
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
                                  borderRadius:
                                      _selectedRatio == ShareRatio.flexible
                                          ? BorderRadius.circular(28.r)
                                          : BorderRadius.zero,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(_bgDimming),
                                      Colors.black.withOpacity(
                                          _bgDimming + 0.3 > 1.0
                                              ? 1.0
                                              : _bgDimming + 0.3),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Content
                            _buildContentWrapper(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 22.w, vertical: 30.h),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Category Name
                                    if (widget.azkarName.isNotEmpty) ...[
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            _titleColor,
                                            _titleColor.withOpacity(0.8)
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          widget.azkarName,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.getFont(
                                            _selectedFont,
                                            fontSize: 20.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      _buildElegantDivider(),
                                      SizedBox(height: 25.h),
                                    ],

                                    // Main Text Box
                                    _buildTextExpander(
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 15.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.12)),
                                        ),
                                        child: SingleChildScrollView(
                                          physics: _selectedRatio ==
                                                  ShareRatio.flexible
                                              ? const ScrollPhysics()
                                              : const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.text,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.getFont(
                                                  _selectedFont,
                                                  fontSize: _adjustedFontSize(
                                                      dynamicFontSize),
                                                  color: _textColor,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.6,
                                                  shadows: const [
                                                    Shadow(
                                                        blurRadius: 8,
                                                        color: Colors.black45,
                                                        offset: Offset(0, 2))
                                                  ],
                                                ),
                                              ),
                                              if (widget.source != null &&
                                                  widget
                                                      .source!.isNotEmpty) ...[
                                                SizedBox(height: 15.h),
                                                Text(
                                                  widget.source!,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 11.sp,
                                                    color: _sourceColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Branding (Safe at bottom)
                                    SizedBox(height: 15.h),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset("assets/images/logoApp.png",
                                            height: 45.h,
                                            width: 45.h,
                                            color: Colors.white),
                                        Text("رفيق المسلم اليومي",
                                            style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 12.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                      // Ratio Selector
                      Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        height: 38.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildRatioTab(
                                "مرن", ShareRatio.flexible, Icons.aspect_ratio),
                            _buildRatioTab("مربع (انستا)", ShareRatio.square,
                                Icons.crop_square),
                            _buildRatioTab("ستوري", ShareRatio.story,
                                Icons.stay_current_portrait),
                            _buildRatioTab(
                                "بوست", ShareRatio.portrait, Icons.portrait),
                          ],
                        ),
                      ),

                      // Internet Requirement Hint
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_download_outlined,
                                color: Colors.amber.withOpacity(0.7),
                                size: 14.sp),
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
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.w),
                                        width: 60.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                          border: _selectedBgIndex == index
                                              ? Border.all(
                                                  color: Colors.amber,
                                                  width: 2.5)
                                              : Border.all(
                                                  color: Colors.white24,
                                                  width: 1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: isCurrentRemote
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      _backgrounds[index].path,
                                                  cacheManager:
                                                      ImageShareService
                                                          .customCacheManager,
                                                  fit: BoxFit.cover,
                                                  imageBuilder:
                                                      (context, imageProvider) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (mounted &&
                                                          !_loadedIndices
                                                              .contains(
                                                                  index)) {
                                                        setState(() =>
                                                            _loadedIndices
                                                                .add(index));
                                                      }
                                                    });
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover),
                                                      ),
                                                    );
                                                  },
                                                  placeholder: (context, url) =>
                                                      Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[800]!,
                                                    highlightColor:
                                                        Colors.grey[700]!,
                                                    child: Container(
                                                        color: Colors.white),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (mounted &&
                                                          !_failedIndices
                                                              .contains(
                                                                  index)) {
                                                        setState(() =>
                                                            _failedIndices
                                                                .add(index));
                                                      }
                                                    });
                                                    return Container(
                                                      color: Colors.black45,
                                                      child: Icon(Icons.refresh,
                                                          color: Colors.white,
                                                          size: 20.sp),
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
                                          child: Icon(Icons.check_circle,
                                              color: Colors.greenAccent,
                                              size: 14.sp),
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
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Font Selector
                            Text(
                              "الخط",
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _fonts
                                    .map((f) => Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4.w),
                                          child: ChoiceChip(
                                            label: Text(f,
                                                style: GoogleFonts.getFont(f,
                                                    color: Colors.white,
                                                    fontSize: 12.sp)),
                                            selected: _selectedFont == f,
                                            onSelected: (val) => setState(
                                                () => _selectedFont = f),
                                            backgroundColor: Colors.white10,
                                            selectedColor:
                                                Colors.amber.shade800,
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Title Color Picker
                            Text(
                              "لون العنوان",
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _titlePalette
                                  .map((c) => GestureDetector(
                                        onTap: () =>
                                            setState(() => _titleColor = c),
                                        child: Container(
                                          width: 32.w,
                                          height: 32.w,
                                          decoration: BoxDecoration(
                                            color: c,
                                            shape: BoxShape.circle,
                                            border: _titleColor == c
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 3)
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),

                            SizedBox(height: 16.h),

                            // Text Color Picker
                            Text(
                              "لون النص",
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _textPalette
                                  .map((c) => GestureDetector(
                                        onTap: () =>
                                            setState(() => _textColor = c),
                                        child: Container(
                                          width: 32.w,
                                          height: 32.w,
                                          decoration: BoxDecoration(
                                            color: c,
                                            shape: BoxShape.circle,
                                            border: _textColor == c
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 3)
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),

                            SizedBox(height: 16.h),

                            // Source Color Picker
                            Text(
                              "لون المصدر",
                              style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: _sourcePalette
                                  .map((c) => GestureDetector(
                                        onTap: () =>
                                            setState(() => _sourceColor = c),
                                        child: Container(
                                          width: 32.w,
                                          height: 32.w,
                                          decoration: BoxDecoration(
                                            color: c,
                                            shape: BoxShape.circle,
                                            border: _sourceColor == c
                                                ? Border.all(
                                                    color: Colors.white,
                                                    width: 3)
                                                : Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    width: 1),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),

                      // Opacity Slider
                      Row(
                        children: [
                          Icon(Icons.opacity,
                              color: Colors.white70, size: 16.sp),
                          Expanded(
                            child: Slider(
                              value: _bgDimming,
                              onChanged: (val) =>
                                  setState(() => _bgDimming = val),
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
                          onPressed: (_isExporting ||
                                  !_loadedIndices.contains(_selectedBgIndex))
                              ? null
                              : _shareImage,
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
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white54))
                                  : const Icon(Icons.share)),
                          label: Text(
                            _isExporting
                                ? "جاري الحفظ..."
                                : (!_loadedIndices.contains(_selectedBgIndex)
                                    ? "جاري التحميل..."
                                    : "مشاركة كصورة"),
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

  // Helper Widgets & Methods
  Widget _buildRatioWrapper({required Widget child}) {
    if (_selectedRatio == ShareRatio.flexible) return child;

    double ratio = 1.0;
    if (_selectedRatio == ShareRatio.square) ratio = 1.0;
    if (_selectedRatio == ShareRatio.story) ratio = 9 / 16;
    if (_selectedRatio == ShareRatio.portrait) ratio = 4 / 5;

    return AspectRatio(
      aspectRatio: ratio,
      child: child,
    );
  }

  Widget _buildRatioTab(String title, ShareRatio ratio, IconData icon) {
    bool isSelected = _selectedRatio == ratio;
    return GestureDetector(
      onTap: () => setState(() => _selectedRatio = ratio),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade800 : Colors.white10,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(title,
                style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  double _adjustedFontSize(double base) {
    if (_selectedRatio == ShareRatio.flexible) return base;
    // For fixed ratios, we slightly reduce font size to ensure it fits better
    if (_selectedRatio == ShareRatio.square) return base * 0.85;
    if (_selectedRatio == ShareRatio.story) return base * 0.95;
    return base;
  }

  Widget _buildElegantDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSmallDivider(isLeft: true),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Icon(Icons.auto_awesome, color: Colors.amber, size: 10.sp),
        ),
        _buildSmallDivider(isLeft: false),
      ],
    );
  }

  Widget _buildContentWrapper({required Widget child}) {
    if (_selectedRatio == ShareRatio.flexible) return child;
    return Positioned.fill(child: child);
  }

  Widget _buildTextExpander({required Widget child}) {
    if (_selectedRatio == ShareRatio.flexible) return child;
    return Expanded(child: Center(child: child));
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
