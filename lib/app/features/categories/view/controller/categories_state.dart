import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hadithDetails/data/modal/hadith_search_modal.dart';
import '../../data/modal/all_hadith_categories_modal.dart';
import '../../data/modal/categories_modal.dart';

part 'categories_state.freezed.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState.initial() = CategoriesStateInitial;

  const factory CategoriesState.loading() = CategoriesStateLoading;

  const factory CategoriesState.success(
      {List<CategoriesModal>? categoriesModal}) = CategoriesStateSuccess;

  const factory CategoriesState.error({required String failure}) =
      CategoriesStateError;

  const factory CategoriesState.hadithCatrgoriesLoading() =
      HadithCategoriesStateLoading;

  const factory CategoriesState.hadithCatrgoriesSuccess(
          {AllHadithCategorieModal? allHadithCategorieModal}) =
      HadithCategoriesStateSuccess;

  const factory CategoriesState.hadithCatrgoriesError(
      {required String failure}) = HadithCategoriesStateError;

  const factory CategoriesState.loadingHadithSearch() =
      HadithSearchStateLoading;
  const factory CategoriesState.errorHadithSearch({required String failure}) =
      HadithSearchStateError;
  const factory CategoriesState.successHadithSearch(
      {SearchResultModal? searchResultModal}) = HadithSearchStateSuccess;
}
// flutter pub run build_runner build --delete-conflicting-outputs
