import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/localization/localization_manager.dart';
import '../../../hadithDetails/data/modal/hadith_search_modal.dart';
import '../../data/modal/all_hadith_categories_modal.dart';
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
  TextEditingController localSearchController = TextEditingController();
  
  SearchResultModal? searchResultModal;
  List<CategoriesModal>? categoriesModal;
  List<CategoriesModal>? _allCategories;
  
  AllHadithCategorieModal? allHadithCategorieModal;
  AllHadithCategorieModal? _allHadithsInCategory;

  Timer? _debounce;
  final Map<String, String> _normalizedCache = {};

  @override
  Future<void> close() {
    _debounce?.cancel();
    _normalizedCache.clear();
    return super.close();
  }

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
          _allCategories = categoriesList;
          categoriesModal = categoriesList;
          _normalizedCache.clear(); // Clear cache on new data load
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

  void searchCategories(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _performSearchCategories(query);
    });
  }

  Future<void> _performSearchCategories(String query) async {
    if (_allCategories == null) return;
    if (query.isEmpty) {
      categoriesModal = _allCategories;
      emit(CategoriesState.success(categoriesModal: _allCategories));
    } else {
      final filtered = await compute(_filterCategories, {
        'list': _allCategories!,
        'query': query,
        'cache': _normalizedCache,
      });
      categoriesModal = filtered;
      emit(CategoriesState.success(categoriesModal: filtered));
    }
  }

  static List<CategoriesModal> _filterCategories(Map<String, dynamic> params) {
    final List<CategoriesModal> list = params['list'];
    final String query = params['query'].toString().normalizeArabic;
    final Map<String, String> cache = params['cache'] ?? {};
    
    return list.where((item) {
      final title = item.title ?? "";
      final normalizedTitle = cache[title] ??= title.normalizeArabic;
      return normalizedTitle.contains(query);
    }).toList();
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
          _allHadithsInCategory = allHadithCategorieModalList;
          allHadithCategorieModal = allHadithCategorieModalList;
          _normalizedCache.clear();
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

  void searchHadiths(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _performSearchHadiths(query);
    });
  }

  Future<void> _performSearchHadiths(String query) async {
    if (_allHadithsInCategory == null || _allHadithsInCategory!.data == null) return;
    if (query.isEmpty) {
      allHadithCategorieModal = _allHadithsInCategory;
      emit(CategoriesState.hadithCatrgoriesSuccess(
          allHadithCategorieModal: _allHadithsInCategory));
    } else {
      final filteredData = await compute(_filterHadiths, {
        'data': _allHadithsInCategory!.data!,
        'query': query,
        'cache': _normalizedCache,
      });
      
      final filteredModal = AllHadithCategorieModal(
        data: filteredData,
        meta: _allHadithsInCategory!.meta,
      );
      allHadithCategorieModal = filteredModal;
      emit(CategoriesState.hadithCatrgoriesSuccess(
          allHadithCategorieModal: filteredModal));
    }
  }

  static List<Datum> _filterHadiths(Map<String, dynamic> params) {
    final List<Datum> data = params['data'];
    final String query = params['query'].toString().normalizeArabic;
    final Map<String, String> cache = params['cache'] ?? {};

    return data.where((item) {
      final title = item.title ?? "";
      final normalizedTitle = cache[title] ??= title.normalizeArabic;
      return normalizedTitle.contains(query);
    }).toList();
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
