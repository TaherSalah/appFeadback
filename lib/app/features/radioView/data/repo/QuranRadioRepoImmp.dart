import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:muslimdaily/app/features/radioView/data/modal/QuranRadioModel.dart';

import '../../../../core/apis_services/api_client/dio_client_helper.dart';
import '../../../../core/apis_services/api_client/endpoints.dart';
import '../../../../core/utils/services_locator.dart';
import 'QuranRadioRepo.dart';
import '../../../../core/services/content_service.dart';

class QuranRadioRepoImmp implements QuranRadioRepo {
  @override
  Future<Either<dynamic, QuranRadioModel>> getQuranRadioData() async {
    // 1. Try fetching from Supabase (Control Panel)
    try {
      final remoteStations = await ContentService().getRadioStations();
      if (remoteStations.isNotEmpty) {
        final radios = remoteStations.map((m) {
          return Radio(
            id: m['id'] is int ? m['id'] : (m['id']?.toString().hashCode ?? 0),
            name: m['name'] ?? 'Unknown',
            url: m['stream_url'] ?? '',
            recentDate: DateTime.now().toIso8601String(),
          );
        }).toList();
        return right(QuranRadioModel(radios: radios));
      }
    } catch (e) {
      print('Supabase Radio fetch failed, falling back to API: $e');
    }

    // 2. Fallback to external API
    Future<Response<dynamic>> func = Di.dioClient.get(
      KEndPoints.getQuranRadioData,
    );
    final result = await ApiClientHelper.responseToModel(func: func);
    return result.fold((l) => left(l), (r) {
      return right(QuranRadioModel.fromJson(r));
    });
  }
}
