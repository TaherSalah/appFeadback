import 'dart:developer' show log;
import 'package:get/get.dart' hide Condition;
import 'package:get_it/get_it.dart';

import '../../../core/utils/objectbox.dart';
import '../data/models/ar_hadith_model.dart';
import '../data/models/collection_model.dart';
import '../../../../objectbox.g.dart';

class SearchController extends GetxController {
  static SearchController get instance =>
      Get.isRegistered<SearchController>()
          ? Get.find<SearchController>()
          : Get.put(SearchController());

  late Store store;
  
  // Search results
  RxList<ARHadithModel> searchResults = <ARHadithModel>[].obs;
  
  // Search state
  RxBool isSearching = false.obs;
  RxString currentQuery = ''.obs;
  RxString selectedNarrator = ''.obs;
  RxString selectedBook = ''.obs;
  Collection? selectedCollection;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize Store
    if (GetIt.I.isRegistered<ObjBox>()) {
      store = GetIt.I.get<ObjBox>().store;
    } else {
      log('ObjBox not registered yet in GetIt', name: 'SearchController');
    }
  }

  /// Search in hadith text
  Future<void> searchInText(String query, {Collection? collection}) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      currentQuery.value = query;
      selectedCollection = collection;

      final hadithBox = store.box<ARHadithModel>();
      
      // Build query
      QueryBuilder<ARHadithModel> queryBuilder;
      
      if (collection != null) {
        // Search within specific collection
        queryBuilder = hadithBox
            .query(ARHadithModel_.collection.equals(collection.id!) &
                   ARHadithModel_.hadithTextWithoutDiacritics.contains(
                     _removeDiacritics(query),
                     caseSensitive: false,
                   ));
      } else {
        // Search all hadiths
        queryBuilder = hadithBox.query(
          ARHadithModel_.hadithTextWithoutDiacritics.contains(
            _removeDiacritics(query),
            caseSensitive: false,
          ),
        );
      }

      final results = queryBuilder.build().find();
      searchResults.value = results;
      
      log('Found ${results.length} hadiths for query: $query', name: 'SearchController');
    } catch (e) {
      log('Error searching hadiths: $e', name: 'SearchController');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Search by narrator (in babName field which often contains narrator info)
  Future<void> searchByNarrator(String narrator) async {
    if (narrator.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      selectedNarrator.value = narrator;

      final hadithBox = store.box<ARHadithModel>();
      
      // Search in babName which often contains narrator information
      final results = hadithBox
          .query(
            ARHadithModel_.babName.contains(narrator, caseSensitive: false),
          )
          .build()
          .find();

      searchResults.value = results;
      
      log('Found ${results.length} hadiths for narrator: $narrator', name: 'SearchController');
    } catch (e) {
      log('Error searching by narrator: $e', name: 'SearchController');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Filter by book name
  Future<void> filterByBook(String bookName, {Collection? collection}) async {
    if (bookName.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      selectedBook.value = bookName;
      selectedCollection = collection;

      final hadithBox = store.box<ARHadithModel>();
      
      QueryBuilder<ARHadithModel> queryBuilder;
      
      if (collection != null) {
        queryBuilder = hadithBox.query(
          ARHadithModel_.collection.equals(collection.id!) &
          ARHadithModel_.bookName.contains(bookName, caseSensitive: false),
        );
      } else {
        queryBuilder = hadithBox.query(
          ARHadithModel_.bookName.contains(bookName, caseSensitive: false),
        );
      }

      final results = queryBuilder.build().find();
      searchResults.value = results;
      
      log('Found ${results.length} hadiths in book: $bookName', name: 'SearchController');
    } catch (e) {
      log('Error filtering by book: $e', name: 'SearchController');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Advanced search with multiple criteria
  Future<void> advancedSearch({
    String? text,
    String? narrator,
    String? book,
    Collection? collection,
  }) async {
    try {
      isSearching.value = true;
      currentQuery.value = text ?? '';
      selectedNarrator.value = narrator ?? '';
      selectedBook.value = book ?? '';
      selectedCollection = collection;

      if ((text?.trim().isEmpty ?? true) &&
          (narrator?.trim().isEmpty ?? true) &&
          (book?.trim().isEmpty ?? true)) {
        searchResults.clear();
        return;
      }

      final hadithBox = store.box<ARHadithModel>();
      
      // Build conditions
      List<Condition<ARHadithModel>> conditions = [];

      if (collection != null) {
        conditions.add(ARHadithModel_.collection.equals(collection.id!));
      }

      if (text != null && text.trim().isNotEmpty) {
        conditions.add(ARHadithModel_.hadithTextWithoutDiacritics.contains(
          _removeDiacritics(text),
          caseSensitive: false,
        ));
      }

      if (narrator != null && narrator.trim().isNotEmpty) {
        conditions.add(ARHadithModel_.babName.contains(narrator, caseSensitive: false));
      }

      if (book != null && book.trim().isNotEmpty) {
        conditions.add(ARHadithModel_.bookName.contains(book, caseSensitive: false));
      }

      // Combine all conditions with AND
      Condition<ARHadithModel>? finalCondition;
      if (conditions.isNotEmpty) {
        finalCondition = conditions.first;
        for (int i = 1; i < conditions.length; i++) {
          finalCondition = finalCondition! & conditions[i];
        }
      }

      final results = hadithBox.query(finalCondition).build().find();
      searchResults.value = results;
      
      log('Advanced search found ${results.length} hadiths', name: 'SearchController');
    } catch (e) {
      log('Error in advanced search: $e', name: 'SearchController');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Clear search results
  void clearSearch() {
    searchResults.clear();
    currentQuery.value = '';
    selectedNarrator.value = '';
    selectedBook.value = '';
    selectedCollection = null;
    update();
  }

  /// Get unique book names for autocomplete
  List<String> getAllBookNames() {
    try {
      final hadithBox = store.box<ARHadithModel>();
      final allHadiths = hadithBox.getAll();
      final bookNames = allHadiths.map((h) => h.bookName).toSet().toList();
      bookNames.sort();
      return bookNames;
    } catch (e) {
      log('Error getting book names: $e', name: 'SearchController');
      return [];
    }
  }

  /// Remove diacritics for search
  String _removeDiacritics(String text) {
    return text.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065E\u0670]'), '');
  }
}
