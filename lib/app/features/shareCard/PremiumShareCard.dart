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
  double _fontSizeMultiplier = 1.0; // New: Font size control
  Color _titleColor = const Color(0xFFFFD700); // Default Gold
  Color _textColor = const Color(0xFFFFFFFF); // Default White for main text
  Color _sourceColor = const Color(0xFFD4AF37); // Default Gold for source
  Color _dividerColor = const Color(0xFFFFD700);

  // Preset Themes
  String _selectedTheme = "ذهبي كلاسيكي";
  final Map<String, Map<String, Color>> _themes = {
    "ذهبي كلاسيكي": {
      "title": const Color(0xFFFFD700),
      "text": const Color(0xFFFFFFFF),
      "source": const Color(0xFFD4AF37),
      "divider": const Color(0xFFFFD700),
    },
    "أخضر إسلامي": {
      "title": const Color(0xFF4CAF50),
      "text": const Color(0xFFE8F5E9),
      "source": const Color(0xFF81C784),
      "divider": const Color(0xFF4CAF50),
    },
    // كرر لباقي الثيمات...
  };

  // final Map<String, Map<String, Color>> _themes = {
  //   "ذهبي كلاسيكي": {
  //     "title": const Color(0xFFFFD700),
  //     "text": const Color(0xFFFFFFFF),
  //     "source": const Color(0xFFD4AF37),
  //   },
  //   "أخضر إسلامي": {
  //     "title": const Color(0xFF4CAF50),
  //     "text": const Color(0xFFE8F5E9),
  //     "source": const Color(0xFF81C784),
  //   },
  //   "أزرق سماوي": {
  //     "title": const Color(0xFF2196F3),
  //     "text": const Color(0xFFE3F2FD),
  //     "source": const Color(0xFF64B5F6),
  //   },
  //   "بنفسجي راقي": {
  //     "title": const Color(0xFF9C27B0),
  //     "text": const Color(0xFFF3E5F5),
  //     "source": const Color(0xFFBA68C8),
  //   },
  //   "برتقالي دافئ": {
  //     "title": const Color(0xFFFF9800),
  //     "text": const Color(0xFFFFF3E0),
  //     "source": const Color(0xFFFFB74D),
  //   },
  // };

  final List<String> _fonts = ["Amiri", "Cairo", "Changa", "Lateef", "Tajawal"];

  // Enhanced Color Palettes with Islamic theme
  final List<Color> _titlePalette = [
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFFFFFF), // White
    const Color(0xFF4CAF50), // Green (Islamic)
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF009688), // Teal
  ];

  final List<Color> _textPalette = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFFFFF8DC), // Cornsilk
    const Color(0xFFE8F5E9), // Light Green
    const Color(0xFFE0F7FA), // Light Cyan
    const Color(0xFFFFF3E0), // Light Orange
    const Color(0xFFF3E5F5), // Light Purple
    const Color(0xFFFCE4EC), // Light Pink
    const Color(0xFFE3F2FD), // Light Blue
    const Color(0xFFFFE0B2), // Light Amber
    const Color(0xFFB2DFDB), // Light Teal
  ];

  final List<Color> _sourcePalette = [
    const Color(0xFFD4AF37), // Gold
    const Color(0xFFFFFFFF), // White
    const Color(0xFF81C784), // Light Green
    const Color(0xFF4DD0E1), // Light Cyan
    const Color(0xFFFFB74D), // Light Orange
    const Color(0xFFBA68C8), // Light Purple
    const Color(0xFFF48FB1), // Light Pink
    const Color(0xFF64B5F6), // Light Blue
    const Color(0xFFFFCC80), // Light Amber
    const Color(0xFF80CBC4), // Light Teal
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

  @override
  Widget build(BuildContext context) {
    bool isRemote = _backgrounds[_selectedBgIndex].isRemote;

    // Dynamic Font Scaling Logic - Enhanced for different ratios
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
                              padding: _getContentPadding(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Top Section: Category Name
                                  if (widget.azkarName.isNotEmpty) ...[
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                                              fontSize: _getTitleFontSize(),
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: _getDividerSpacing()),
                                        _buildElegantDivider(),
                                      ],
                                    ),
                                  ],

                                  // Middle Section: Main Text Box (Expanded)
                                  _buildTextExpander(
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: _getTextBoxPadding(),
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
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              widget.text,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.getFont(
                                                _selectedFont,
                                                fontSize: _adjustedFontSize(
                                                    dynamicFontSize) * _fontSizeMultiplier,
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
                                              SizedBox(height: _getSourceSpacing()),
                                              Text(
                                                widget.source!,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.cairo(
                                                  fontSize: _getSourceFontSize(),
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

                                  // Bottom Section: Branding (Always visible)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: _getBrandingTopSpacing()),
                                      Image.asset(
                                        "assets/images/logoApp.png",
                                        height: _getLogoSize(),
                                        width: _getLogoSize(),
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "رفيق المسلم اليومي",
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: _getBrandingFontSize(),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_selectedRatio ==
                                          ShareRatio.flexible) ...[
                                        SizedBox(height: 8.h),
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
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 250.h),
                    child: Column(
                      children: [
                        // Preset Themes Section
                        // Container(
                        //   padding: EdgeInsets.all(14.w),
                        //   decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //       colors: [
                        //         const Color(0xFFD4AF37).withOpacity(0.15),
                        //         const Color(0xFFFFD700).withOpacity(0.05),
                        //       ],
                        //       begin: Alignment.topRight,
                        //       end: Alignment.bottomLeft,
                        //     ),
                        //     borderRadius: BorderRadius.circular(20.r),
                        //     border: Border.all(
                        //         color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Icon(Icons.color_lens,
                        //               color: const Color(0xFFFFD700), size: 16.sp),
                        //           SizedBox(width: 8.w),
                        //           Text("الثيمات الجاهزة",
                        //               style: GoogleFonts.cairo(
                        //                   color: Colors.white,
                        //                   fontSize: 12.sp,
                        //                   fontWeight: FontWeight.bold)),
                        //         ],
                        //       ),
                        //       SizedBox(height: 10.h),
                        //       SingleChildScrollView(
                        //         scrollDirection: Axis.horizontal,
                        //         child: Row(
                        //           children: _themes.keys.map((themeName) {
                        //             bool isSelected = _selectedTheme == themeName;
                        //             return GestureDetector(
                        //               onTap: () {
                        //                 setState(() {
                        //                   _selectedTheme = themeName;
                        //                   _titleColor = _themes[themeName]!["title"]!;
                        //                   _textColor = _themes[themeName]!["text"]!;
                        //                   _sourceColor = _themes[themeName]!["source"]!;
                        //                   _dividerColor = _themes[themeName]!["divider"] ?? _titleColor;
                        //                 });
                        //               },
                        //               child: Container(
                        //                 margin: EdgeInsets.symmetric(horizontal: 4.w),
                        //                 padding: EdgeInsets.symmetric(
                        //                     horizontal: 12.w, vertical: 8.h),
                        //                 decoration: BoxDecoration(
                        //                   gradient: isSelected
                        //                       ? LinearGradient(
                        //                     colors: [
                        //                       _themes[themeName]!["title"]!,
                        //                       _themes[themeName]!["source"]!,
                        //                     ],
                        //                   )
                        //                       : null,
                        //                   color: isSelected
                        //                       ? null
                        //                       : Colors.white.withOpacity(0.1),
                        //                   borderRadius: BorderRadius.circular(12.r),
                        //                   border: Border.all(
                        //                     color: isSelected
                        //                         ? Colors.white.withOpacity(0.5)
                        //                         : Colors.white24,
                        //                     width: isSelected ? 2 : 1,
                        //                   ),
                        //                 ),
                        //                 child: Row(
                        //                   children: [
                        //                     // Color indicator dots
                        //                     Column(
                        //                       children: [
                        //                         Container(
                        //                           width: 8.w,
                        //                           height: 8.w,
                        //                           decoration: BoxDecoration(
                        //                             color: _themes[themeName]!["title"],
                        //                             shape: BoxShape.circle,
                        //                             border: Border.all(
                        //                                 color: Colors.white, width: 1),
                        //                           ),
                        //                         ),
                        //                         SizedBox(height: 2.h),
                        //                         Container(
                        //                           width: 8.w,
                        //                           height: 8.w,
                        //                           decoration: BoxDecoration(
                        //                             color: _themes[themeName]!["text"],
                        //                             shape: BoxShape.circle,
                        //                             border: Border.all(
                        //                                 color: Colors.white, width: 1),
                        //                           ),
                        //                         ),
                        //                       ],
                        //                     ),
                        //                     SizedBox(width: 8.w),
                        //                     Text(
                        //                       themeName,
                        //                       style: GoogleFonts.cairo(
                        //                         color: isSelected
                        //                             ? Colors.white
                        //                             : Colors.white70,
                        //                         fontSize: 10.sp,
                        //                         fontWeight: isSelected
                        //                             ? FontWeight.bold
                        //                             : FontWeight.w600,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //               ),
                        //             );
                        //           }).toList(),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 12.h),

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

                        // Enhanced Personalization Tools Box
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Font Section
                              Row(
                                children: [
                                  Icon(Icons.font_download,
                                      color: const Color(0xFFD4AF37), size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text("نوع الخط",
                                      style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 10.h),
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
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold)),
                                      selected: _selectedFont == f,
                                      onSelected: (_) => setState(
                                              () => _selectedFont = f),
                                      backgroundColor: const Color(0xFF2C2C2C),
                                      selectedColor:
                                      const Color(0xFFD4AF37),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        side: BorderSide(
                                          color: _selectedFont == f
                                              ? const Color(0xFFFFD700)
                                              : Colors.white24,
                                          width: _selectedFont == f ? 2 : 1,
                                        ),
                                      ),
                                      labelPadding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                    ),
                                  ))
                                      .toList(),
                                ),
                              ),

                              SizedBox(height: 20.h),
                              Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                              SizedBox(height: 16.h),

                              // Font Size Control
                              Row(
                                children: [
                                  Icon(Icons.format_size,
                                      color: const Color(0xFFD4AF37), size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text("حجم الخط",
                                      style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Icon(Icons.text_fields,
                                      color: Colors.white54, size: 14.sp),
                                  Expanded(
                                    child: Slider(
                                      value: _fontSizeMultiplier,
                                      onChanged: (v) => setState(() => _fontSizeMultiplier = v),
                                      min: 0.7,
                                      max: 1.3,
                                      divisions: 12,
                                      activeColor: const Color(0xFFFFD700),
                                      inactiveColor: Colors.white24,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: const Color(0xFFD4AF37).withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "${(_fontSizeMultiplier * 100).toInt()}%",
                                      style: GoogleFonts.cairo(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),
                              Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                              SizedBox(height: 16.h),

                              // Enhanced Color Sections
                              Row(
                                children: [
                                  Icon(Icons.palette,
                                      color: const Color(0xFFD4AF37), size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text("تخصيص الألوان",
                                      style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 14.h),

                              _buildEnhancedColorSection(
                                  "لون العنوان",
                                  _titlePalette,
                                  _titleColor,
                                  Icons.title,
                                      (c) => setState(() => _titleColor = c)),

                              _buildEnhancedColorSection(
                                  "لون النص الأساسي",
                                  _textPalette,
                                  _textColor,
                                  Icons.text_fields,
                                      (c) => setState(() => _textColor = c)),

                              _buildEnhancedColorSection(
                                  "لون المصدر",
                                  _sourcePalette,
                                  _sourceColor,
                                  Icons.source,
                                      (c) => setState(() => _sourceColor = c)),
                              _buildEnhancedColorSection(
                                "لون الخط الفاصل",
                                _titlePalette,
                                _dividerColor,
                                Icons.horizontal_rule,
                                    (c) => setState(() => _dividerColor = c),
                              ),

                              // Reset Button
                              SizedBox(height: 10.h),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFont = "Amiri";
                                      _bgDimming = 0.4;
                                      _fontSizeMultiplier = 1.0;
                                      _titleColor = const Color(0xFFFFD700);
                                      _textColor = const Color(0xFFFFFFFF);
                                      _sourceColor = const Color(0xFFD4AF37);
                                      _selectedTheme = "ذهبي كلاسيكي";
                                      _dividerColor = const Color(0xFFFFD700);

                                    });
                                  },
                                  icon: const Icon(Icons.restart_alt, size: 18),
                                  label: Text(
                                    "إعادة تعيين الإعدادات",
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(0.3)),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
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

                  // Fixed Bottom Overlay (Ratio & Share)
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30.r)),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          border:
                          Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ratio Tabs
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

                            SizedBox(height: 12.h),

                            // Dimming Slider
                            Row(
                              children: [
                                Icon(Icons.opacity,
                                    color: const Color(0xFFD4AF37), size: 18.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Slider(
                                    value: _bgDimming,
                                    onChanged: (v) =>
                                        setState(() => _bgDimming = v),
                                    min: 0.0,
                                    max: 0.8,
                                    activeColor: const Color(0xFFFFD700),
                                    inactiveColor: Colors.white24,
                                  ),
                                ),
                                Text(
                                  "${(_bgDimming * 100).toInt()}%",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white70,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // Share Button
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
                                  shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
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

  // Helper Methods for Responsive Sizing
  EdgeInsets _getContentPadding() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return EdgeInsets.symmetric(horizontal: 22.w, vertical: 30.h);
      case ShareRatio.square:
        return EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h);
      case ShareRatio.story:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 25.h);
      case ShareRatio.portrait:
        return EdgeInsets.symmetric(horizontal: 18.w, vertical: 22.h);
    }
  }

  double _getTitleFontSize() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 20.sp;
      case ShareRatio.square:
        return 16.sp;
      case ShareRatio.story:
        return 18.sp;
      case ShareRatio.portrait:
        return 17.sp;
    }
  }

  double _getDividerSpacing() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 10.h;
      case ShareRatio.square:
        return 6.h;
      case ShareRatio.story:
        return 8.h;
      case ShareRatio.portrait:
        return 7.h;
    }
  }

  double _getTextBoxPadding() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 15.h;
      case ShareRatio.square:
        return 10.h;
      case ShareRatio.story:
        return 12.h;
      case ShareRatio.portrait:
        return 12.h;
    }
  }

  double _getSourceSpacing() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 15.h;
      case ShareRatio.square:
        return 8.h;
      case ShareRatio.story:
        return 10.h;
      case ShareRatio.portrait:
        return 10.h;
    }
  }

  double _getSourceFontSize() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 11.sp;
      case ShareRatio.square:
        return 9.sp;
      case ShareRatio.story:
        return 10.sp;
      case ShareRatio.portrait:
        return 10.sp;
    }
  }

  double _getBrandingTopSpacing() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 15.h;
      case ShareRatio.square:
        return 8.h;
      case ShareRatio.story:
        return 10.h;
      case ShareRatio.portrait:
        return 10.h;
    }
  }

  double _getLogoSize() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 45.h;
      case ShareRatio.square:
        return 32.h;
      case ShareRatio.story:
        return 38.h;
      case ShareRatio.portrait:
        return 35.h;
    }
  }

  double _getBrandingFontSize() {
    switch (_selectedRatio) {
      case ShareRatio.flexible:
        return 12.sp;
      case ShareRatio.square:
        return 9.sp;
      case ShareRatio.story:
        return 10.sp;
      case ShareRatio.portrait:
        return 10.sp;
    }
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFD4AF37)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
              : Border.all(color: Colors.white24),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16.sp,
                color: isSelected ? Colors.white : Colors.white70),
            SizedBox(width: 6.w),
            Text(title,
                style: GoogleFonts.cairo(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  double _adjustedFontSize(double base) {
    if (_selectedRatio == ShareRatio.flexible) return base;
    if (_selectedRatio == ShareRatio.square) return base * 0.80;
    if (_selectedRatio == ShareRatio.story) return base * 0.90;
    return base * 0.85;
  }

  Widget _buildElegantDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSmallDivider(isLeft: true),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Icon(Icons.auto_awesome,
              color: _dividerColor,
              size: _selectedRatio == ShareRatio.flexible ? 12.sp : 10.sp),
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
              ? [Colors.transparent, _dividerColor.withOpacity(0.8)]
              : [_dividerColor.withOpacity(0.8), Colors.transparent],
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

  Widget _buildEnhancedColorSection(
      String label,
      List<Color> palette,
      Color current,
      IconData icon,
      Function(Color) onSelect,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with Icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: current.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: current.withOpacity(0.4)),
                ),
                child: Icon(icon, color: current, size: 14.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Current Color Preview
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: current.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: _getContrastColor(current),
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Color Palette
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: palette.map((c) {
                bool isSelected = current == c;
                return GestureDetector(
                  onTap: () => onSelect(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isSelected ? 40.w : 34.w,
                    height: isSelected ? 40.w : 34.w,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: c.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: _getContrastColor(c),
                      size: 18.sp,
                    )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}