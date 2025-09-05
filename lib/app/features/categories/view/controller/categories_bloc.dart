import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_manager.dart';
import '../../../hadithDetails/data/modal/hadith_search_modal.dart';
import '../../data/modal/categories_modal.dart';
import '../../data/repo/categories_repo_immp.dart';
import 'categories_state.dart';

class CategoriesBloc extends Cubit<CategoriesState> {
  CategoriesBloc(this.categoriesRepoImmp)
      : super(const CategoriesState.initial());

  static CategoriesBloc get(context) =>
      BlocProvider.of<CategoriesBloc>(context);

  final CategoriesRepoImmp categoriesRepoImmp;
  TextEditingController searchKeyboardController = TextEditingController();
  SearchResultModal? searchResultModal;
  List<CategoriesModal>? categoriesModal;
  Future<void> getAllCategories() async {
    try {
      emit(const CategoriesState.loading());
      var result = await categoriesRepoImmp.getAllCategories();
      result.fold(
        (failure) {
          debugPrint(
              '=================  get All Categories Bloc Failure : $failure');
          emit(CategoriesState.error(failure: failure.toString()));
        },
        (categoriesList) {
          categoriesModal = categoriesList;
          debugPrint(
              '================= get All Categories Bloc Success : $categoriesList');
          emit(CategoriesState.success(categoriesModal: categoriesList));
        },
      );
    } catch (e) {
      debugPrint(
          '================= get All Categories Bloc (Catch): ${e.toString()}');
      emit(CategoriesState.error(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }

  Future<void> getAllHadithFromCategories({dynamic categoriesId}) async {
    try {
      emit(const CategoriesState.hadithCatrgoriesLoading());
      var result = await categoriesRepoImmp.getAllHadithFromCategories(
          categoriesId: categoriesId);
      result.fold(
        (failure) {
          debugPrint(
              '================= get All Hadith From Categories Bloc Failure : $failure');
          emit(CategoriesState.hadithCatrgoriesError(
              failure: failure.toString()));
        },
        (allHadithCategorieModalList) {
          debugPrint(
              '================= get All Hadith From Categories Bloc Success : $allHadithCategorieModalList');
          emit(CategoriesState.hadithCatrgoriesSuccess(
              allHadithCategorieModal: allHadithCategorieModalList));
        },
      );
    } catch (e) {
      debugPrint(
          '================= get All Hadith From Categories Bloc (Catch): ${e.toString()}');
      emit(CategoriesState.hadithCatrgoriesError(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }

  Future<void> getHadithSearch({dynamic wordKey}) async {
    try {
      emit(const CategoriesState.loadingHadithSearch());
      var result = await categoriesRepoImmp.getHadithSearch(
          searchWord: searchKeyboardController.text);
      result.fold((failure) {
        debugPrint(
            '=================  get hadith Search  Bloc Failure : $failure');
        emit(CategoriesState.errorHadithSearch(failure: failure.toString()));
      }, (data) {
        searchResultModal = data;
        debugPrint('================= get hadith Search Bloc Success : $data');
        emit(CategoriesState.successHadithSearch(searchResultModal: data));
      });
    } catch (e) {
      debugPrint(
          '================= get hadith Search Bloc (Catch): ${e.toString()}');
      emit(CategoriesState.errorHadithSearch(
          failure: LocalizationManager.call('try_later')));
      rethrow;
    }
  }
}
