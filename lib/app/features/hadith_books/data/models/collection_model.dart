import 'package:objectbox/objectbox.dart' show Entity, Id, ToMany, Backlink;

import 'ar_hadith_model.dart';
import 'book_obj_model.dart';
import 'collection_lang.dart';
import 'en_hadith_model.dart';
import 'ur_hadith_model.dart';

@Entity()
class Collection {
  @Id(assignable: true)
  int? id;
  final String name;
  final String bookName;
  final String arAndEnName;
  final bool hasBooks;
  final bool hasChapters;
  final List<String> translations;
  final int totalBooksCount;
  ToMany<CollectionLang> collectionLangs = ToMany<CollectionLang>();
  final int totalHadith;
  final int totalAvailableHadith;
  ToMany<BookObjModel> booksNames = ToMany<BookObjModel>();
  @Backlink('collection')
  ToMany<ARHadithModel> arabicHadiths = ToMany<ARHadithModel>();
  @Backlink('collection')
  ToMany<ENHadithModel> englishHadiths = ToMany<ENHadithModel>();
  @Backlink('collection')
  ToMany<URHadithModel> urduHadiths = ToMany<URHadithModel>();
  
  Collection({
    required this.name,
    required this.bookName,
    required this.arAndEnName,
    required this.hasBooks,
    required this.hasChapters,
    required this.translations,
    required this.totalBooksCount,
    required this.collectionLangs,
    required this.totalHadith,
    required this.totalAvailableHadith,
    required this.booksNames,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      name: json['name'],
      bookName: json['bookName'] ?? 'book name',
      arAndEnName: json['arAndEnName'] ?? 'book ar and en name',
      hasBooks: json['hasBooks'],
      hasChapters: json['hasChapters'],
      translations: List<String>.from(json['translations']),
      totalBooksCount: json['books_count'],
      collectionLangs: ToMany<CollectionLang>(
          items: List<CollectionLang>.from(
              json['collection'].map((lang) => CollectionLang.fromJson(
                    lang,
                  )))),
      totalHadith: json['totalHadith'],
      totalAvailableHadith: json['totalAvailableHadith'],
      booksNames: ToMany<BookObjModel>(
          items: List<BookObjModel>.from(json['books_names']
              .map((j) => BookObjModel.fromJson(j))
              .toList())),
    );
  }
}
