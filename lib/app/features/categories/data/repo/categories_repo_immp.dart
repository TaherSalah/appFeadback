import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/apis_services/api_client/dio_client_helper.dart';
import '../../../../core/apis_services/api_client/endpoints.dart';
import '../../../../core/errors/failuers.dart';
import '../../../../core/utils/services_locator.dart';
import '../../../hadithDetails/data/modal/hadith_search_modal.dart';
import '../modal/all_hadith_categories_modal.dart';
import '../modal/categories_modal.dart';
import 'categories_repo.dart';

class CategoriesRepoImmp implements CategoriesRepo {
  @override
  Future<Either<dynamic, List<CategoriesModal>>> getAllCategories() async {
    try {
      final response =
          await Di.dioClient.getRequest(url: KEndPoints.getCategories);

      // Check if the response is a List and map each item to CategoriesModal
      if (response is List) {
        // Deserialize each item into CategoriesModal
        List<CategoriesModal> categoriesList =
            response.map((item) => CategoriesModal.fromJson(item)).toList();
        return Right(categoriesList);
      } else {
        return const Left("Unexpected response format");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<KFailure, AllHadithCategorieModal>> getAllHadithFromCategories(
      {dynamic categoriesId}) async {
    // TODO: implement getAllHadithFromCategories
    Future<Response<dynamic>> func = Di.dioClient.get(
      KEndPoints.getHadithFromCategories(categoryId: categoriesId),
    );
    final result = await ApiClientHelper.responseToModel(func: func);
    return result.fold((l) => left(l), (r) {
      return right(AllHadithCategorieModal.fromJson(r));
    });
  }

  @override
  Future<Either<dynamic, SearchResultModal>> getHadithSearch(
      {dynamic searchWord}) async {
    // TODO: implement getHadithSearch
    Future<Response<dynamic>> func =
        Di.dioClient.get(KEndPoints.getHadithSearch(searchWord: searchWord));
    final result = await ApiClientHelper.responseToModel(func: func);
    return result.fold((l) => left(l), (r) {
      return right(SearchResultModal.fromJson(r));
    });
  }
}
