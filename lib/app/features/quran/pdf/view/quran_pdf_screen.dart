import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/features/quran/pdf/view/widgets/pdf_navigation_dialog.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:get_storage/get_storage.dart';

class QuranPdfScreen extends StatefulWidget {
  final String? pdfPath;
  final bool isAsset;

  const QuranPdfScreen({
    super.key,
    this.pdfPath,
    this.isAsset = true,
  });

  @override
  State<QuranPdfScreen> createState() => _QuranPdfScreenState();
}

class _QuranPdfScreenState extends State<QuranPdfScreen> {
  PDFViewController? _pdfController;
  late final String _path;
  int _totalPages = 0;
  int _currentPage = 0;
  final int _pageOffset = 2; // Adjusted based on user feedback (Cover + 2 Intro)
  bool _isFullScreen = false;
  final _storage = GetStorage();
  
  String get _storageKey => 'pdf_page_${widget.pdfPath.hashCode}';

  @override
  void initState() {
    super.initState();
    _path = widget.pdfPath ?? '';
    _currentPage = _storage.read<int>(_storageKey) ?? 0;
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                'القرآن الكريم (PDF)',
                style: TextStyle(
                  fontFamily: "cairo",
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              iconTheme:
                  IconThemeData(color: isDark ? Colors.white : Colors.black),
              actions: [
                IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: 'الفهرس',
                  onPressed: () async {
                    final page = await showDialog<int>(
                      context: context,
                      builder: (context) => const PdfNavigationDialog(),
                    );

                    if (page != null && _pdfController != null) {
                      final targetIndex = page - 1 + _pageOffset;
                      await _pdfController!.setPage(targetIndex);
                    }
                  },
                ),
              ],
            ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isFullScreen = !_isFullScreen;
          });
        },
        child: Directionality(
          textDirection: TextDirection.ltr, // PDF View works better with LTR
          child: Stack(
            children: [
              widget.isAsset
                  ? PDF(
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      pageSnap: true,
                      defaultPage: _currentPage,
                      fitPolicy: FitPolicy.WIDTH,
                      onPageChanged: (int? page, int? total) {
                        if (mounted && page != null) {
                          setState(() {
                            _currentPage = page;
                            _totalPages = total ?? 0;
                          });
                          _storage.write(_storageKey, page);
                        }
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _pdfController = pdfViewController;
                      },
                      onError: (dynamic error) =>
                          Center(child: Text(error.toString())),
                    ).fromAsset(
                      _path,
                    )
                  : PDF(
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: false,
                      pageSnap: true,
                      defaultPage: _currentPage,
                      fitPolicy: FitPolicy.WIDTH,
                      onPageChanged: (int? page, int? total) {
                        if (mounted && page != null) {
                          setState(() {
                            _currentPage = page;
                            _totalPages = total ?? 0;
                          });
                          _storage.write(_storageKey, page);
                        }
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _pdfController = pdfViewController;
                      },
                      onError: (dynamic error) =>
                          Center(child: Text(error.toString())),
                    ).fromPath(
                      _path,
                    ),
              if (_isFullScreen)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPageLabel(),
                        style: TextStyle(
                  fontFamily: "cairo",
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isFullScreen
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getPageLabel(),
                    style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
    );
  }

  String _getPageLabel() {
    final int quranPage = _currentPage - _pageOffset + 1;

    if (quranPage <= 0) {
      return 'مقدمة';
    }
    final int totalQuranPages =
        _totalPages > 0 ? _totalPages - _pageOffset : 604;
    return 'صفحة $quranPage / $totalQuranPages';
  }
}
