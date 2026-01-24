import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // Optional for easy printing/sharing of PDF
import 'package:printing/printing.dart'; // Optional for easy printing/sharing of PDF
// Fixing imports:
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

import '../../../core/widgets/KLoading.dart';

class KhatmahCertificateScreen extends StatefulWidget {
  final String userName;
  final int contributionCount;
  final String campaignTitle; // e.g. "ختمة شهر رمضان"
  final DateTime date;

  const KhatmahCertificateScreen({
    super.key,
    required this.userName,
    required this.contributionCount,
    required this.campaignTitle,
    required this.date,
  });

  @override
  State<KhatmahCertificateScreen> createState() => _KhatmahCertificateScreenState();
}

class _KhatmahCertificateScreenState extends State<KhatmahCertificateScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('شهادة الإنجاز', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: _buildCertificateUI(context),
              ),
              const SizedBox(height: 30),
              if (_isGenerating)
                KLoading.progressIOSIndicator(context: context)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _captureAndShareImage(context),
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      label: Text('مشاركة صورة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () => _generateAndSharePdf(context),
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                      label: Text('حفظ كملف PDF', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateUI(BuildContext context) {
    // A premium certificate design
    return AspectRatio(
      aspectRatio: 1.414, // A4 aspect ratio (Landscape)
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600), // Max A4-ish ratio width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        border: Border.all(color: const Color(0xFFD4AF37), width: 8), // Gold border
      ),
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Column(
              children: [
                Icon(Icons.workspace_premium_rounded, size: 60, color: KColors.primaryColor),
                const SizedBox(height: 10),
                Text(
                  'شهادة شكر وتقدير',
                  style: GoogleFonts.amiri( // Amiri is good for certificates
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD4AF37), // Gold
                  ),
                ),
                Text(
                  'CERTIFICATE OF APPRECIATION',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            // Body
            Column(
              children: [
                Text(
                  'يسر أسرة تطبيق رفيق المسلم أن تتقدم بخالص الشكر',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.userName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'على مشاركته الفعالة في الختمة الجماعية',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '"${widget.campaignTitle}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: KColors.primaryColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'حيث ساهم بإتمام قراءة ${widget.contributionCount} ورد من كتاب الله',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Text(
                  '«خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                ),
              ],
            ),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التاريخ', style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey)),
                    Text('${widget.date.year}/${widget.date.month}/${widget.date.day}', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ],
                ),
                // Logo or Signature placeholder
                 Column(
                  children: [
                    Image.asset('assets/images/logoApp.png', height: 40, errorBuilder: (_,__,___) => const Icon(Icons.mosque)),
                    Text('تطبيق رفيق المسلم', style: GoogleFonts.cairo(fontSize: 8, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _captureAndShareImage(BuildContext context) async {
    setState(() => _isGenerating = true);
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
         await Future.delayed(const Duration(milliseconds: 20)); // Wait a bit
         boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
         if (boundary == null) return;
      }

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/certificate_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'شهادتي من تطبيق رفيق المسلم 📜✨');
    } catch (e) {
      KHelper.showError(message: 'حدث خطأ أثناء تصدير الصورة: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateAndSharePdf(BuildContext context) async {
     setState(() => _isGenerating = true);
     try {
       // 1. Create PDF Document
       final pdf = pw.Document();
       
       // 2. Load Fonts (Loading Google Fonts for PDF is async)
       // We use standard fonts or load custom ttf if available in assets for better Arabic support
       // For simplicity, we assume we might need a font that supports Arabic. 
       // PdfGoogleFonts is a helper from `printing` package.
       final font = await PdfGoogleFonts.amiriRegular();
       final fontBold = await PdfGoogleFonts.amiriBold();

       // 3. Define Page Design
       pdf.addPage(
         pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            build: (pw.Context context) {
              return pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.amber700, width: 5),
                ),
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('شهادة شكر وتقدير', style: pw.TextStyle(font: fontBold, fontSize: 32, color: PdfColors.amber700), textDirection: pw.TextDirection.rtl),
                        pw.Text('Certificate of Appreciation', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('تتقدم أسرة تطبيق رفيق المسلم بخالص الشكر والتقدير إلى', style: pw.TextStyle(font: font, fontSize: 18), textDirection: pw.TextDirection.rtl),
                        pw.SizedBox(height: 10),
                        pw.Text(widget.userName, style: pw.TextStyle(font: fontBold, fontSize: 26), textDirection: pw.TextDirection.rtl),
                        pw.SizedBox(height: 10),
                        pw.Text('لمشاركته في الختمة الجماعية "${widget.campaignTitle}"', style: pw.TextStyle(font: font, fontSize: 18), textDirection: pw.TextDirection.rtl),
                        pw.Text('وإتمامه قراءة ${widget.contributionCount} ورد', style: pw.TextStyle(font: font, fontSize: 18, color: PdfColors.green700), textDirection: pw.TextDirection.rtl),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('التاريخ', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey), textDirection: pw.TextDirection.rtl),
                            pw.Text('${widget.date.year}/${widget.date.month}/${widget.date.day}', style: pw.TextStyle(font: font, fontSize: 12), textDirection: pw.TextDirection.rtl),
                          ],
                        ),
                        pw.Text('تطبيق رفيق المسلم', style: pw.TextStyle(font: font, fontSize: 12), textDirection: pw.TextDirection.rtl),
                      ],
                    ),
                  ],
                ),
              );
            },
         ),
       );

       // 4. Save and Share
       final output = await pdf.save();
       final tempDir = await getTemporaryDirectory();
       final file = await File('${tempDir.path}/certificate_${DateTime.now().millisecondsSinceEpoch}.pdf').create();
       await file.writeAsBytes(output);
       
       await Share.shareXFiles([XFile(file.path)], text: 'نسخة PDF من شهادتي 📜');
       
     } catch (e) {
       print(e);
       KHelper.showError(message: 'حدث خطأ أثناء تصدير PDF: $e');
     } finally {
        if (mounted) setState(() => _isGenerating = false);
     }
  }
}
