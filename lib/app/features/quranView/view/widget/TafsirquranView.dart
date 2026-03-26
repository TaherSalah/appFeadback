import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:quran_library/quran.dart';

import '../../../../core/utils/style/k_helper.dart';
import '../TafsirViewerDetailsScreen.dart';

class TafsirQuranView extends StatefulWidget {
  const TafsirQuranView({super.key});

  @override
  State<TafsirQuranView> createState() => _TafsirQuranViewState();
}

class _TafsirQuranViewState extends State<TafsirQuranView> {
  final _ql = QuranLibrary();
  final Set<int> _downloading = {};
  bool _inited = false;

  @override
  void initState() {
    super.initState();
    _initTafsirOnce();
  }

  Future<void> _initTafsirOnce() async {
    if (mounted) setState(() => _inited = true);
  }

  // ─── Download dialog styled like delete-wird ───────────────────────────────
  void _showDownloadDialog(String tafsirName) {
    final bool isDark = context.isDark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            backgroundColor: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Body
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isDark
                          ? [const Color(0xFF0A1F12), const Color(0xFF061209)]
                          : [const Color(0xFFF2FFF6), const Color(0xFFE1FFE9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'جاري تحميل التفسير',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tafsirName,
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF43A047),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'يتم الآن تنزيل ملف التفسير.\nيُرجى الانتظار حتى اكتمال التحميل.',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 13,
                          height: 1.6,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.green.withOpacity(0.07),
                          border: Border.all(
                              color: Colors.green.withOpacity(0.4), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'لن تحتاج إلى تنزيله مجدداً — سيُحفظ على جهازك.',
                                style: TextStyle(
                  fontFamily: "cairo",
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating circle icon
                Positioned(
                  top: -30,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.6),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.cloud_download_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownloadOrOpen(int index, String tafsirName) async {
    if (_downloading.contains(index)) return;

    final isDownloaded = _ql.getTafsirDownloaded(index);
    if (isDownloaded) {
      _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
      ));
      return;
    }

    setState(() => _downloading.add(index));
    _showDownloadDialog(tafsirName);

    try {
      await _ql.tafsirDownload(index);
      _ql.changeTafsirSwitch(index, pageNumber: _ql.currentPageNumber);
      if (mounted) {
        Navigator.of(context).pop(); // close dialog
        KHelper.showSuccess(message: 'تم تنزيل التفسير بنجاح ✅');
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              TafsirViewerDetailsScreen(initialPage: _ql.currentPageNumber),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        KHelper.showError(message: 'تعذّر تنزيل التفسير: $e');
      }
    } finally {
      if (mounted) setState(() => _downloading.remove(index));
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    final isDark = context.isDark;
    final isTablet = context.isTab;
    final books = _ql.tafsirAndTraslationsCollection;
    const imagePath = 'assets/images';
    final tafsirImages = List.generate(6, (i) => '$imagePath/${i + 1}.jpg');

    final bgColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F7F5);
    final cardColor = isDark ? const Color(0xFF161D1B) : Colors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(isTablet ? 70 : 56),
          child: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black87,
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'كتب تفسير القرآن الكريم',
                  style: TextStyle(
                  fontFamily: "cairo",
                    color: const Color(0xFF43A047),
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 14.sp : 17.sp,
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFFD4AF37)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: tafsirImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: isTablet ? 1 / 1.3 : 1 / 1.75,
            ),
            itemBuilder: (context, index) {
              final isDownloaded = _ql.getTafsirDownloaded(index);
              final isBusy = _downloading.contains(index);
              final name = books[index].name ?? 'تفسير ${index + 1}';

              return _BookCard(
                imagePath: tafsirImages[index],
                name: name,
                isDownloaded: isDownloaded,
                isBusy: isBusy,
                isDark: isDark,
                isTablet: isTablet,
                cardColor: cardColor,
                onTap: () => _handleDownloadOrOpen(index, name),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Book Card Widget ──────────────────────────────────────────────────────────
class _BookCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isDownloaded;
  final bool isBusy;
  final bool isDark;
  final bool isTablet;
  final Color cardColor;
  final VoidCallback onTap;

  const _BookCard({
    required this.imagePath,
    required this.name,
    required this.isDownloaded,
    required this.isBusy,
    required this.isDark,
    required this.isTablet,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card body
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: isDownloaded
                    ? const Color(0xFF43A047).withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Book Cover
                  Expanded(
                    flex: 7,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: isDark
                                ? const Color(0xFF1A2A1E)
                                : const Color(0xFFE8F5E9),
                            child: const Icon(Icons.menu_book_rounded,
                                size: 40, color: Color(0xFF43A047)),
                          ),
                        ),
                        // Gradient overlay at bottom
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.6, 1.0],
                                colors: [
                                  Colors.transparent,
                                  cardColor.withOpacity(0.95),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Downloaded badge
                        if (isDownloaded)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43A047),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 10, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    'محمّل',
                                    style: TextStyle(
                  fontFamily: "cairo",
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Book Name + action row
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: isTablet ? 9.sp : 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Action button
                          _ActionButton(
                            isBusy: isBusy,
                            isDownloaded: isDownloaded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isBusy;
  final bool isDownloaded;

  const _ActionButton({required this.isBusy, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF4CAF50),
        ),
      );
    }

    if (isDownloaded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded,
                size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'اقرأ',
              style: TextStyle(
                  fontFamily: "cairo",
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Not downloaded
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF43A047), width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_download_outlined,
              size: 14, color: Color(0xFF43A047)),
          const SizedBox(width: 4),
          Text(
            'تحميل',
            style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 11,
                color: const Color(0xFF43A047),
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
