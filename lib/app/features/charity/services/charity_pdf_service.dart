import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/charity_models.dart';
import 'package:intl/intl.dart' as intl;

class CharityPdfService {
  /// توليد تقرير تبرعات بصيغة PDF
  static Future<void> generateDonationsReport(
    List<CharityDonation> donations,
    CharityStats stats,
  ) async {
    final pdf = pw.Document();

    // Load Fonts
    final fontData =
        await rootBundle.load("assets/fonts/cairo/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData =
        await rootBundle.load("assets/fonts/cairo/Cairo-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    // Load Images
    final logoImage =
        await imageFromAssetBundle('assets/images/logoApp.png');
    final appStoreImage =
        await imageFromAssetBundle('assets/images/app-store.png');
    final playStoreImage =
        await imageFromAssetBundle('assets/images/logoApp.png');
    final huaweiImage = await imageFromAssetBundle('assets/images/huawei.png');

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(ttf, ttfBold, logoImage),
        footer: (context) =>
            _buildFooter(appStoreImage, playStoreImage, huaweiImage),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildStatsSummary(ttf, ttfBold, stats),
          pw.SizedBox(height: 20),
          _buildDonationsTable(ttf, donations),
        ],
      ),
    );

    // Save/Share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'تقرير_الصدقات_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildHeader(
      pw.Font font, pw.Font boldFont, pw.ImageProvider logoImage) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.black,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("تقرير الصدقات والتبرعات",
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      font: boldFont,
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold)),
              pw.Text("رفيق المسلم اليومي",
                  style: pw.TextStyle(
                      color: PdfColors.white, font: font, fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text(
                  "تاريخ التقرير: ${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                  style: pw.TextStyle(
                      color: PdfColors.amber200, font: font, fontSize: 12)),
            ],
          ),
          pw.Container(
            height: 90,
            width: 90,
            child: pw.Image(logoImage),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.ImageProvider appStore,
      pw.ImageProvider playStore, pw.ImageProvider huawei) {
    return pw.Column(children: [
      pw.Divider(),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
        pw.Text("حمل التطبيق الآن:", style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(width: 10),
        pw.Container(height: 20, child: pw.Image(playStore)),
        pw.SizedBox(width: 10),
        pw.Container(height: 20, child: pw.Image(appStore)),
        pw.SizedBox(width: 10),
        pw.Container(height: 20, child: pw.Image(huawei)),
      ]),
      pw.SizedBox(height: 5),
      pw.Text(
        "هذا التقرير صادر إلكترونياً من تطبيق رفيق المسلم اليومي. تقبل الله طاعاتكم.",
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        textAlign: pw.TextAlign.center,
      ),
    ]);
  }

  static pw.Widget _buildStatsSummary(
      pw.Font font, pw.Font boldFont, CharityStats stats) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ملخص الإحصائيات:',
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statItem(font, boldFont, 'إجمالي الصدقات:',
                  '${stats.totalAllTime.toStringAsFixed(2)} جنيه'),
              _statItem(
                  font, boldFont, 'عدد التبرعات:', '${stats.donationsCount}'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statItem(font, boldFont, 'الشهر الحالي:',
                  '${stats.totalThisMonth.toStringAsFixed(2)} جنيه'),
              _statItem(
                  font, boldFont, 'أطول سلسلة:', '${stats.longestStreak} يوم'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _statItem(
      pw.Font font, pw.Font boldFont, String label, String value) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildDonationsTable(
      pw.Font font, List<CharityDonation> donations) {
    return pw.TableHelper.fromTextArray(
      context: null,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
          font: font, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      cellStyle: pw.TextStyle(font: font),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellAlignment: pw.Alignment.center,
      columnWidths: {
        0: const pw.FixedColumnWidth(80), // التاريخ
        1: const pw.FixedColumnWidth(60), // المبلغ
        2: const pw.FixedColumnWidth(80), // الفئة
        3: const pw.FixedColumnWidth(120), // ملاحظات
      },
      headers: ['التاريخ', 'المبلغ', 'الفئة', 'ملاحظات'],
      data: donations.map((d) {
        return [
          intl.DateFormat('yyyy/MM/dd').format(d.date),
          '${d.amount}',
          d.category.arabicName,
          d.notes ?? '-',
        ];
      }).toList(),
    );
  }
}
