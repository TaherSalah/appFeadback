import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_book_model.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_service.dart';
import 'package:muslimdaily/app/features/quran/pdf/view/quran_pdf_screen.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/services/feature_guard_service.dart';
import '../../../../core/utils/style/k_helper.dart';

class PdfListScreen extends StatefulWidget {
  const PdfListScreen({super.key});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  final PdfService _pdfService = PdfService();
  List<PdfBookModel> _books = [];
  bool _isLoading = true;
  final Map<String, double> _downloadProgress = {};
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final canAccess =
        await FeatureGuardService().canAccess(context, 'pdf_library');
    if (!canAccess && mounted) {
      if (mounted) Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final books = await _pdfService.fetchPdfBooks();

      // Check download status for each book
      for (var book in books) {
        book.isDownloaded = await _pdfService.isPdfDownloaded(book.fileName);
      }

      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
        _checkAutoResume();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        KHelper.showError(message: "فشل تحميل قائمة الكتب");
      }
    }
  }

  Future<void> _checkAutoResume() async {
    final String? lastPath = _storage.read<String>('last_pdf_path');
    if (lastPath != null && mounted) {
      // Check if file still exists
      if (await File(lastPath).exists()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuranPdfScreen(
              pdfPath: lastPath,
              isAsset: false,
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleBookAction(PdfBookModel book) async {
    if (book.isDownloaded) {
      final path = await _pdfService.getFilePath(book.fileName);
      if (mounted) {
        _storage.write('last_pdf_path', path);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuranPdfScreen(
              pdfPath: path,
              isAsset: false,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _downloadProgress[book.id] = 0.0;
      });

      final success = await _pdfService.downloadPdf(
        book.url,
        book.fileName,
        onProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress[book.id] = received / total;
            });
          }
        },
      );

      if (success) {
        book.isDownloaded = true;
        setState(() {
          _downloadProgress.remove(book.id);
        });
      } else {
        setState(() {
          _downloadProgress.remove(book.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'مكتبة الكتب (PDF)',
        //     style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        //   ),
        //   centerTitle: true,
        // ),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            centerTitle: true,
            title: Text(
              "مكتبة المصحف الشريف",
              style: TextStyle(
                  fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),

        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.library_books_outlined,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'المكتبة فارغة حالياً',
                          style: TextStyle(
                  fontFamily: "cairo",
                              fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadBooks,
                          child: const Text('تحديث'),
                        )
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      final progress = _downloadProgress[book.id];
                      final isDownloading = progress != null;

                      return GestureDetector(
                        onTap: isDownloading
                            ? null
                            : () => _handleBookAction(book),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Book Cover
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.05),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15)),
                                  ),
                                  child: book.coverUrl != null &&
                                          book.coverUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(15)),
                                          child: Image.network(
                                            book.coverUrl!,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.picture_as_pdf,
                                                    color: Colors.red, size: 40),
                                              );
                                            },
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(Icons.picture_as_pdf,
                                              color: Colors.red, size: 40),
                                        ),
                                ),
                              ),
                              // Book Details
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: TextStyle(
                  fontFamily: "cairo",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            height: 1.2),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      if (isDownloading)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 4,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            const SizedBox(height: 2),
                                            Text('${(progress * 100).toInt()}%',
                                                style: const TextStyle(
                                                    fontSize: 9)),
                                          ],
                                        )
                                      else
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                book.isDownloaded
                                                    ? 'جاهز'
                                                    : 'تحميل',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: book.isDownloaded
                                                      ? Colors.green
                                                      : Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              book.isDownloaded
                                                  ? Icons.check_circle
                                                  : Icons.download_for_offline,
                                              size: 18,
                                              color: book.isDownloaded
                                                  ? Colors.green
                                                  : Colors.blue,
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
                      );
                    },
                  ),

      ),
    );
  }
}
