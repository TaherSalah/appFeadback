import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_book_model.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_service.dart';
import 'package:muslimdaily/app/features/quran/pdf/view/quran_pdf_screen.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final canAccess = await FeatureGuardService().canAccess(context, 'pdf_library');
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        KHelper.showError(message: "فشل تحميل قائمة الكتب");
      }
    }
  }

  Future<void> _handleBookAction(PdfBookModel book) async {
    if (book.isDownloaded) {
      final path = await _pdfService.getFilePath(book.fileName);
      if (mounted) {
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
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
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
                        const Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'المكتبة فارغة حالياً',
                          style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadBooks,
                          child: const Text('تحديث'),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      final progress = _downloadProgress[book.id];
                      final isDownloading = progress != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          ),
                          title: Text(
                            book.title,
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.description,
                                  style: GoogleFonts.cairo(
                                      fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                if (isDownloading)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(value: progress),
                                      const SizedBox(height: 4),
                                      Text('${(progress * 100).toInt()}%',
                                          style: const TextStyle(fontSize: 10)),
                                    ],
                                  )
                                else
                                  Text(
                                    book.isDownloaded ? 'جاهز للقراءة' : 'يحتاج للتحميل',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          book.isDownloaded ? Colors.green : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: isDownloading
                                ? null
                                : () => _handleBookAction(book),
                            icon: Icon(
                              book.isDownloaded ? Icons.menu_book : Icons.download,
                              color: book.isDownloaded ? Colors.green : Colors.blue,
                            ),
                          ),
                          onTap: isDownloading ? null : () => _handleBookAction(book),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
