import 'package:objectbox/objectbox.dart' show Entity, Id, ToOne;
import 'collection_model.dart';

@Entity()
class ARHadithModel {
  @Id()
  int? id;
  final int volumeNumber;
  final int bookNumber;
  final String bookName;
  final String babNumber;
  final String? babName;
  final int hadithNumber;
  final String newHadithNumber;
  final String hadithText;
  final String bookID;
  final int ourHadithNumber;
  final int matchingEnglishURN;
  final String lastUpdated;
  final int arabicURN;
  final List<String>? annotations;
  final String? grade1;
  final ToOne<Collection> collection = ToOne<Collection>();

  late String hadithTextWithoutDiacritics;

  ARHadithModel({
    required this.arabicURN,
    required this.annotations,
    required this.grade1,
    required this.volumeNumber,
    required this.bookNumber,
    required this.bookName,
    required this.babNumber,
    required this.babName,
    required this.hadithNumber,
    required this.newHadithNumber,
    required this.hadithText,
    required this.bookID,
    required this.ourHadithNumber,
    required this.matchingEnglishURN,
    required this.lastUpdated,
  });

  factory ARHadithModel.fromJson(Map<String, dynamic> json) {
    return ARHadithModel(
      arabicURN: json['arabicURN'],
      annotations: json['annotations'] != null
          ? RegExp('"([^"]*)"')
              .allMatches(
                  json['annotations'].replaceAll(RegExp(r'<[^>]*>'), ''))
              .map((match) => match.group(1)!)
              .toList()
          : null,
      grade1: json['grade1'],
      volumeNumber: json['volumeNumber'],
      bookNumber: (json['bookNumber'] is int) 
          ? json['bookNumber'] 
          : (int.tryParse(json['bookNumber']?.toString().replaceAll(RegExp(r'\D'), '') ?? '0') ?? 0),
      bookName: json['bookName'],
      babNumber: json['babNumber'] ?? '',
      babName: json['babName'] ?? '',
      hadithNumber: int.parse(
          (json['hadithNumber'].toString()).replaceAll(RegExp(r'\D'), '')),
      newHadithNumber: (json['hadithNumber'].toString()),
      hadithText: json['hadithText'],
      bookID: json['bookID'],
      ourHadithNumber: json['ourHadithNumber'],
      matchingEnglishURN: json['matchingEnglishURN'],
      lastUpdated: json['last_updated'] ?? '',
    )..hadithTextWithoutDiacritics = removeDiacritics(json['hadithText']);
  }

  static String removeDiacritics(String text) {
    return text.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065E\u0670]'), '');
  }
}
