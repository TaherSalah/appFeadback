abstract class KEndPoints {
  static const String baseUrl = 'https://hadeethenc.com/api/v1';

  static String getCategories =
      // '$baseUrl/categories/list/?language=${LocalizationManager.isEn ? "en" : "ar"}';
      '$baseUrl/categories/list/?language=ar';

  static String register = 'https://api.hadith-shareef.com/api/auth/register';
  static String login = 'https://api.hadith-shareef.com/api/auth/login';
  static String profile = 'https://api.hadith-shareef.com/api/auth/profile';
  static String hadithBookMarks =
      'https://api.hadith-shareef.com/api/bookmarks/add';

  static String getHadithFromCategories({dynamic categoryId}) =>
      // '$baseUrl/hadeeths/list/?language=${LocalizationManager.isEn ? "en" : "ar"}&category_id=$categoryId&page=1&per_page=5';
      '$baseUrl/hadeeths/list/?language=ar&category_id=$categoryId&page=1&per_page=1000';

  static String getHadithDetails({dynamic hadithId}) =>
      // 'https://hadeethenc.com/api/v1/hadeeths/one/?language=${LocalizationManager.isEn ? "en" : "ar"}&id=$hadithId';
      'https://hadeethenc.com/api/v1/hadeeths/one/?language=ar&id=$hadithId';

  static String getHadithSearch({dynamic searchWord}) =>
      'https://hadith-shareef.com/index.php?skey=$searchWord';

  static String removeBookmarksHadith({dynamic hadithId}) =>
      'https://api.hadith-shareef.com/api/bookmarks/remove/$hadithId';

  static String getMoreHadithInDetails({dynamic categoryId}) =>
      '$baseUrl/hadeeths/list/?language=ar&category_id=$categoryId&page=1&per_page=6';

  static String removeBookmarks({dynamic hadithId}) =>
      '$baseUrl/bookmarks/remove/$hadithId';

  static String getAllBookmarks =
      'https://api.hadith-shareef.com/api/bookmarks';

  static String addHadithToBookmarks(
          {dynamic hadithId,
          dynamic userId,
          dynamic collection,
          dynamic createdAt,
          dynamic hadithBook,
          dynamic notes}) =>
      '$baseUrl/bookmarks/add';

// '$baseUrl/hadeeths/list/?language=${LocalizationManager.isEn ? "en" : "ar"}&category_id=$categoryId&page=1&per_page=6';
}
