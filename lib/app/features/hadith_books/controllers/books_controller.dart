import 'dart:developer' show log;
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:objectbox/objectbox.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/constent/lists.dart';
import '../../../core/utils/objectbox.dart';
import '../data/models/ar_hadith_model.dart';
import '../data/models/bn_hadith_model.dart';
import '../data/models/collection_model.dart';
import '../data/models/collection_lang.dart';
import '../data/models/book_obj_model.dart';
import '../data/models/en_hadith_model.dart';
import '../data/models/ur_hadith_model.dart';

// Assuming objectbox.g.dart is in the root of the project by default or correctly placed
import '../../../../../objectbox.g.dart';
import '../data/models/bookmark_model.dart';


class BooksController extends GetxController {
  static BooksController get instance =>
      Get.isRegistered<BooksController>()
          ? Get.find<BooksController>()
          : Get.put(BooksController());

  final box = GetStorage();
  final RxList<ARHadithModel> arabicHadiths = <ARHadithModel>[].obs;
  RxList<ENHadithModel> tempEnglishHadiths = <ENHadithModel>[].obs;
  RxList<URHadithModel> tempUrduHadiths = <URHadithModel>[].obs;
  RxList<BNHadithModel> tempBanglaHadiths = <BNHadithModel>[].obs;

  var lastReadPage = <String, int>{}.obs;
  var listHadithID = <int, int>{}.obs;
  Map<int, int> bookTotalPages = {};
  RxInt currentPageNumber = 0.obs;

  List<String> otherLanguages = ['en', 'ur', 'bn'];

  int currentBookNumber = 1;

  final List<int> currentBookChaptersIndexes = [];

  PageController bookChaptersPageViewCrl = PageController();

  List<Collection> allCollections = [];
  
  // Mocking the Splash/Organize functionality for now
  final RxList<String> addedColectionsBookNames = <String>[].obs;

  bool shouldScrollToCustomIndex = false;
  int get currentCustomScrollIndex => shouldScrollToCustomIndex ? 5 : 0;
  ARHadithModel? selectedHadith;

  late Store store;

  void _setStore(Store store) => this.store = store;

  // Placeholder for GeneralController language code
  RxString currentTranslationLangCode = 'en'.obs; 
  // Placeholder available check
  bool get selectedTranslationLangAvailable => true;

  @override
  void onInit() {
    log('Initializing BooksController', name: 'BooksController');
    lastReadedHadithsWorker = debounce(currentPageIndex, (callback) {
      if (currentPageIndex.value != 0) {
        saveLastReadHadith();
      }
    }, time: const Duration(milliseconds: 2500));

    // Initialize Store
    if (GetIt.I.isRegistered<ObjBox>()) {
      setStore(GetIt.I.get<ObjBox>().store);
    } else {
      log('ObjBox not registered yet in GetIt', name: 'BooksController');
    }

    super.onInit();
  }
  
  // Method to be called from Main when Store is ready
  void setStore(Store store) {
     _setStore(store);
     _ensureCollectionsLoaded();
  }

  void _ensureCollectionsLoaded() {
    final collectionBox = store.box<Collection>();
    if (collectionBox.isEmpty()) {
      log('Seeding Collections...', name: 'BooksController');
      List<Collection> newCollections = [];
      for (var bookData in booksList) {
        newCollections.add(Collection(
          name: bookData['bookName'],
          bookName: bookData['name'],
          arAndEnName: bookData['arAndEnName'] ?? bookData['name'],
          hasBooks: true, // Defaulting to true as most collections have books
          hasChapters: true, // Defaulting to true
          translations: [], // Empty list for now
          totalBooksCount: 0, // Placeholder
          collectionLangs: ToMany<CollectionLang>(), // Placeholder
          totalHadith: 0, 
          totalAvailableHadith: 0,
          booksNames: ToMany<BookObjModel>(),
        ));
      }
      collectionBox.putMany(newCollections);
    }
    allCollections = collectionBox.getAll();
    update();
  }

  void saveLastReadHadith() {
     // Logic to be added from ui_getters or extensions
     // For minimal migration, we will implement save logic here or in extension
  }

  RxInt currentPageIndex = RxInt(0);
  late Worker lastReadedHadithsWorker;

  void changePage(int newPageIndex) {
    currentPageIndex.value = newPageIndex;
    if (arabicHadiths.length <= newPageIndex + 3) {
      debugPrint('Getting More Hadiths...');
       // implementation from ui_getters
       // getAndSetMoreHadiths();
       update();
    }
  }

  @override
  void dispose() {
    lastReadedHadithsWorker.dispose();
    super.dispose();
  }

  // ============================================
  // Bookmarks Management Methods
  // ============================================

