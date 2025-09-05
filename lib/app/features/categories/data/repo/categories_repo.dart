import 'package:dartz/dartz.dart';
import '../../../../core/errors/failuers.dart';
import '../../../hadithDetails/data/modal/hadith_search_modal.dart';
import '../modal/all_hadith_categories_modal.dart';
import '../modal/categories_modal.dart';

abstract class CategoriesRepo {
  Future<Either<dynamic, List<CategoriesModal>>> getAllCategories();

  Future<Either<KFailure, AllHadithCategorieModal>> getAllHadithFromCategories(
      {dynamic categoriesId});
  Future<Either<dynamic, SearchResultModal>> getHadithSearch(
      {dynamic searchWord});
}
