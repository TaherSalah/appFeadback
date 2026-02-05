import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pdf_book_model.dart';

import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PdfService {
  final Dio _dio = Dio();
  final _supabase = Supabase.instance.client;
  static const String _pdfBoxName = 'pdfBooksBox';

  // Fetch PDF books from Supabase with Caching
  Future<List<PdfBookModel>> fetchPdfBooks() async {
    final box = Hive.box<PdfBookModel>(_pdfBoxName);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = connectivityResult == ConnectivityResult.none;

      if (isOffline) {
        if (box.isNotEmpty) return box.values.toList();
        return [];
      }

      final response = await _supabase
          .from('pdf_books')
          .select()
          .order('created_at', ascending: false);

      final books = (response as List)
          .map((book) => PdfBookModel.fromJson(book))
          .toList();

      // Refresh cache
      await box.clear();
      await box.addAll(books);
      
      return books;
    } catch (e) {
      print('Error fetching PDF books: $e');
      if (box.isNotEmpty) return box.values.toList();
      return [];
    }
  }

  // Get the local path for storing PDFs
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the full file path for a specific PDF
  Future<String> getFilePath(String fileName) async {
    final path = await _localPath;
    return '$path/$fileName';
  }

  // Check if a PDF is already downloaded
  Future<bool> isPdfDownloaded(String fileName) async {
    final path = await getFilePath(fileName);
    return File(path).exists();
  }

  // Download a PDF
  Future<bool> downloadPdf(String url, String fileName,
      {Function(int, int)? onProgress}) async {
    try {
      final savePath = await getFilePath(fileName);
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
      return true;
    } catch (e) {
      KHelper.showError(message: "فشل التحميل: تأكد من الاتصال بالإنترنت");
      return false;
    }
  }
}
