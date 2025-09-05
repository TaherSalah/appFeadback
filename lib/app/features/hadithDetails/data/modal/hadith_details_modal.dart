import 'package:freezed_annotation/freezed_annotation.dart';

part "hadith_details_modal.g.dart";

@JsonSerializable()
class HadithDetailsModal {
  dynamic id;
  dynamic title;
  dynamic hadeeth;
  dynamic attribution;
  dynamic grade;
  dynamic explanation;
  List<dynamic>? hints;
  List<dynamic>? categories;
  List<dynamic>? translations;
  @JsonKey(name: 'hadeeth_intro')
  dynamic hadeethIntro;
  @JsonKey(name: 'words_meanings')
  List<WordsMeaning>? wordsMeanings;
  dynamic reference;

  HadithDetailsModal({
    this.id,
    this.title,
    this.hadeeth,
    this.attribution,
    this.grade,
    this.explanation,
    this.hints,
    this.categories,
    this.translations,
    this.hadeethIntro,
    this.wordsMeanings,
    this.reference,
  });

  factory HadithDetailsModal.fromJson(Map<String, dynamic> json) =>
      _$HadithDetailsModalFromJson(json);

  Map<String, dynamic> toJson() => _$HadithDetailsModalToJson(this);
}

@JsonSerializable()
class WordsMeaning {
  dynamic word;
  dynamic meaning;

  WordsMeaning({
    this.word,
    this.meaning,
  });
  factory WordsMeaning.fromJson(Map<String, dynamic> json) =>
      _$WordsMeaningFromJson(json);
}
