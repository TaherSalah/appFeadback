import 'dart:developer' show log;
import 'dart:math' show min;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/cubit/centralized_cubit.dart';
import '../../../../core/utils/constent/lists.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../data/models/ar_hadith_model.dart';
import '../../data/models/bn_hadith_model.dart';
import '../../data/models/book_obj_model.dart';
import '../../data/models/collection_model.dart';
import '../../data/models/en_hadith_model.dart';
import '../../data/models/ur_hadith_model.dart';
import '../../data/models/collection_lang.dart';
import '../books_controller.dart';
import '../../presentation/read_view.dart';
import '../../presentation/details/collection_details_screen.dart';
// Ensure this path matches where objectbox.g.dart is
import '../../../../../objectbox.g.dart'; 

extension BooksGettersExtension on BooksController {
  
  List<Collection> getCollectionsGroupByTitle(String title) {
    // Requires Constants to be imported
    if (title == Constants.collectionsGroupsTitles[0]) {
      return theSixBooksCollection;
    } else if (title == Constants.collectionsGroupsTitles[1]) {
      return theNineBooksCollection;
    } else {
      return theOtherBooksCollection;
    }
  }

  int get currentBookHadithsCount {
    final count = (store
            .box<ARHadithModel>()
            .query(ARHadithModel_.bookNumber.equals(currentBookNumber))
          ..link(ARHadithModel_.collection,
              Collection_.id.equals(currentCollectionId)))
        .build()
        .count();
    log('currentBookHadithsCount for book $currentBookNumber: $count', name: 'DEBUG');
    return count;
  }

  List<Collection> get theSixBooksCollection {
    log('theSixBooksCollection called. allCollections length: ${allCollections.length}', name: 'DEBUG_BOOKS');
    return allCollections.take(6).toList();
  }

  List<Collection> get theNineBooksCollection {
    log('theNineBooksCollection called. allCollections length: ${allCollections.length}', name: 'DEBUG_BOOKS');
    return allCollections.skip(min(6, allCollections.length)).take(3).toList();
  }

  List<Collection> get theOtherBooksCollection {
    log('theOtherBooksCollection called. allCollections length: ${allCollections.length}', name: 'DEBUG_BOOKS');
    return allCollections.length > 9 ? allCollections.skip(9).toList() : [];
  }

  bool isTheBeginningOfChapter(int index) =>
      currentBookChaptersIndexes.contains(index);

  List<List<ARHadithModel>> get currentBookChapters {
    final Map<String, List<ARHadithModel>> groupedMap = {};
    for (var hadith in arabicHadiths) {
      if (groupedMap.containsKey(hadith.babNumber)) {
        groupedMap[hadith.babNumber]!.add(hadith);
      } else {
        groupedMap[hadith.babNumber] = [hadith];
        currentBookChaptersIndexes.add(arabicHadiths.indexOf(hadith));
      }
    }
    final List<List<ARHadithModel>> hadiths = [];
    hadiths.addAll(groupedMap.values);
    return hadiths;
  }

  String get currentBookPath =>
      'assets/json/books_data/${currentCollection.name}_books';

  String get currentBookName => currentCollection.booksNames
      .firstWhere(
        (e) => double.parse(e.bookNumber).toInt() == currentBookNumber,
        orElse: () => BookObjModel(bookName: 'Unknown', bookNumber: '0'),
      )
      .bookName;

  Collection get currentCollection {
    final col = allCollections.firstWhereOrNull((col) => col.id == currentCollectionId);
    return col ?? Collection(
      name: 'Unknown',
      bookName: 'Unknown',
      arAndEnName: 'Unknown',
      hasBooks: false,
      hasChapters: false,
      translations: [],
      totalBooksCount: 0,
      totalHadith: 0,
      totalAvailableHadith: 0,
      collectionLangs: ToMany<CollectionLang>(),
      booksNames: ToMany<BookObjModel>(),
    );
  }

  static int _currentCollectionId = 1;
  int get currentCollectionId => _currentCollectionId;
  set currentCollectionId(int newId) => _currentCollectionId = newId;

  // Simplified clearing logic
  void clearHadithsAndGetNewOnes() {
    arabicHadiths.clear();
    getAndSetMoreHadiths(clearOlds: true);
  }

