import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetalPriceService {
  static const String _cacheKeyGold = 'cached_gold_price_usd';
  static const String _cacheKeySilver = 'cached_silver_price_usd';
  static const String _cacheKeyRates = 'cached_exchange_rates_json';
  static const String _cacheKeyTimestamp = 'cached_prices_timestamp';
  static const String _cacheKeyRatesTimestamp = 'cached_rates_timestamp';

  // Cache duration: 1 hour
  static const int _cacheDurationMs = 60 * 60 * 1000;

  // 1 Troy Ounce in Grams
  static const double _troyOunceInGrams = 31.1035;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
    },
  ));

  /// Fetches Gold (24k) and Silver prices per gram in USD.
  /// Uses multiple API sources as fallback, with 1-hour caching.
  Future<Map<String, double>> fetchPricesInUSD() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedTs = prefs.getInt(_cacheKeyTimestamp) ?? 0;
    final cacheAge = now - cachedTs;
    final isCacheValid = cacheAge < _cacheDurationMs &&
        prefs.containsKey(_cacheKeyGold) &&
        prefs.containsKey(_cacheKeySilver);

    if (isCacheValid) {
      log('MetalPriceService: Using cached prices (age: ${(cacheAge / 60000).toStringAsFixed(1)} min)');
      return {
        'gold': prefs.getDouble(_cacheKeyGold)!,
        'silver': prefs.getDouble(_cacheKeySilver)!,
      };
    }

    // Try primary source first, then fallback
    try {
      return await _fetchFromGoldApi(prefs, now);
    } catch (primaryError) {
      log('MetalPriceService: Primary API failed ($primaryError), trying Yahoo Finance...');
      try {
        return await _fetchFromYahooFinance(prefs, now);
      } catch (fallbackError) {
        log('MetalPriceService: Yahoo Finance also failed ($fallbackError)');

        // Return stale cache as last resort
        if (prefs.containsKey(_cacheKeyGold) &&
            prefs.containsKey(_cacheKeySilver)) {
          log('MetalPriceService: Returning stale cache.');
          return {
            'gold': prefs.getDouble(_cacheKeyGold)!,
            'silver': prefs.getDouble(_cacheKeySilver)!,
          };
        }

        // Re-throw a user-friendly error
        throw Exception(primaryError
            .toString()
            .replaceAll('Exception: ', ''));
      }
    }
  }

  /// Primary: Gold-API.com
  Future<Map<String, double>> _fetchFromGoldApi(
      SharedPreferences prefs, int now) async {
    final goldRes = await _dio.get('https://api.gold-api.com/price/XAU');
    await Future.delayed(const Duration(milliseconds: 400));
    final silverRes = await _dio.get('https://api.gold-api.com/price/XAG');

    if (goldRes.statusCode == 200 && silverRes.statusCode == 200) {
      var gData = goldRes.data;
      if (gData is String) gData = jsonDecode(gData);
      var sData = silverRes.data;
      if (sData is String) sData = jsonDecode(sData);

      final result = {
        'gold': (gData['price'] as num).toDouble() / _troyOunceInGrams,
        'silver': (sData['price'] as num).toDouble() / _troyOunceInGrams,
      };
      await _cacheMetalPrices(prefs, now, result);
      return result;
    }

    if (goldRes.statusCode == 429) {
      throw Exception('تم تجاوز الحد المسموح للطلبات. المحاولة من مصدر آخر...');
    }
    throw Exception('Failed with status ${goldRes.statusCode}');
  }

  /// Fallback: Yahoo Finance (GC=F gold futures, SI=F silver futures)
  Future<Map<String, double>> _fetchFromYahooFinance(
      SharedPreferences prefs, int now) async {
    final goldRes = await _dio.get(
        'https://query1.finance.yahoo.com/v8/finance/chart/GC%3DF?interval=1d&range=1d');
    await Future.delayed(const Duration(milliseconds: 400));
    final silverRes = await _dio.get(
        'https://query1.finance.yahoo.com/v8/finance/chart/SI%3DF?interval=1d&range=1d');

    double goldOunce = _parseYahooPrice(goldRes.data);
    double silverOunce = _parseYahooPrice(silverRes.data);

    if (goldOunce <= 0 || silverOunce <= 0) {
      throw Exception('Yahoo Finance returned invalid prices');
    }

    final result = {
      'gold': goldOunce / _troyOunceInGrams,
      'silver': silverOunce / _troyOunceInGrams,
    };
    await _cacheMetalPrices(prefs, now, result);
    return result;
  }

  double _parseYahooPrice(dynamic rawData) {
    try {
      var data = rawData;
      if (data is String) data = jsonDecode(data);
      // Yahoo Finance chart response structure
      final meta = data['chart']['result'][0]['meta'];
      return (meta['regularMarketPrice'] as num).toDouble();
    } catch (e) {
      log('Yahoo parse error: $e');
      return 0.0;
    }
  }

  Future<void> _cacheMetalPrices(
      SharedPreferences prefs, int now, Map<String, double> result) async {
    await prefs.setDouble(_cacheKeyGold, result['gold']!);
    await prefs.setDouble(_cacheKeySilver, result['silver']!);
    await prefs.setInt(_cacheKeyTimestamp, now);
  }

  /// Fetches exchange rate for USD to target currency, with 1-hour caching.
  Future<double> fetchExchangeRate(String targetCurrency) async {
    if (targetCurrency == 'USD' || targetCurrency == r'$') return 1.0;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedTs = prefs.getInt(_cacheKeyRatesTimestamp) ?? 0;
    final isCacheValid =
        (now - cachedTs) < _cacheDurationMs && prefs.containsKey(_cacheKeyRates);

    if (isCacheValid) {
      return _rateFromCache(prefs, targetCurrency);
    }

    try {
      final response = await _dio.get('https://open.er-api.com/v6/latest/USD');
      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        final rates = data['rates'] as Map<String, dynamic>;

        await prefs.setString(_cacheKeyRates, jsonEncode(rates));
        await prefs.setInt(_cacheKeyRatesTimestamp, now);

        final code = _resolveCurrencyCode(targetCurrency);
        return (rates[code] as num?)?.toDouble() ?? 1.0;
      }
      return 1.0;
    } catch (e) {
      log('Error fetching exchange rate: $e');
      if (prefs.containsKey(_cacheKeyRates)) {
        return _rateFromCache(prefs, targetCurrency);
      }
      return 1.0;
    }
  }

  double _rateFromCache(SharedPreferences prefs, String targetCurrency) {
    try {
      final Map<String, dynamic> rates =
          jsonDecode(prefs.getString(_cacheKeyRates)!);
      final code = _resolveCurrencyCode(targetCurrency);
      return (rates[code] as num?)?.toDouble() ?? 1.0;
    } catch (_) {
      return 1.0;
    }
  }

  String _resolveCurrencyCode(String input) {
    const map = {
      'ج.م': 'EGP', 'EGP': 'EGP',
      'ر.س': 'SAR', 'SAR': 'SAR',
      'د.إ': 'AED', 'AED': 'AED',
      'د.ك': 'KWD', 'KWD': 'KWD',
      'ر.ق': 'QAR', 'QAR': 'QAR',
      'د.ب': 'BHD', 'BHD': 'BHD',
      'ر.ع': 'OMR', 'OMR': 'OMR',
      'د.أ': 'JOD', 'JOD': 'JOD',
      '₺': 'TRY', 'TRY': 'TRY',
      'د.ج': 'DZD', 'DZD': 'DZD',
      'د.م': 'MAD', 'MAD': 'MAD',
      'د.ل': 'LYD', 'LYD': 'LYD',
      'د.ت': 'TND', 'TND': 'TND',
      'د.ع': 'IQD', 'IQD': 'IQD',
      'ل.ل': 'LBP', 'LBP': 'LBP',
      'ل.س': 'SYP', 'SYP': 'SYP',
      'ر.ي': 'YER', 'YER': 'YER',
      'ج.س': 'SDG', 'SDG': 'SDG',
      '€': 'EUR', 'EUR': 'EUR',
      '£': 'GBP', 'GBP': 'GBP',
    };
    return map[input] ?? input;
  }
}
