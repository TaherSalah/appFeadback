import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/apis_services/api_client/dio_client_helper.dart';
import '../../../../core/apis_services/api_client/endpoints.dart';
import '../../../../core/errors/failuers.dart';
import '../../../../core/utils/services_locator.dart';
import '../../../categories/data/modal/all_hadith_categories_modal.dart';
import '../modal/hadith_details_modal.dart';
import 'hadith_details_repo.dart';

class HadithDetailsRepoImmp implements HadithDetailsRepo {
  @override
  Future<Either<dynamic, HadithDetailsModal>> getHadithDetails(
      {dynamic hadithId}) async {
    // TODO: implement getHadithDetails
    Future<Response<dynamic>> func = Di.dioClient.get(
      KEndPoints.getHadithDetails(hadithId: hadithId),
    );
    final result = await ApiClientHelper.responseToModel(func: func);
    return result.fold((l) => left(l), (r) {
      return right(HadithDetailsModal.fromJson(r));
    });
  }

  @override
  Future<Either<dynamic, List<HadithDetailsModal>>> getHadithDetailsList(
      {hadithId}) async {
    try {
      final response = await Di.dioClient
          .getRequest(url: KEndPoints.getHadithDetails(hadithId: hadithId));

      // Explicitly cast the response to Map<String, dynamic>
      if (response is Map<String, dynamic>) {
        // Map the single response object to HadithDetailsModal and wrap it in a list
        List<HadithDetailsModal> hadithDetailsList = [
          HadithDetailsModal.fromJson(response)
        ];
        return Right(hadithDetailsList); // Return the list
      } else {
        return const Left("Unexpected response format");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<KFailure, List<AllHadithCategorieModal>>> getMoreHadith(
      {hadithId}) async {
    try {
      // TODO: implement getMoreHadith
      final response = await Di.dioClient.getRequest(
          url: KEndPoints.getMoreHadithInDetails(categoryId: hadithId));

      // Explicitly cast the response to Map<String, dynamic>
      if (response is Map<String, dynamic>) {
        // Map the single response object to HadithDetailsModal and wrap it in a list
        List<AllHadithCategorieModal> hadithDetailsList = [
          AllHadithCategorieModal.fromJson(response)
        ];
        return Right(hadithDetailsList); // Return the list
      } else {
        return const Left(KFailure.error('error getting more hadith'));
      }
    } catch (e) {
      return Left(KFailure.error(e.toString()));
    }
  }
}
