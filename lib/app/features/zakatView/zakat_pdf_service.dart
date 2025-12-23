import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;

class ZakatPdfService {
  static Future<void> generateAndPrint({
    required double totalWealth,
    required double totalZakat,
    required double nisabValue,
    required String currencySymbol,
    required bool isHijri,
    required bool reachedNisab,
    
    // Breakdowns
    double? money,
    double? gold,
    double? silver,
    double? assets,
    double? realEstate,
    double? crops,
    String? cattleDetails,
    double? fitrTotal,
  }) async {
    final pdf = pw.Document();

    // Load Arabic Font (Use a standard font helper or load from assets if possible)
    // For simplicity in this step, we will use a built-in font or try to load one.
    // In a real app, you MUST load a TTF font that supports Arabic.
    // We will assume "Arial" or similar is available or use `PdfGoogleFonts`.
    // Since we can't easily fetch internet fonts here without risk, we'll try to use a standard font
    // or if the app has assets, use them. The app HAS assets: assets/fonts/cairo/Cairo-Regular.ttf
    
    final fontData = await rootBundle.load("assets/fonts/cairo/Cairo-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load("assets/fonts/cairo/Cairo-Bold.ttf");
    final ttfBold = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: ttf,
          bold: ttfBold,
        ),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green800,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("تقرير زكاة المال",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(" تطبيق رفيق المسلم اليومي",
                            style: pw.TextStyle(
                                color: PdfColors.white, fontSize: 14)),
                      ],
                    ),
                    pw.PdfLogo(), // Placeholder logo
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Date & Status
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      "التاريخ: ${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}",
                      style: const pw.TextStyle(fontSize: 14)),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: reachedNisab ? PdfColors.green100 : PdfColors.red100,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      reachedNisab ? "بلغ النصاب (تجب الزكاة)" : "لم يبلغ النصاب",
                      style: pw.TextStyle(
                        color: reachedNisab ? PdfColors.green900 : PdfColors.red900,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Summary Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                   _buildTableRow("العملة المستخدمة", currencySymbol, ttfBold),
                   _buildTableRow("قيمة النصاب الشرعي", "${_format(nisabValue)} $currencySymbol", ttfBold),
                   _buildTableRow("نوع الحول", isHijri ? "هجري (2.5%)" : "ميلادي (2.577%)", ttfBold),
                   _buildTableRow("إجمالي الثروة المحسوبة", "${_format(totalWealth)} $currencySymbol", ttfBold, isHighlight: true),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text("تفاصيل الممتلكات والزكاة المستحقة:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Breakdown Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                       pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("البند", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                       pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("القيمة (زكاة)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ]
                  ),
                  if ((money ?? 0) > 0) _buildLineItem("زكاة المال السائل", money!, currencySymbol),
                  if ((gold ?? 0) > 0) _buildLineItem("زكاة الذهب", gold!, currencySymbol),
                  if ((silver ?? 0) > 0) _buildLineItem("زكاة الفضة", silver!, currencySymbol),
                  if ((assets ?? 0) > 0) _buildLineItem("زكاة الأصول وعروض التجارة", assets!, currencySymbol),
                  if ((realEstate ?? 0) > 0) _buildLineItem("زكاة العقارات", realEstate!, currencySymbol),
                  if ((crops ?? 0) > 0) _buildLineItem("زكاة الزروع", crops!, currencySymbol),
                  if ((fitrTotal ?? 0) > 0) _buildLineItem("زكاة الفطر", fitrTotal!, currencySymbol),
                ],
              ),
              
              if (cattleDetails != null && cattleDetails.isNotEmpty) ...[
                 pw.SizedBox(height: 20),
                 pw.Text("زكاة الأنعام:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                 pw.Container(
                   width: double.infinity,
                   padding: const pw.EdgeInsets.all(10),
                   decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400)),
                   child: pw.Text(cattleDetails)
                 ),
              ],

              pw.SizedBox(height: 30),

              // Total Zakat Box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text("إجمالي الزكاة المستحقة", style: pw.TextStyle(fontSize: 16, color: PdfColors.green900)),
                    pw.SizedBox(height: 5),
                    pw.Text("${_format(totalZakat)} $currencySymbol", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                "هذا التقرير صادر إلكترونياً من تطبيق رفيق المسلم. يُنصح بمراجعة أهل العلم للتأكد من التفاصيل الفقهية الدقيقة.",
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // Save/Share
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '_تقرير زكاتك _ رفيق المسلم اليومي ${intl.DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.TableRow _buildTableRow(String label, String value, pw.Font font, {bool isHighlight = false}) {
    return pw.TableRow(
      decoration: isHighlight ? const pw.BoxDecoration(color: PdfColors.green50) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        ),

      ],
    );
  }

  static pw.TableRow _buildLineItem(String label, double value, String symbol) {
     return pw.TableRow(
      children: [

        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text("${_format(value)} $symbol", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  static String _format(double value) {
    return intl.NumberFormat("#,##0.##", "en_US").format(value);
  }
}
