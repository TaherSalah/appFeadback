import 'package:objectbox/objectbox.dart' show Entity, Id, ToOne;
import 'collection_model.dart';

@Entity()
class URHadithModel {
  @Id()
  int? id;
  final int volumeNumber;
  final int bookNumber;
  final String? bookName;
  final String? babNumber;
  final String? babName;
  final int hadithNumber;
  final String hadithText;
  final String bookID;
  final int ourHadithNumber;
  final int matchingArabicURN;
  final String lastUpdated;
  final int urduURN;
  final String? grade1;
  final collection = ToOne<Collection>();

  URHadithModel({
    required this.urduURN,
    required this.grade1,
    required this.volumeNumber,
    required this.bookNumber,
    required this.bookName,
    required this.babNumber,
    required this.babName,
    required this.hadithNumber,
    required this.hadithText,
    required this.bookID,
    required this.ourHadithNumber,
    required this.matchingArabicURN,
    required this.lastUpdated,
  });

  factory URHadithModel.fromJson(Map<String, dynamic> json) {
    return URHadithModel(
      urduURN: json['urduURN'],
      grade1: json['grade1'],
      volumeNumber: json['volumeNumber'],
      bookNumber: (json['bookNumber'] is int) ? json['bookNumber'] : (int.tryParse(json['bookNumber']?.toString() ?? '0') ?? 0),
      bookName: json['bookName'],
      babNumber: json['babNumber']?.toString(),
      babName: json['babName'],
      hadithNumber: int.tryParse(json['hadithNumber'].toString()) ?? 404,
      hadithText: json['hadithText'],
      bookID: json['bookID'],
      ourHadithNumber: json['ourHadithNumber'],
      matchingArabicURN: json['matchingArabicURN'],
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}
