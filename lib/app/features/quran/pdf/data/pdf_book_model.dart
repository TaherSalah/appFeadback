import 'package:hive/hive.dart';

part 'pdf_book_model.g.dart';

@HiveType(typeId: 30)
class PdfBookModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String url;
  @HiveField(4)
  final String? coverUrl;
  @HiveField(5)
  final String fileName;
  @HiveField(6)
  bool isDownloaded;

  PdfBookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.fileName,
    this.coverUrl,
    this.isDownloaded = false,
  });

  factory PdfBookModel.fromJson(Map<String, dynamic> json) {
    return PdfBookModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
      coverUrl: json['coverUrl'],
      isDownloaded: false, // Corrected syntax: using colon for named argument
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'fileName': fileName,
      'coverUrl': coverUrl,
    };
  }
}