  /// Toggle bookmark for a hadith
  Future<bool> toggleBookmark(ARHadithModel hadith, {String category = 'عام'}) async {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      
      // Check if already bookmarked
      final existingBookmark = bookmarkBox
          .query(BookmarkModel_.hadith.equals(hadith.id!))
          .build()
          .findFirst();
      
      if (existingBookmark != null) {
        // Remove bookmark
        bookmarkBox.remove(existingBookmark.id!);
        update();
        return false; // Unbookmarked
      } else {
        // Add bookmark
        final bookmark = BookmarkModel(
          category: category,
          createdAt: DateTime.now(),
        );
        bookmark.hadith.target = hadith;
        bookmarkBox.put(bookmark);
        update();
        return true; // Bookmarked
      }
    } catch (e) {
      log('Error toggling bookmark: $e', name: 'BooksController');
      return false;
    }
  }

  /// Check if a hadith is bookmarked
  bool isBookmarked(int hadithId) {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      final bookmark = bookmarkBox
          .query(BookmarkModel_.hadith.equals(hadithId))
          .build()
          .findFirst();
      return bookmark != null;
    } catch (e) {
      log('Error checking bookmark: $e', name: 'BooksController');
      return false;
    }
  }

  /// Get all bookmarks, optionally filtered by category
  List<BookmarkModel> getBookmarks({String? category}) {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      
      if (category != null && category.isNotEmpty) {
        return bookmarkBox
            .query(BookmarkModel_.category.equals(category))
            .order(BookmarkModel_.createdAt, flags: Order.descending)
            .build()
            .find();
      } else {
        return bookmarkBox
            .query()
            .order(BookmarkModel_.createdAt, flags: Order.descending)
            .build()
            .find();
      }
    } catch (e) {
      log('Error getting bookmarks: $e', name: 'BooksController');
      return [];
    }
  }

  /// Get all unique bookmark categories
  List<String> getBookmarkCategories() {
    try {
      final bookmarks = getBookmarks();
      final categories = bookmarks.map((b) => b.category).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      log('Error getting categories: $e', name: 'BooksController');
      return [];
    }
  }

  /// Update bookmark category
  Future<void> updateBookmarkCategory(int bookmarkId, String newCategory) async {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      final bookmark = bookmarkBox.get(bookmarkId);
      
      if (bookmark != null) {
        // Create a new bookmark with updated category
        final updatedBookmark = BookmarkModel(
          id: bookmark.id,
          category: newCategory,
          note: bookmark.note,
          createdAt: bookmark.createdAt,
        );
        updatedBookmark.hadith.target = bookmark.hadith.target;
        
        bookmarkBox.put(updatedBookmark);
        update();
      }
    } catch (e) {
      log('Error updating bookmark category: $e', name: 'BooksController');
    }
  }

  /// Update bookmark note
  Future<void> updateBookmarkNote(int bookmarkId, String? newNote) async {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      final bookmark = bookmarkBox.get(bookmarkId);
      
      if (bookmark != null) {
        final updatedBookmark = BookmarkModel(
          id: bookmark.id,
          category: bookmark.category,
          note: newNote,
          createdAt: bookmark.createdAt,
        );
        updatedBookmark.hadith.target = bookmark.hadith.target;
        
        bookmarkBox.put(updatedBookmark);
        update();
      }
    } catch (e) {
      log('Error updating bookmark note: $e', name: 'BooksController');
    }
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    try {
      final bookmarkBox = store.box<BookmarkModel>();
      bookmarkBox.remove(bookmarkId);
      update();
    } catch (e) {
      log('Error deleting bookmark: $e', name: 'BooksController');
    }
  }

  /// Get bookmark count
  int getBookmarkCount({String? category}) {
    return getBookmarks(category: category).length;
  }


  Future<void> loadBooksForCollection(Collection collection) async {
    final hadithCount = store.box<ARHadithModel>().query(ARHadithModel_.collection.equals(collection.id!)).build().count();
    
    // Check for corrupted book numbers (e.g. -1 for Introduction)
    // The previous issue caused Introduction book to be saved as "-1.0", 
    // leading to failed queries (searching for -1 instead of 0).
    bool hasCorruptedBooks = collection.booksNames.any((b) => b.bookNumber == '-1' || b.bookNumber == '-1.0');

    if (!hasCorruptedBooks && collection.booksNames.isNotEmpty && hadithCount > 0) {
      log('Collection ${collection.name} already seeded with $hadithCount hadiths and ${collection.booksNames.length} books.', name: 'BooksController');
      return; // Already loaded and valid
    }

    if (hasCorruptedBooks) {
      log('Found corrupted book numbers in ${collection.name}. Forcing reload.', name: 'BooksController');
    }

    // Cleanup if partially loaded or corrupted
    if (collection.booksNames.isNotEmpty || hadithCount > 0) {
       log('Partial/Corrupted data found for ${collection.name}. Cleaning up and re-loading...', name: 'BooksController');
       final existingBooksList = collection.booksNames.toList();
       if (existingBooksList.isNotEmpty) {
          // Clear relation FIRST to avoid 404 when saving collection with deleted items
          collection.booksNames.clear();
          store.box<Collection>().put(collection);
          
          // Then delete the actual book objects
          store.box<BookObjModel>().removeMany(existingBooksList.map((e) => e.id!).toList());
       }
       // Note: deleting ARHadithModels for this collection
       final q = store.box<ARHadithModel>().query(ARHadithModel_.collection.equals(collection.id!)).build();
       q.remove();
    }

    log('Loading books and hadiths for ${collection.name}...', name: 'BooksController');
    
    final String folderName = '${collection.name}_books';
    final String assetPath = 'assets/json/books_data/$folderName/';

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final filePaths = manifestMap.keys
          .where((String key) => key.contains(assetPath) && key.endsWith('.json'))
          .toList();

      if (filePaths.isEmpty) {
        log('No files found for $assetPath', name: 'BooksController');
        return;
      }

      Map<String, BookObjModel> uniqueBooks = {};
      List<ARHadithModel> arHadiths = [];
      List<ENHadithModel> enHadiths = [];
      List<URHadithModel> urHadiths = [];
      List<BNHadithModel> bnHadiths = [];

      // Process in chunks of 20 to avoid memory pressure while being faster than sequential
      const int chunkSize = 20;
      for (int i = 0; i < filePaths.length; i += chunkSize) {
        final chunk = filePaths.sublist(i, i + chunkSize > filePaths.length ? filePaths.length : i + chunkSize);
        
        await Future.wait(chunk.map((filePath) async {
          final fileName = filePath.split('/').last;
          final jsonString = await rootBundle.loadString(filePath);
          final List<dynamic> jsonList = json.decode(jsonString);

          for (var item in jsonList) {
            if (fileName.startsWith('ar_')) {
              // Extract Book/Chapter info only from Arabic files to avoid duplicates
              // Priority: bookNumber (index), then bookID. For Ibn Majah, bookNumber is correct.
              
              // Helper to safely get book number and handle the -1.0 issue
              String getAndFixBookNum(Map<String, dynamic> item) {
                 var val = item['bookNumber'];
                 if (val != null) return val.toString();
                 
                 // Fallback to bookID if bookNumber missing
                 val = item['bookID'];
                 String strVal = val?.toString() ?? '0';
                 if (strVal == '-1.0' || strVal == '-1') return '0';
                 return strVal;
              }

              String bookNum = getAndFixBookNum(item);
              String bookName = item['bookName'] ?? '';
              
              if (!uniqueBooks.containsKey(bookNum)) {
                uniqueBooks[bookNum] = BookObjModel(bookName: bookName, bookNumber: bookNum);
              }

              try {
                final hadith = ARHadithModel.fromJson(item);
                hadith.collection.target = collection;
                arHadiths.add(hadith);
              } catch (e) { /* log if needed */ }
            } else if (fileName.startsWith('en_')) {
              try {
                final hadith = ENHadithModel.fromJson(item);
                hadith.collection.target = collection;
                enHadiths.add(hadith);
              } catch (e) {}
            } else if (fileName.startsWith('ur_')) {
              try {
                final hadith = URHadithModel.fromJson(item);
                hadith.collection.target = collection;
                urHadiths.add(hadith);
              } catch (e) {}
            } else if (fileName.startsWith('bn_')) {
              try {
                final hadith = BNHadithModel.fromJson(item);
                hadith.collection.target = collection;
                bnHadiths.add(hadith);
              } catch (e) {}
            }
          }
        }));
      }

      // Save everything
      if (uniqueBooks.isNotEmpty) {
        List<BookObjModel> booksToSave = uniqueBooks.values.toList();
        booksToSave.sort((a, b) {
           double numA = double.tryParse(a.bookNumber) ?? 0;
           double numB = double.tryParse(b.bookNumber) ?? 0;
           return numA.compareTo(numB);
        });
        
        // Explicitly put the books first to ensure they have IDs and relations are correctly saved
        store.box<BookObjModel>().putMany(booksToSave);
        
        collection.booksNames.clear(); // Clear any existing just in case
        collection.booksNames.addAll(booksToSave);
        store.box<Collection>().put(collection);
      }

      if (arHadiths.isNotEmpty) store.box<ARHadithModel>().putMany(arHadiths);
      if (enHadiths.isNotEmpty) store.box<ENHadithModel>().putMany(enHadiths);
      if (urHadiths.isNotEmpty) store.box<URHadithModel>().putMany(urHadiths);
      if (bnHadiths.isNotEmpty) store.box<BNHadithModel>().putMany(bnHadiths);

      log('Finished loading ${collection.name}: ${arHadiths.length} AR, ${enHadiths.length} EN, ${urHadiths.length} UR, ${bnHadiths.length} BN', name: 'BooksController');
      
      update(); // Trigger UI update (e.g. for BooksList)
      
    } catch (e) {
      log('Error loading books: $e', name: 'BooksController');
    }
  }
}
