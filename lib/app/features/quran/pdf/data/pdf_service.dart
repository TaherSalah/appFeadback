import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';

class PdfService {
  final Dio _dio = Dio();

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
