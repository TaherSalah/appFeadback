import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/apis_services/api_client/dio_client_helper.dart';
import '../../../../core/apis_services/api_client/endpoints.dart';
import '../../../../core/utils/services_locator.dart';
import '../../../radioView/data/modal/QuranRadioModel.dart';
import 'QuranRadioRepo.dart';

class QuranRadioRepoImmp implements QuranRadioRepo {


  @override
  Future<Either<dynamic, QuranRadioModel>> getQuranRadioData() async {
    // TODO: implement getQuranRadioData
    Future<Response<dynamic>> func = Di.dioClient.get(
      KEndPoints.getQuranRadioData,
    );
    final result = await ApiClientHelper.responseToModel(func: func);
    return result.fold((l) => left(l), (r) {
      return right(QuranRadioModel.fromJson(r));
    });
  }

}
