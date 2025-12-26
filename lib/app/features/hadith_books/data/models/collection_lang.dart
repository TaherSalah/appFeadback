import 'package:objectbox/objectbox.dart';
import 'collection_model.dart';

@Entity()
class CollectionLang {
  @Id()
  int? id;
  final String lang;
  final String title;
  final String shortIntro;

  final ToOne<Collection> collection = ToOne<Collection>();

  CollectionLang({
    required this.lang,
    required this.title,
    required this.shortIntro,
  });

  factory CollectionLang.fromJson(Map<String, dynamic> json) {
    return CollectionLang(
      lang: json['lang'],
      title: json['title'],
      shortIntro: json['shortIntro'],
    );
  }
}
