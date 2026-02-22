import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/adhan_data.dart';
import 'dart:developer';

class AdhanAudioDownloader {
  static const String ADHAN_PATH_INDEX = 'adhan_path_index';
  static const String ADHAN_PATH_AUDIO = 'adhan_path_audio';
  static const String ADHAN_PATH_FAJIR_AUDIO = 'adhan_path_fajir_audio';

  Future<AdhanData> downloadAndUnzipAdhan(
    AdhanData adhanData, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final isIOS = Platform.isIOS || Platform.isMacOS;
    final downloadUrl =
        isIOS ? adhanData.urlIosAdhanZip : adhanData.urlAndroidAdhanZip;

    final filePath = await _downloadAndExtractFile(
      adhanData.index,
      downloadUrl,
      adhanData.adhanFileName,
      'audio',
      prefs,
      onReceiveProgress: onReceiveProgress,
    );

    return AdhanData(
      index: adhanData.index,
      adhanFileName: adhanData.adhanFileName,
      adhanLocalPath: adhanData.adhanLocalPath,
      adhanName: adhanData.adhanName,
      urlAndroidAdhanZip: adhanData.urlAndroidAdhanZip,
      urlIosAdhanZip: adhanData.urlIosAdhanZip,
      urlPlayAdhan: adhanData.urlPlayAdhan,
      androidFilePath: !isIOS ? filePath : null,
      iosFilePath: isIOS ? filePath : null,
      androidFajirFilePath:
          prefs.getString('${adhanData.index}$ADHAN_PATH_FAJIR_AUDIO'),
      adhanPath: prefs.getString('${adhanData.index}$ADHAN_PATH_AUDIO'),
    );
  }

  Future<String?> _downloadAndExtractFile(
    int index,
    String url,
    String fileName,
    String platform,
    SharedPreferences prefs, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: const Duration(seconds: 60),
        ),
        onReceiveProgress: onReceiveProgress,
      );

      final appDir = Platform.isAndroid
          ? await getApplicationDocumentsDirectory()
          : await getLibraryDirectory();

      final soundsDir = Directory(path.join(appDir.path, 'Sounds'));

      if (!soundsDir.existsSync()) {
        soundsDir.createSync(recursive: true);
      }

      final zipFilePath = path.join(soundsDir.path, '$fileName.zip');
      final zipFile = File(zipFilePath);

      await zipFile.writeAsBytes(response.data);

      final bytes = zipFile.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? extractedFilePath;
      String? extractedFilePathFajir;

      for (var file in archive) {
        if (file.isFile &&
            (file.name.endsWith('.wav') ||
                file.name.endsWith('.mp3') ||
                file.name.endsWith('.m4a'))) {
          final outputPath = path.join(soundsDir.path, platform);
          final extractedFile = File(path.join(outputPath, file.name));
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(file.content as List<int>);

          if (file.name.contains('fajir')) {
            extractedFilePathFajir = extractedFile.path;
            await prefs.setString(
                '${index}$ADHAN_PATH_FAJIR_AUDIO', extractedFile.path);
            log('extractedFilePathFajir: ${extractedFile.path}',
                name: 'AdhanAudioDownloader');
          } else {
            extractedFilePath = extractedFile.path;
            await prefs.setString(
                '${index}$ADHAN_PATH_AUDIO', extractedFile.path);
            log('extractedFilePath: ${extractedFile.path}',
                name: 'AdhanAudioDownloader');
          }
        }
      }

      await prefs.setInt(ADHAN_PATH_INDEX, index);

      await zipFile.delete();

      if (extractedFilePath == null || extractedFilePathFajir == null) {
        throw Exception('Failed to extract audio files.');
      }

      return extractedFilePathFajir;
    } catch (e) {
      log('Error downloading or extracting file: $e');
      return null;
    }
  }
}
