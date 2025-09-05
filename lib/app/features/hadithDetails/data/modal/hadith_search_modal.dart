import 'package:freezed_annotation/freezed_annotation.dart';

part "hadith_search_modal.g.dart";

@JsonSerializable()
class SearchResultModal {
  Ahadith ahadith;

  SearchResultModal({required this.ahadith});

  factory SearchResultModal.fromJson(Map<String, dynamic> json) =>
      _$SearchResultModalFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultModalToJson(this);
}

@JsonSerializable()
class Ahadith {
  String result;

  Ahadith({required this.result});

  factory Ahadith.fromJson(Map<String, dynamic> json) =>
      _$AhadithFromJson(json);

  Map<String, dynamic> toJson() => _$AhadithToJson(this);
}
