



import 'package:dio/dio.dart';
import 'package:muslimdaily/main.dart';

import '../model/all_azkar_modal.dart';
import '../model/azkar_massa_model.dart';

class AzkarRemoteServices {
  static final Dio dio = Dio();

  fetchAzkarData(String azkarType) async {
    try {
      final responce =
          await dio.get('https://ahegazy.github.io/muslimKit/json/$azkarType');
      if (responce.statusCode == 200) {
        List<dynamic> jsonData = responce.data['content'];
        return jsonData.map((item) => Content.fromJson(item)).toList();
      }
      throw Exception('Error To Catch azkkkar data');
    } catch (error) {
      logger.e(error);
    }
  }
  fetchAzkar() async {
    try {
      final responce =
          await dio.get('https://www.hisnmuslim.com/api/ar/27.json');
      if (responce.statusCode == 200) {
        List<dynamic> jsonData = responce.data['أذكار الصباح والمساء'];
        return jsonData.map((item) => Empty.fromJson(item)).toList();
      }
      throw Exception('Error To Catch azkkkar data');
    } catch (error) {
      logger.e(error);
    }
  }
}
