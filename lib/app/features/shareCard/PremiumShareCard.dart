import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
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
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Header with Close and Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "تخصيص ومشاركة",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),

            // Preview area (Top - constrained height)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: RepaintBoundary(
                  key: _globalKey,
                  child: _buildRatioWrapper(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: _selectedRatio == ShareRatio.flexible
                            ? BorderRadius.circular(28.r)
                            : BorderRadius.zero,
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

                          // 2. Remote Image Layer
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
                                      cacheManager:
                                          ImageShareService.customCacheManager,
                                      fit: BoxFit.cover,
                                      imageBuilder: (context, imageProvider) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (mounted &&
                                              !_loadedIndices
                                                  .contains(_selectedBgIndex)) {
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
                                              !_failedIndices
                                                  .contains(_selectedBgIndex)) {
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
                                horizontal:
                                    _selectedRatio == ShareRatio.flexible
                                        ? 22.w
                                        : 18.w,
                                vertical: _selectedRatio == ShareRatio.flexible
                                    ? 30.h
                                    : 20.h,
                              ),
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
                                          fontSize: _selectedRatio ==
                                                  ShareRatio.flexible
                                              ? 20.sp
                                              : 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: _selectedRatio ==
                                                ShareRatio.flexible
                                            ? 10.h
                                            : 6.h),
                                    _buildElegantDivider(),
                                    SizedBox(
                                        height: _selectedRatio ==
                                                ShareRatio.flexible
                                            ? 25.h
                                            : 15.h),
                                  ],

                                  // Main Text Box
                                  _buildTextExpander(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: _selectedRatio ==
                                                ShareRatio.flexible
                                            ? 15.h
                                            : 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.12)),
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
                                                widget.source!.isNotEmpty) ...[
                                              SizedBox(
                                                  height: _selectedRatio ==
                                                          ShareRatio.flexible
                                                      ? 15.h
                                                      : 8.h),
                                              Text(
                                                widget.source!,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.cairo(
                                                  fontSize: _selectedRatio ==
                                                          ShareRatio.flexible
                                                      ? 11.sp
                                                      : 9.sp,
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
                                  SizedBox(
                                      height:
                                          _selectedRatio == ShareRatio.flexible
                                              ? 15.h
                                              : 8.h),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        "assets/images/logoApp.png",
                                        height: _selectedRatio ==
                                                ShareRatio.flexible
                                            ? 45.h
                                            : 35.h,
                                        width: _selectedRatio ==
                                                ShareRatio.flexible
                                            ? 45.h
                                            : 35.h,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "رفيق المسلم اليومي",
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: _selectedRatio ==
                                                  ShareRatio.flexible
                                              ? 12.sp
                                              : 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_selectedRatio ==
                                          ShareRatio.flexible) ...[
                                        SizedBox(height: 10.h),
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
              ),
            ),

            // Controls Area (Bottom - scrollable)
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 130.h),
                    child: Column(
                      children: [
                        // Background Selector
                        SizedBox(
                          height: 60.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _backgrounds.length,
                            itemBuilder: (context, index) {
                              bool isCurrentRemote =
                                  _backgrounds[index].isRemote;
                              bool isFailed = _failedIndices.contains(index);
                              return GestureDetector(
                                onTap: () {
                                  if (isFailed) {
                                    setState(() {
                                      _failedIndices.remove(index);
                                      _selectedBgIndex = index;
                                    });
                                  } else {
                                    setState(() => _selectedBgIndex = index);
                                  }
                                },
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
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: isCurrentRemote
                                              ? CachedNetworkImage(
                                                  imageUrl:
                                                      _backgrounds[index].path,
                                                  cacheManager:
                                                      ImageShareService
                                                          .customCacheManager,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          color:
                                                              Colors.grey[900]),
                                                  errorWidget: (context, url,
                                                          e) =>
                                                      const Icon(
                                                          Icons.cloud_off,
                                                          color:
                                                              Colors.white24),
                                                )
                                              : Image.asset(
                                                  _backgrounds[index].path,
                                                  fit: BoxFit.cover),
                                        ),
                                        if (_loadedIndices.contains(index))
                                          Positioned(
                                              top: 4.w,
                                              right: 4.w,
                                              child: Icon(Icons.check_circle,
                                                  color: Colors.greenAccent,
                                                  size: 14.sp)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Personalization Tools Box
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("الخط",
                                  style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold)),
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
                                                      fontSize: 11.sp)),
                                              selected: _selectedFont == f,
                                              onSelected: (_) => setState(
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
                              Text("الألوان",
                                  style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10.h),
                              // Re-implementing the color picks simply
                              _buildSimpleColorSection(
                                  "لون العنوان",
                                  _titlePalette,
                                  _titleColor,
                                  (c) => setState(() => _titleColor = c)),
                              _buildSimpleColorSection(
                                  "لون النص",
                                  _textPalette,
                                  _textColor,
                                  (c) => setState(() => _textColor = c)),
                              _buildSimpleColorSection(
                                  "لون المصدر",
                                  _sourcePalette,
                                  _sourceColor,
                                  (c) => setState(() => _sourceColor = c)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fixed Bottom Overlay (Ratio & Share)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30.r)),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildRatioTab("مرن", ShareRatio.flexible,
                                      Icons.aspect_ratio),
                                  _buildRatioTab("مربع", ShareRatio.square,
                                      Icons.crop_square),
                                  _buildRatioTab("ستوري", ShareRatio.story,
                                      Icons.stay_current_portrait),
                                  _buildRatioTab("بوست", ShareRatio.portrait,
                                      Icons.portrait),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Icon(Icons.opacity,
                                    color: Colors.white70, size: 16.sp),
                                Expanded(
                                  child: Slider(
                                    value: _bgDimming,
                                    onChanged: (v) =>
                                        setState(() => _bgDimming = v),
                                    min: 0.0,
                                    max: 0.8,
                                    activeColor: Colors.amber,
                                    inactiveColor: Colors.white24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: 10.h), // Added a SizedBox for spacing
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (_isExporting ||
                                        !_loadedIndices
                                            .contains(_selectedBgIndex))
                                    ? null
                                    : _shareImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[800],
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.r)),
                                  elevation: 8,
                                  shadowColor: Colors.amber.withOpacity(0.5),
                                ),
                                icon: _isExporting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : (!_loadedIndices
                                            .contains(_selectedBgIndex)
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
                                      : (!_loadedIndices
                                              .contains(_selectedBgIndex)
                                          ? "جاري التحميل..."
                                          : "مشاركة كصورة"),
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildSimpleColorSection(String label, List<Color> palette,
      Color current, Function(Color) onSelect) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SizedBox(
              width: 75.w,
              child: Text(label,
                  style: GoogleFonts.cairo(
                      color: Colors.white70, fontSize: 10.sp))),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: palette
                    .map((c) => GestureDetector(
                          onTap: () => onSelect(c),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: current == c
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
