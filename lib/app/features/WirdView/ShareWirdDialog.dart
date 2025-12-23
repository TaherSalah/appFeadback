import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:muslimdaily/app/core/services/image_share_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late List<ShareImageItem> _backgrounds;
  int _selectedImageIndex = 0;
  bool _isSharing = false;
  final Set<int> _loadedIndices = {};
  final Set<int> _failedIndices = {};

  String _selectedFont = "Amiri";
  double _bgDimming = 0.3;

  final List<String> _fonts = ["Amiri", "Cairo", "Changa", "Lateef", "Tajawal"];

  @override
  void initState() {
    super.initState();
    _backgrounds = ImageShareService.getAllBackgrounds();
    for (int i = 0; i < _backgrounds.length; i++) {
      if (!_backgrounds[i].isRemote) {
        _loadedIndices.add(i);
      }
    }
  }

  Future<void> _captureAndShare() async {
    if (!_loadedIndices.contains(_selectedImageIndex)) return;
    
    setState(() => _isSharing = true);

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/dhikr_share.png');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles([XFile(file.path)], text: 'شارك الذكر مع من تحب');
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.tealAccent : const Color(0xFF00897B);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("مشاركة الذكر", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp, color: isDark ? Colors.white : Colors.black87)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey.withOpacity(0.5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: double.infinity,
                  height: 350.h,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildBackgroundImage(_selectedImageIndex),
                      ),
                      Container(color: Colors.black.withOpacity(_bgDimming)),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              widget.dhikrText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(_selectedFont, fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.bold, height: 1.5),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/logoApp.png", height: 32.h, width: 32.h),
                                SizedBox(width: 8.w),
                                Text("رفيق المسلم", style: GoogleFonts.cairo(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _buildControlSection(isDark, primaryColor),
              SizedBox(height: 24.h),
              _buildShareButton(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(int index) {
    if (_backgrounds[index].isRemote) {
      return CachedNetworkImage(
        imageUrl: _backgrounds[index].path,
        cacheManager: ImageShareService.customCacheManager,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[800], child: const Center(child: CupertinoActivityIndicator(color: Colors.white))),
        errorWidget: (context, url, error) => Container(color: Colors.grey[800], child: const Icon(Icons.error_outline, color: Colors.white54)),
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_loadedIndices.contains(index)) setState(() => _loadedIndices.add(index));
          });
          return Container(decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover)));
        },
      );
    }
    return Image.asset(_backgrounds[index].path, fit: BoxFit.cover);
  }

  Widget _buildControlSection(bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("تخصيص التصميم", style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _fonts.map((f) => Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: ChoiceChip(
                label: Text(f, style: GoogleFonts.getFont(f, fontSize: 10.sp)),
                selected: _selectedFont == f,
                onSelected: (val) => setState(() => _selectedFont = f),
                selectedColor: primaryColor,
                labelStyle: TextStyle(color: _selectedFont == f ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87)),
                backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide.none,
              ),
            )).toList(),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Icon(CupertinoIcons.circle_lefthalf_fill, size: 16.sp, color: Colors.grey),
            Expanded(
              child: Slider(
                value: _bgDimming,
                min: 0.1,
                max: 0.8,
                activeColor: primaryColor,
                onChanged: (val) => setState(() => _bgDimming = val),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text("الخلفيات", style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
        SizedBox(height: 12.h),
        SizedBox(
          height: 60.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedImageIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  width: 60.h,
                  margin: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
                    image: DecorationImage(
                      image: _backgrounds[index].isRemote 
                        ? CachedNetworkImageProvider(_backgrounds[index].path, cacheManager: ImageShareService.customCacheManager)
                        : AssetImage(_backgrounds[index].path) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isSelected ? Center(child: Icon(Icons.check_circle_rounded, color: primaryColor, size: 20.sp)) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isSharing || !_loadedIndices.contains(_selectedImageIndex)) ? null : _captureAndShare,
        icon: _isSharing 
          ? const CupertinoActivityIndicator(color: Colors.white) 
          : const Icon(CupertinoIcons.share),
        label: Text(_isSharing ? "جاري التجهيز..." : "مشاركة الصورة", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
