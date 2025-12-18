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

    // تحميل الخط العربي
    final fontData =
        await rootBundle.load("assets/fonts/cairo/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: ttf),
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(ttf, stats),
          pw.SizedBox(height: 20),
          _buildStatsSummary(ttf, stats),
          pw.SizedBox(height: 20),
          _buildDonationsTable(ttf, donations),
        ],
      ),
    );

    // عرض معاينة أو حفظ
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'تقرير_الصدقات_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildHeader(pw.Font font, CharityStats stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'تقرير الصدقات والتبرعات 🤲',
          style: pw.TextStyle(
              font: font, fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'تطبيق رفيق المسلم - متتبع الصدقات الذكي',
          style:
              pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(),
        pw.Text(
          'تاريخ التقرير: ${intl.DateFormat('yyyy/MM/dd', 'ar').format(DateTime.now())}',
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildStatsSummary(pw.Font font, CharityStats stats) {
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
                  font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statItem(font, 'إجمالي الصدقات:',
                  '${stats.totalAllTime.toStringAsFixed(2)} جنيه'),
              _statItem(font, 'عدد التبرعات:', '${stats.donationsCount}'),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _statItem(font, 'الشهر الحالي:',
                  '${stats.totalThisMonth.toStringAsFixed(2)} جنيه'),
              _statItem(font, 'أطول سلسلة:', '${stats.longestStreak} يوم'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _statItem(pw.Font font, String label, String value) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(width: 5),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildDonationsTable(
      pw.Font font, List<CharityDonation> donations) {
    return pw.TableHelper.fromTextArray(
      context: null, // context is optional in MultiPage usually
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