  ARHadithModel? getHadithById(int hadithId) {
    return store.box<ARHadithModel>().get(hadithId)!;
  }

  ENHadithModel? getEnHadithById(int hadithId) =>
      tempEnglishHadiths.firstWhereOrNull((h) => h.id == hadithId);
  URHadithModel? getUrHadithById(int hadithId) =>
      tempUrduHadiths.firstWhereOrNull((h) => h.id == hadithId);
  BNHadithModel? getBnHadithById(int hadithId) =>
      tempBanglaHadiths.firstWhereOrNull((h) => h.id == hadithId);

  ENHadithModel? getEnHadithByIndex(int hadithIndex) {
    if (tempEnglishHadiths.length > hadithIndex) {
      return tempEnglishHadiths[hadithIndex];
    }
    return null;
  }

  URHadithModel? getUrHadithByIndex(int hadithIndex) {
    if (tempUrduHadiths.length > hadithIndex) {
      return tempUrduHadiths[hadithIndex];
    }
    return null;
  }

  BNHadithModel? getBnHadithByIndex(int hadithIndex) {
    if (tempBanglaHadiths.length > hadithIndex) {
      return tempBanglaHadiths[hadithIndex];
    }
    return null;
  }

  Future<List<ARHadithModel>> getAndSetArabicHadithsForCurrentBook() async {
    log('currentBookNumber: $currentBookNumber | Collection id: $currentCollectionId',
        name: currentBookName);
    
    // Debug logging for book 0 issue
    final testQuery = store
        .box<ARHadithModel>()
        .query(ARHadithModel_.bookNumber.equals(currentBookNumber))
        .build();
    final totalCount = testQuery.count();
    log('Total hadiths found for bookNumber $currentBookNumber: $totalCount', name: 'DEBUG');
    testQuery.close();
    
    // Store offset and limit for logging
    final queryOffset = shouldScrollToCustomIndex ? 0 : arabicHadiths.length;
    final queryLimit = shouldScrollToCustomIndex ? selectedHadith!.hadithNumber : 10;
    
    final normalQuery = (store
            .box<ARHadithModel>()
            .query(ARHadithModel_.bookNumber.equals(currentBookNumber))
          ..link(ARHadithModel_.collection,
              Collection_.id.equals(currentCollectionId))
          ..order(ARHadithModel_.hadithNumber))
        .build()
      ..offset = queryOffset
      ..limit = queryLimit;
    
    final results = await normalQuery.findAsync();
    log('Query returned ${results.length} hadiths (offset: $queryOffset, limit: $queryLimit)', name: 'DEBUG');
    if (results.isNotEmpty) {
      log('First hadith: ${results.first.hadithText.substring(0, min(50, results.first.hadithText.length))}...', name: 'DEBUG');
    }
    
    return results;
  }

  Future<void> getAndSet2ndLangHadithsForCurrentBook() async {
    // Logic adapted to use local currentTranslationLangCode
    switch (currentTranslationLangCode.value) {
      case 'en':
        final normalQuery = (store
                .box<ENHadithModel>()
                .query(ENHadithModel_.bookNumber.equals(currentBookNumber))
              ..link(ENHadithModel_.collection,
                  Collection_.id.equals(currentCollectionId))
            ..order(ENHadithModel_.hadithNumber))
            .build()
          ..offset = tempEnglishHadiths.length
          ..limit = shouldScrollToCustomIndex
              ? selectedHadith!.hadithNumber
              : 10;
        normalQuery.findAsync().then((v) => tempEnglishHadiths.addAll(v));
        break;

      case 'ur':
        final normalQuery = (store
                .box<URHadithModel>()
                .query(URHadithModel_.bookNumber.equals(currentBookNumber))
              ..link(URHadithModel_.collection,
                  Collection_.id.equals(currentCollectionId))
            ..order(URHadithModel_.hadithNumber))
            .build()
          ..offset = tempUrduHadiths.length
          ..limit = shouldScrollToCustomIndex
              ? selectedHadith!.hadithNumber
              : 10;
        normalQuery.findAsync().then((v) => tempUrduHadiths.addAll(v));
        break;
      case 'bn':
        final normalQuery = (store
                .box<BNHadithModel>()
                .query(BNHadithModel_.bookNumber.equals(currentBookNumber))
              ..link(BNHadithModel_.collection,
                  Collection_.id.equals(currentCollectionId))
            ..order(BNHadithModel_.hadithNumber))
            .build()
          ..offset = tempBanglaHadiths.length
          ..limit = shouldScrollToCustomIndex
              ? selectedHadith!.hadithNumber
              : 10;
        normalQuery.findAsync().then((v) => tempBanglaHadiths.addAll(v));
        break;
    }
  }

