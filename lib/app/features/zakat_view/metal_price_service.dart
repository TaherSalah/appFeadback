import 'package:dio/dio.dart';
import 'dart:developer';

class MetalPriceService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches Gold (24k) and Silver prices per gram in USD.
  /// Returns a map with 'gold' and 'silver' keys.
  Future<Map<String, double>> fetchPricesInUSD() async {
    try {
      // Using a publicly accessible gold API source
      // Gold-API.com provides free access to current prices
      final goldResponse = await _dio.get('https://api.gold-api.com/price/XAU');
      final silverResponse = await _dio.get('https://api.gold-api.com/price/XAG');

      if (goldResponse.statusCode == 200 && silverResponse.statusCode == 200) {
        // Results are usually per ounce
        double goldPriceOunce = (goldResponse.data['price'] as num).toDouble();
        double silverPriceOunce = (silverResponse.data['price'] as num).toDouble();

        // 1 Ounce = 31.1035 Grams
        return {
          'gold': goldPriceOunce / 31.1035,
          'silver': silverPriceOunce / 31.1035,
        };
      } else {
        throw Exception("Failed to fetch prices: ${goldResponse.statusCode}");
      }
    } on DioException catch (e) {
      log("Dio Error fetching metal prices: $e");
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("لا يوجد اتصال بالإنترنت أو الخادم غير متاح حالياً.");
      }
      throw Exception("حدث خطأ أثناء جلب الأسعار. يرجى المحاولة لاحقاً.");
    } catch (e) {
      log("Unknown Error fetching metal prices: $e");
      throw Exception("فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.");
    }
  }

  /// Fetches exchange rate for USD to target currency
  Future<double> fetchExchangeRate(String targetCurrency) async {
    if (targetCurrency == "USD" || targetCurrency == r"$") return 1.0;
    
    try {
      // Using a free exchange rate API
      final response = await _dio.get('https://open.er-api.com/v6/latest/USD');
      if (response.statusCode == 200) {
        final rates = response.data['rates'] as Map<String, dynamic>;
        // Map common symbols to currency codes if necessary
        String code = targetCurrency;
        if (code == "ج.م" || code == "EGP") code = "EGP";
        if (code == "ر.س" || code == "SAR") code = "SAR";
        if (code == "د.إ" || code == "AED") code = "AED";
        // ... add more as needed

        return (rates[code] as num?)?.toDouble() ?? 1.0;
      }
      return 1.0;
    } catch (e) {
      log("Error fetching exchange rate: $e");
      return 1.0; // Fallback to 1.0 if exchange rate fails
    }
  }
}
