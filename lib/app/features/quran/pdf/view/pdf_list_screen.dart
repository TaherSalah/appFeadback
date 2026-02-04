import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_book_model.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/pdf_service.dart';
import 'package:muslimdaily/app/features/quran/pdf/view/quran_pdf_screen.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';

class PdfListScreen extends StatefulWidget {
  const PdfListScreen({super.key});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  final PdfService _pdfService = PdfService();

  // Sample data - In a real app, this might come from an API or GitHub JSON
  final List<PdfBookModel> _books = [
    PdfBookModel(
      id: '1',
      title: 'مصحف المدينة المنورة',
      url: 'https://books.islamway.net/1/02_Mushaf_AlMadinah_M_549.pdf',
      fileName: 'mushaf_madinah_549.pdf',
    ),
    PdfBookModel(
      id: '2',
      title: 'مصحف الشمرلي',
      url: 'https://books.islamway.net/1/shamarly_v31.pdf',
      fileName: 'shamarly_v31.pdf',
    ),
    PdfBookModel(
      id: '3',
      title: ' مصحف المدينة المنورة الازرق',
      url: 'https://books.islamway.net/1/03_Mushaf_AlMadinah_N_B_549.pdf',
      fileName: '03_Mushaf_AlMadinah_N_B_549.pdf',
    ),
    PdfBookModel(
      id: '4',
      title: ' مصحف المدينة المنورة الاخضر',
      url: 'https://books.islamway.net/1/04_Mushaf_AlMadinah_N_G_549.pdf',
      fileName: '04_Mushaf_AlMadinah_N_G_549.pdf',
    ),
    PdfBookModel(
      id: '5',
      title: ' مصحف المدينة المنورة الجديد',
      url: 'https://books.islamway.net/1/05_Mushaf_AlMadinah_new_549.pdf',
      fileName: '05_Mushaf_AlMadinah_new_549.pdf',
    ),
    PdfBookModel(
      id: '6',
      title: ' مصحف المدينة المنورة القديم',
      url: 'https://books.islamway.net/1/06_Mushaf_AlMadinah_old_549.pdf',
      fileName: '06_Mushaf_AlMadinah_old_549.pdf',
    ),
    PdfBookModel(
      id: '6',
      title: ' مصحف المدينة المنورة القديم',
      url: 'https://download.alquranweb.com/printed-quran/masahif-almadinah-mojamma/almadinah-naskh-taliq.pdf',
      fileName: '06_Mushaf_AlMadinah_old_549.pdf',
    ),
  ];

  Map<String, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    _checkDownloads();
  }

  Future<void> _checkDownloads() async {
    for (var book in _books) {
      book.isDownloaded = await _pdfService.isPdfDownloaded(book.fileName);
    }
    if (mounted) setState(() {});
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مكتبة الكتب (PDF)',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final progress = _downloadProgress[book.id];
          final isDownloading = progress != null;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: isDownloading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress),
                        const SizedBox(height: 4),
                        Text('${(progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10)),
                      ],
                    )
                  : Text(book.isDownloaded ? 'جاهز للقراءة' : 'يحتاج للتحميل'),
              trailing: IconButton(
                onPressed: isDownloading ? null : () => _handleBookAction(book),
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
    );
  }
}