  Future<void> getAndSetMoreHadiths({bool clearOlds = false}) async {
    if (clearOlds) {
      tempEnglishHadiths.clear();
      tempUrduHadiths.clear();
      tempBanglaHadiths.clear();
    }
    final List<ARHadithModel> newHadiths =
        await getAndSetArabicHadithsForCurrentBook();
    if (newHadiths.isEmpty) {
      log('No more hadiths to load', name: 'getAndSetMoreHadiths');
      return;
    }
    arabicHadiths.addAll(newHadiths);
    await getAndSet2ndLangHadithsForCurrentBook();
  }

  // Logic for setting book and navigating, ported from books_ui_helper.dart
  Future<void> setAndShowBookByBookNumber(int bookNumber) async {
    // Logic for Tirmidhi check
    if (currentCollection.name == 'tirmidhi' &&
        [3, 4, 5, 6].contains(bookNumber)) {
      bookNumber = 2;
    }
    
    currentBookNumber = bookNumber;
    clearHadithsAndGetNewOnes();
    
    Navigator.push(
      CentralizedCubit.navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const ReadView()),
    );
    
  }

  Future<void> setAndShowCollectionByCollectionId(int collectionId, int idFromList) async {
    currentCollectionId = collectionId;

    final collection = allCollections.firstWhereOrNull((c) => c.id == collectionId);
    
    // Check if we need to load or RELOAD (if corrupted data detected)
    bool needsLoad = false;
    if (collection != null) {
       bool hasCorruptedBooks = collection.booksNames.any((b) => b.bookNumber == '-1' || b.bookNumber == '-1.0');
       if (collection.booksNames.isEmpty || hasCorruptedBooks) {
          needsLoad = true;
       }
    }

    if (collection != null && needsLoad) {
        showDialog(
          context: CentralizedCubit.navigatorKey.currentContext!,
          barrierDismissible: false,
          builder: (context) =>  Center(child:  KLoading.progressIOSIndicator(context: context)),
        );
        
        await loadBooksForCollection(collection);
        
        if (Navigator.canPop(CentralizedCubit.navigatorKey.currentContext!)) {
          Navigator.pop(CentralizedCubit.navigatorKey.currentContext!);
        }
    }

    Navigator.push(
      CentralizedCubit.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => CollectionDetailsScreen(bookNumber: idFromList),
      ),
    );
  }

  RxBool isBookLoaded(String bookName) => true.obs; 
  // We assume books are loaded or we need to port the download logic if using external assets.
  // But we copied assets locally, so they are "loaded" if we parse them.
  // The original logic checked Splash screen progress or addedColectionsBookNames.
  // We can default to true for now since we expect local assets.

  Future<void> navigateToHadith(ARHadithModel hadith) async {
    // 1. Set context (Collection & Book)
    currentCollectionId = hadith.collection.targetId;
    currentBookNumber = hadith.bookNumber;

    // 2. Prepare for scrolling
    shouldScrollToCustomIndex = true;
    selectedHadith = hadith;

    // 3. Reset and Load Data - WAIT for it
    arabicHadiths.clear();
    await getAndSetMoreHadiths(clearOlds: true);

    // 4. Calculate target index logic
    int targetPage = 0;
    // Try to find index in loaded list
    final index = arabicHadiths.indexWhere((h) => h.id == hadith.id);
    
    if (index != -1) {
       targetPage = index + 1; // +1 because index 0 is book title
    } else {
       // Fallback: use hadithNumber directly
       targetPage = hadith.hadithNumber;
    }

    // 5. Navigate to ReadView with initialPage
    Navigator.push(
      CentralizedCubit.navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => ReadView(initialPage: targetPage),
      ),
    );
    
    // Reset flag immediately after navigation is initiated
    // This allows subsequent loads to work normally (offset-based)
    shouldScrollToCustomIndex = false;
    
    // Trigger UI update to ensure consistent state
    update();
  }
}
