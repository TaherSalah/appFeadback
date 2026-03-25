import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  print('Testing XAU...');
  try {
    final goldResponse = await dio.get('https://api.gold-api.com/price/XAU');
    print('XAU StatusCode: \${goldResponse.statusCode}');
    print('XAU Data: \${goldResponse.data}');
  } on DioException catch (e) {
    print('XAU Dio Error: \${e.message} | \${e.response?.statusCode} | \${e.response?.data}');
  } catch (e) {
    print('XAU Unknown Error: \$e');
  }

  print('Testing ER-API...');
  try {
    final erResponse = await dio.get('https://open.er-api.com/v6/latest/USD');
    print('ER StatusCode: \${erResponse.statusCode}');
  } on DioException catch (e) {
    print('ER Dio Error: \${e.message}');
  }
}
