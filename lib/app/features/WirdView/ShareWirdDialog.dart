import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:muslimdaily/app/core/services/image_share_service.dart';

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

  // Personalization States
  String _selectedFont = "Amiri";
  double _bgDimming = 0.3;

  final List<String> _fonts = ["Amiri", "Cairo", "Changa", "Lateef", "Tajawal"];

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

  Future<void> _captureAndShare() async {
    if (!_loadedIndices.contains(_selectedImageIndex)) return;
    
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
              constraints: const BoxConstraints(minHeight: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                   // 1. Fallback / Base Layer
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        ImageShareService.localBackgrounds[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // 2. Remote Image Layer (with loading handling)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _backgrounds[_selectedImageIndex].isRemote 
                        ? CachedNetworkImage(
                            imageUrl: _backgrounds[_selectedImageIndex].path,
                            cacheManager: ImageShareService.customCacheManager,
                            fit: BoxFit.cover,
                            imageBuilder: (context, imageProvider) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_loadedIndices.contains(_selectedImageIndex)) {
                                  setState(() => _loadedIndices.add(_selectedImageIndex));
                                }
                              });
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                ),
                              );
                            },
                            placeholder: (context, url) => Container(color: Colors.black26),
                            errorWidget: (context, url, error) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && !_failedIndices.contains(_selectedImageIndex)) {
                                  setState(() => _failedIndices.add(_selectedImageIndex));
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
                            _backgrounds[_selectedImageIndex].path,
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),

                  // 3. طبقة تعتيم خفيفة لتحسين قراءة النص
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(_bgDimming),
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
                          style: GoogleFonts.getFont(
                            _selectedFont,
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
                              style: GoogleFonts.getFont(
                                _selectedFont,
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

          const SizedBox(height: 15),

          // Internet Requirement Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi, color: Colors.teal.withOpacity(0.7), size: 14),
              const SizedBox(width: 6),
              Text(
                "خلفيات إضافية (تحتاج اتصال بالإنترنت) ✨",
                style: GoogleFonts.cairo(
                  color: widget.isDark ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 10),

          // تخصيص الخط والشفافية
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._fonts.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ActionChip(
                    label: Text(f, style: GoogleFonts.getFont(f, color: _selectedFont == f ? Colors.white : (widget.isDark ? Colors.white70 : Colors.black87), fontSize: 11)),
                    onPressed: () => setState(() => _selectedFont = f),
                    backgroundColor: _selectedFont == f ? Colors.teal : (widget.isDark ? Colors.grey[800] : Colors.grey[200]),
                  ),
                )),
              ],
            ),
          ),
          
          Row(
            children: [
              Icon(Icons.opacity, color: widget.isDark ? Colors.white70 : Colors.black54, size: 18),
              Expanded(
                child: Slider(
                  value: _bgDimming,
                  onChanged: (val) => setState(() => _bgDimming = val),
                  min: 0.0,
                  max: 0.8,
                  activeColor: Colors.teal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

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
                final isCurrentRemote = _backgrounds[index].isRemote;
                final isFailed = _failedIndices.contains(index);
                return GestureDetector(
                  onTap: () {
                    if (isFailed) {
                      // Manual Retry: Clear from failed and select to trigger re-fetch
                      setState(() {
                        _failedIndices.remove(index);
                        _selectedImageIndex = index;
                      });
                    } else {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    }
                  },
                  child: Opacity(
                    opacity: isFailed ? 0.3 : 1.0,
                    child: SizedBox(
                      width: 60,
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(color: Colors.teal, width: 3)
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
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
                                        child: const Icon(Icons.refresh, color: Colors.white, size: 18),
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
                              top: 2,
                              right: 2,
                              child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 12),
                            ),
                        ],
                      ),
                    ),
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
              onPressed: (_isSharing || !_loadedIndices.contains(_selectedImageIndex)) ? null : _captureAndShare,
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : (!_loadedIndices.contains(_selectedImageIndex) 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2))
                      : const Icon(Icons.share, color: Colors.white)),
              label: Text(
                _isSharing 
                    ? "جاري التجهيز..." 
                    : (!_loadedIndices.contains(_selectedImageIndex) ? "جاري التحميل..." : "مشاركة الصورة"),
                style: const TextStyle(
                    fontFamily: "cairo",
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey[800],
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
